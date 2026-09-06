import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/donation_subscription_model.dart';
import '../models/payout_model.dart';
import '../models/transaction_model.dart';
import '../models/tx_enums.dart';

final paymentRemoteDataProvider = Provider((ref) => PaymentRemoteDatasource());

/// Result of Phase 1 for a ONE-TIME payment — the Stripe client secret plus
/// our own transaction id and the server-quoted fee/charge.
class CreatedPaymentIntent {
  const CreatedPaymentIntent({
    required this.clientSecret,
    required this.transactionId,
    required this.fee,
    required this.amountCharged,
  });

  final String clientSecret;
  final int transactionId;
  final double fee;
  final double amountCharged;
}

/// Result of Phase 1 for a RECURRING donation — the first invoice's client
/// secret plus the customer context PaymentSheet needs to save the method.
class CreatedSubscription {
  const CreatedSubscription({
    required this.clientSecret,
    required this.subscriptionId,
    required this.customerId,
    required this.ephemeralKeySecret,
    required this.fee,
    required this.amountCharged,
  });

  final String clientSecret;
  final int subscriptionId;
  final String? customerId;
  final String? ephemeralKeySecret;
  final double fee;
  final double amountCharged;
}

/// A recent, non-anonymous donor (from `fn_project_recent_donors`).
class RecentDonor {
  const RecentDonor({required this.userId, this.avatarUrl, this.name});

  final String userId;
  final String? avatarUrl;
  final String? name;
}

/// Read/initiate access for the payment flow. All money WRITES happen in the
/// edge functions (service_role); the client only reads its own rows via RLS
/// and calls the functions to start / stop a payment.
class PaymentRemoteDatasource {
  static const _transactionsTable = 'transactions';
  static const _subscriptionsTable = 'donation_subscriptions';
  static const _payoutsTable = 'payouts';
  static const _createIntentFn = 'create-payment-intent';
  static const _createSubscriptionFn = 'create-subscription';
  static const _cancelSubscriptionFn = 'cancel-subscription';
  static const _recentDonorsRpc = 'fn_project_recent_donors';

