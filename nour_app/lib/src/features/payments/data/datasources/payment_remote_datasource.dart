import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import '../models/payout_model.dart';
import '../models/transaction_model.dart';
import '../models/tx_enums.dart';

final paymentRemoteDataProvider = Provider((ref) => PaymentRemoteDatasource());

/// Result of Phase 1 — the Stripe client secret plus our own transaction id.
class CreatedPaymentIntent {
  const CreatedPaymentIntent({
    required this.clientSecret,
    required this.transactionId,
  });

  final String clientSecret;
  final int transactionId;
}

/// Read/initiate access for the payment flow. All money WRITES happen in the
/// `create-payment-intent` Edge Function (service_role); the client only reads
/// its own transactions via RLS and calls the function to start a payment.
class PaymentRemoteDatasource {
  static const _transactionsTable = 'transactions';
  static const _payoutsTable = 'payouts';
  static const _createIntentFn = 'create-payment-intent';

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

  /// Phase 1 — asks the backend to create a PaymentIntent + a pending
  /// transaction. Returns the client secret to hand to the PaymentSheet.
  Future<CreatedPaymentIntent> createPaymentIntent({
    required TxType type,
    required String currency,
    required List<PaymentItem> items,
    required bool coverFees,
  }) async {
    _requireUserId();
    try {
      final res = await supabaseClient.functions.invoke(
        _createIntentFn,
        body: {
          'type': type.value,
          'currency': currency,
          'coverFees': coverFees,
          'items': items.map((i) => i.toJson()).toList(),
        },
      );

      final data = res.data;
      final clientSecret = data?['clientSecret'] as String?;
      final txId = data?['transactionId'] as int?;
      if (clientSecret == null || txId == null) {
        throw ServerException(
          type: .badRequest,
          messageKey: ApiErrorKey.paymentIntentFailed,
        );
      }
      return CreatedPaymentIntent(clientSecret: clientSecret, transactionId: txId);
    } on ServerException {
      rethrow;
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

  /// One-off status read — the timeout fallback if the app was backgrounded and
  /// missed the realtime push.
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

  /// The caller's donation/zakat history, newest first, with per-project items.
  Future<List<TransactionModel>> getHistory() async {
    final userId = _requireUserId();
    try {
      final response = await supabaseClient
          .from(_transactionsTable)
          .select('*, transaction_items(*)')
          .eq('user_id', userId)
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
}