  String _requireUserId() {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw ServerException(
        type: .unauthorized,
        messageKey: ApiErrorKey.userNotAuthenticated,
      );
    }
    return user.id;
  }

  static double _toDouble(dynamic v) =>
      v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);

  /// Maps the edge-function error codes to stable API error keys.
  ApiErrorKey _mapFunctionError(dynamic data, ApiErrorKey fallback) {
    final code = data is Map ? data['error'] : null;
    return switch (code) {
      'amount_too_small' => ApiErrorKey.paymentAmountTooSmall,
      'amount_too_large' => ApiErrorKey.paymentAmountTooLarge,
      'project_inactive' => ApiErrorKey.paymentProjectInactive,
      'not_zakat_eligible' => ApiErrorKey.paymentNotZakatEligible,
      _ => fallback,
    };
  }

  // ── One-time ────────────────────────────────────────────────────────────────

  /// Phase 1 — asks the backend to create a PaymentIntent + a pending
  /// transaction. Returns the client secret to hand to Stripe.
  Future<CreatedPaymentIntent> createPaymentIntent({
    required TxType type,
    required String currency,
    required List<PaymentItem> items,
    required bool coverFees,
    required bool isAnonymous,
    required PaymentMethodKind paymentMethod,
    required String clientKey,
  }) async {
    _requireUserId();
    try {
      final res = await supabaseClient.functions.invoke(
        _createIntentFn,
        body: {
          'type': type.value,
          'currency': currency,
          'coverFees': coverFees,
          'isAnonymous': isAnonymous,
          'paymentMethod': paymentMethod.value,
          'clientKey': clientKey,
          'items': items.map((i) => i.toJson()).toList(),
        },
      );

      final data = res.data;
      final clientSecret = data?['clientSecret'] as String?;
      final txId = data?['transactionId'] as int?;
      if (clientSecret == null || txId == null) {
        throw ServerException(
          type: .badRequest,
          messageKey: _mapFunctionError(data, ApiErrorKey.paymentIntentFailed),
        );
      }
      return CreatedPaymentIntent(
        clientSecret: clientSecret,
        transactionId: txId,
        fee: _toDouble(data?['fee']),
        amountCharged: _toDouble(data?['amountCharged']),
      );
    } on ServerException {
      rethrow;
    } on FunctionException catch (e) {
      talker.error('[payment] createPaymentIntent ${e.status}', e);
      throw ServerException(
        type: .badRequest,
        messageKey: _mapFunctionError(e.details, ApiErrorKey.paymentIntentFailed),
      );
    } catch (e) {
      talker.error('[payment] createPaymentIntent', e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.paymentIntentFailed,
      );
    }
  }

  /// Phase 4 — subscribe to the caller's own transaction row. Emits every time
  /// the webhook mutates it; the presenter watches for `succeeded` / `failed`.
  Stream<TxStatus> watchTransactionStatus(int transactionId) {
    return supabaseClient
        .from(_transactionsTable)
        .stream(primaryKey: ['id'])
        .eq('id', transactionId)
        .map((rows) {
          if (rows.isEmpty) return TxStatus.pending;
          return TxStatus.fromString(rows.first['status'] as String);
        });
  }

  /// One-off status read — the polling / resume fallback if the app was
  /// backgrounded (wallet sheet, PayPal browser) and missed the realtime push.
  Future<TxStatus> fetchTransactionStatus(int transactionId) async {
    try {
      final row = await supabaseClient
          .from(_transactionsTable)
          .select('status')
          .eq('id', transactionId)
          .single();
      return TxStatus.fromString(row['status'] as String);
    } catch (e) {
      talker.error('[payment] fetchTransactionStatus', e);
      return TxStatus.pending;
    }
  }

  // ── Recurring ───────────────────────────────────────────────────────────────

  Future<CreatedSubscription> createSubscription({
    required int projectId,
    required double amount,
    required String currency,
    required DonationFrequency frequency,
    required bool coverFees,
    required bool isAnonymous,
    required PaymentMethodKind paymentMethod,
    required String clientKey,
  }) async {
    _requireUserId();
    assert(frequency.isRecurring);
    try {
      final res = await supabaseClient.functions.invoke(
        _createSubscriptionFn,
        body: {
          'projectId': projectId,
          'amount': amount,
          'currency': currency,
          'interval': frequency.interval,
          'coverFees': coverFees,
          'isAnonymous': isAnonymous,
          'paymentMethod': paymentMethod.value,
          'clientKey': clientKey,
        },
      );
      final data = res.data;
      final clientSecret = data?['clientSecret'] as String?;
      final subId = data?['subscriptionId'] as int?;
      if (clientSecret == null || subId == null) {
        throw ServerException(
          type: .badRequest,
          messageKey: _mapFunctionError(data, ApiErrorKey.paymentSubscriptionFailed),
        );
      }
      return CreatedSubscription(
        clientSecret: clientSecret,
        subscriptionId: subId,
        customerId: data?['customerId'] as String?,
        ephemeralKeySecret: data?['ephemeralKeySecret'] as String?,
        fee: _toDouble(data?['fee']),
        amountCharged: _toDouble(data?['amountCharged']),
      );
    } on ServerException {
      rethrow;
    } on FunctionException catch (e) {
      talker.error('[payment] createSubscription ${e.status}', e);
      throw ServerException(
        type: .badRequest,
        messageKey: _mapFunctionError(e.details, ApiErrorKey.paymentSubscriptionFailed),
      );
    } catch (e) {
      talker.error('[payment] createSubscription', e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.paymentSubscriptionFailed,
      );
    }
  }

  /// The subscription becomes `active` when the first invoice is paid
  /// (webhook `invoice.paid`). Realtime on the caller's own row.
  Stream<SubscriptionStatus> watchSubscriptionStatus(int subscriptionId) {
    return supabaseClient
        .from(_subscriptionsTable)
        .stream(primaryKey: ['id'])
        .eq('id', subscriptionId)
        .map((rows) {
          if (rows.isEmpty) return SubscriptionStatus.incomplete;
          return SubscriptionStatus.fromString(rows.first['status'] as String?);
        });
  }

  Future<SubscriptionStatus> fetchSubscriptionStatus(int subscriptionId) async {
    try {
      final row = await supabaseClient
          .from(_subscriptionsTable)
          .select('status')
          .eq('id', subscriptionId)
          .single();
      return SubscriptionStatus.fromString(row['status'] as String?);
    } catch (e) {
      talker.error('[payment] fetchSubscriptionStatus', e);
      return SubscriptionStatus.incomplete;
    }
  }

  Future<List<DonationSubscriptionModel>> getMySubscriptions() async {
    final userId = _requireUserId();
    try {
      final response = await supabaseClient
          .from(_subscriptionsTable)
          .select('*, impact_projects(id, title_en, title_fr, title_ar, title_de, '
              'title_nl, title_tr, title_id, title_ur, title_bn, title_ms, title_ru, '
              'cover_image_url)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return (response as List)
          .map((e) => DonationSubscriptionModel.fromJson(e))
          .toList();
    } catch (e) {
      talker.error('[payment] getMySubscriptions', e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.paymentSubscriptionsLoadFailed,
      );
    }
  }

  Future<void> cancelSubscription(int subscriptionId, {bool immediately = false}) async {
    _requireUserId();
    try {
      await supabaseClient.functions.invoke(
        _cancelSubscriptionFn,
        body: {'subscriptionId': subscriptionId, 'immediately': immediately},
      );
    } catch (e) {
      talker.error('[payment] cancelSubscription', e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.paymentSubscriptionCancelFailed,
      );
    }
  }

  // ── History / transparency ─────────────────────────────────────────────────

  /// The caller's donation/zakat history, newest first, with per-project items.
  Future<List<TransactionModel>> getHistory() async {
    final userId = _requireUserId();
    try {
      final response = await supabaseClient
          .from(_transactionsTable)
          .select('*, transaction_items(*, impact_projects(id, title_en, title_fr, '
              'title_ar, title_de, title_nl, title_tr, title_id, title_ur, '
              'title_bn, title_ms, title_ru, cover_image_url))')
          .eq('user_id', userId)
          .neq('status', 'pending')
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => TransactionModel.fromJson(e))
          .toList();
    } catch (e) {
      talker.error('[payment] getHistory', e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.paymentHistoryLoadFailed,
      );
    }
  }

  /// Public transparency: the CONFIRMED disbursement proofs for a project. RLS
  /// (`payouts_public_confirmed_read`) restricts this to confirmed rows only, so
  /// donors see exactly what has been sent to the partner — nothing pending.
  Future<List<PayoutModel>> getProjectPayouts(int projectId) async {
    _requireUserId();
    try {
      final response = await supabaseClient
          .from(_payoutsTable)
          .select()
          .eq('impact_project_id', projectId)
          .eq('status', 'confirmed')
          .order('executed_at', ascending: false)
          .order('created_at', ascending: false);

      return (response as List).map((e) => PayoutModel.fromJson(e)).toList();
    } catch (e) {
      talker.error('[payment] getProjectPayouts', e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.paymentProjectTransactionsLoadFailed,
      );
    }
  }

  /// Avatars of the latest non-anonymous donors (progress card). Best effort —
  /// an empty list simply falls back to the decorative avatars.
  Future<List<RecentDonor>> getRecentDonors(int projectId, {int limit = 3}) async {
    try {
      final response = await supabaseClient.rpc(
        _recentDonorsRpc,
        params: {'p_project_id': projectId, 'p_limit': limit},
      );
      return [
        for (final row in (response as List? ?? const []))
          if (row is Map)
            RecentDonor(
              userId: row['user_id'] as String,
              avatarUrl: row['avatar_url'] as String?,
              name: row['name'] as String?,
            ),
      ];
    } catch (e) {
      talker.error('[payment] getRecentDonors', e);
      return const [];
    }
  }
}
