import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:nour/src/core/utils/typedefs.dart';
import 'package:nour/src/features/payments/data/models/tx_enums.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/mosque_donation_models.dart';

final mosqueDonationRemoteDataProvider = Provider((ref) => MosqueDonationRemoteDatasource());

/// P3 — Sadaqa / campaigns / membership fee / receipts / Stripe Connect.
///
/// Money WRITES only happen in the edge functions (direct charges on the
/// mosque's connected account); the client reads through RLS + RPCs.
class MosqueDonationRemoteDatasource {
  static const _settings = 'mosque_donation_settings';
  static const _campaigns = 'mosque_campaigns';
  static const _campaignUpdates = 'mosque_campaign_updates';
  static const _stripeAccounts = 'mosque_stripe_accounts';
  static const _receipts = 'mosque_receipts';
  static const _subscriptions = 'donation_subscriptions';

  static const _fnOnboarding = 'mosque-stripe-onboarding';
  static const _fnIntent = 'create-mosque-payment-intent';
  static const _fnSubscription = 'create-mosque-subscription';
  static const _fnCancel = 'cancel-mosque-subscription';
  static const _fnReceipt = 'generate-mosque-receipt';

  String _requireUserId() {
    final user = supabaseClient.auth.currentUser;
    if (user == null) throw ServerException(type: .unauthorized, messageKey: ApiErrorKey.userNotAuthenticated);
    return user.id;
  }

  ServerException _wrap(Object e, ApiErrorKey fallback) {
    talker.error(e);
    if (e is ServerException) return e;
    if (e is PostgrestException) {
      if (e.message.contains('campaign_limit_reached')) return ServerException(type: .badRequest, messageKey: ApiErrorKey.mosqueCampaignLimitReached);
      if (e.message.contains('forbidden') || e.code == '42501') return ServerException(type: .forbiden, messageKey: ApiErrorKey.mosqueNotApproved);
      return ServerException(type: .badRequest, message: e.message);
    }
    return ServerException(type: .badRequest, messageKey: fallback);
  }

  ApiErrorKey _mapFunctionError(dynamic data, ApiErrorKey fallback) {
    final code = data is Map ? data['error'] : null;
    return switch (code) {
      'amount_too_small' => ApiErrorKey.paymentAmountTooSmall,
      'amount_too_large' => ApiErrorKey.paymentAmountTooLarge,
      'donations_disabled' || 'stripe_not_ready' || 'mosque_not_chargeable' => ApiErrorKey.mosqueDonationsDisabled,
      'campaign_closed' || 'campaign_not_found' => ApiErrorKey.mosqueCampaignClosed,
      'mosque_not_approved' || 'forbidden' => ApiErrorKey.mosqueNotApproved,
      'receipts_not_allowed' => ApiErrorKey.mosqueReceiptsNotAllowed,
      'no_donations' => ApiErrorKey.mosqueReceiptNoDonations,
      'method_not_supported' => ApiErrorKey.paymentIntentFailed,
      _ => fallback,
    };
  }

  ServerException _fnError(Object e, ApiErrorKey fallback) {
    if (e is ServerException) return e;
    if (e is FunctionException) {
      talker.error('[mosque-donation] fn ${e.status}', e);
      return ServerException(type: .badRequest, messageKey: _mapFunctionError(e.details, fallback));
    }
    talker.error('[mosque-donation] fn', e);
    return ServerException(type: .badRequest, messageKey: fallback);
  }

  static double _toDouble(dynamic v) => v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);

  // ── Public reads ──────────────────────────────────────────────────────────

  Future<MosqueDonationSettings> getSettings(int mosqueId) async {
    try {
      final row = await supabaseClient.from(_settings).select().eq('mosque_id', mosqueId).maybeSingle();
      return row == null ? MosqueDonationSettings(mosqueId: mosqueId) : MosqueDonationSettings.fromJson(row);
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueLoadFailed);
    }
  }

  Future<List<MosqueCampaignModel>> getCampaigns(int mosqueId, {bool activeOnly = false, int limit = 20}) async {
    try {
      var q = supabaseClient.from(_campaigns).select().eq('mosque_id', mosqueId);
      if (activeOnly) q = q.eq('status', 'active');
      final rows = await q.order('status', ascending: true).order('ends_at', ascending: true).limit(limit);
      return (rows as List).map((e) => MosqueCampaignModel.fromJson(e as Json)).toList();
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueLoadFailed);
    }
  }

  Future<MosqueCampaignModel> getCampaign(int campaignId) async {
    try {
      final row = await supabaseClient.from(_campaigns).select().eq('id', campaignId).single();
      return MosqueCampaignModel.fromJson(row);
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueLoadFailed);
    }
  }

  /// Realtime on one campaign (progress bar after a gift, close by cron).
  Stream<MosqueCampaignModel?> watchCampaign(int campaignId) => supabaseClient
      .from(_campaigns)
      .stream(primaryKey: ['id'])
      .eq('id', campaignId)
      .map((rows) => rows.isEmpty ? null : MosqueCampaignModel.fromJson(rows.first));

  Future<List<MosqueCampaignUpdate>> getCampaignUpdates(int campaignId) async {
    try {
      final rows = await supabaseClient.from(_campaignUpdates).select().eq('campaign_id', campaignId).order('created_at', ascending: false).limit(20);
      return (rows as List).map((e) => MosqueCampaignUpdate.fromJson(e as Json)).toList();
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueLoadFailed);
    }
  }

  Future<List<MosqueCampaignDonor>> getCampaignRecentDonors(int campaignId, {int limit = 3}) async {
    try {
      final rows = await supabaseClient.rpc('fn_mosque_campaign_recent_donors', params: {'p_campaign_id': campaignId, 'p_limit': limit});
      return (rows as List).map((e) => MosqueCampaignDonor.fromJson(e as Json)).toList();
    } catch (e) {
      talker.error('[mosque-donation] recentDonors', e);
      return const [];
    }
  }

  // ── Donor: pay ────────────────────────────────────────────────────────────

  Future<MosqueCreatedPayment> createPaymentIntent({
    required int mosqueId,
    required double amount,
    required String currency,
    int? campaignId,
    int? membershipId,
    required bool isAnonymous,
    required PaymentMethodKind paymentMethod,
    required String clientKey,
  }) async {
    _requireUserId();
    try {
      final res = await supabaseClient.functions.invoke(_fnIntent, body: {
        'mosqueId': mosqueId,
        'amount': amount,
        'currency': currency,
        if (campaignId != null) 'campaignId': campaignId,
        if (membershipId != null) 'membershipId': membershipId,
        'isAnonymous': isAnonymous,
        'paymentMethod': paymentMethod.value,
        'clientKey': clientKey,
      });
      final data = res.data;
      final secret = data?['clientSecret'] as String?;
      final txId = (data?['transactionId'] as num?)?.toInt();
      final acct = data?['stripeAccountId'] as String?;
      if (secret == null || txId == null || acct == null) {
        throw ServerException(type: .badRequest, messageKey: _mapFunctionError(data, ApiErrorKey.paymentIntentFailed));
      }
      return MosqueCreatedPayment(clientSecret: secret, stripeAccountId: acct, transactionId: txId, amountCharged: _toDouble(data?['amountCharged']));
    } catch (e) {
      throw _fnError(e, ApiErrorKey.paymentIntentFailed);
    }
  }

  Future<MosqueCreatedPayment> createSubscription({
    required int mosqueId,
    required double amount,
    required String currency,
    required DonationFrequency frequency,
    int? membershipId,
    required bool isAnonymous,
    required PaymentMethodKind paymentMethod,
    required String clientKey,
  }) async {
    _requireUserId();
    try {
      final res = await supabaseClient.functions.invoke(_fnSubscription, body: {
        'mosqueId': mosqueId,
        'amount': amount,
        'currency': currency,
        'interval': frequency.interval ?? 'month',
        if (membershipId != null) 'membershipId': membershipId,
        'isAnonymous': isAnonymous,
        'paymentMethod': paymentMethod.value,
        'clientKey': clientKey,
      });
      final data = res.data;
      final secret = data?['clientSecret'] as String?;
      final subId = (data?['subscriptionId'] as num?)?.toInt();
      final acct = data?['stripeAccountId'] as String?;
      if (secret == null || subId == null || acct == null) {
        throw ServerException(type: .badRequest, messageKey: _mapFunctionError(data, ApiErrorKey.paymentSubscriptionFailed));
      }
      return MosqueCreatedPayment(
        clientSecret: secret,
        stripeAccountId: acct,
        subscriptionId: subId,
        customerId: data?['customerId'] as String?,
        ephemeralKeySecret: data?['ephemeralKeySecret'] as String?,
        amountCharged: _toDouble(data?['amountCharged']),
      );
    } catch (e) {
      throw _fnError(e, ApiErrorKey.paymentSubscriptionFailed);
    }
  }

  Future<void> cancelSubscription(int subscriptionId, {bool immediately = false}) async {
    _requireUserId();
    try {
      await supabaseClient.functions.invoke(_fnCancel, body: {'subscriptionId': subscriptionId, 'immediately': immediately});
    } catch (e) {
      throw _fnError(e, ApiErrorKey.paymentSubscriptionCancelFailed);
    }
  }

  // ── Donor: history ────────────────────────────────────────────────────────

  Future<List<MyMosqueDonation>> getMyDonations({int limit = 100}) async {
    _requireUserId();
    try {
      final rows = await supabaseClient.rpc('fn_my_mosque_donations', params: {'p_limit': limit});
      return (rows as List).map((e) => MyMosqueDonation.fromJson(e as Json)).toList();
    } catch (e) {
      throw _wrap(e, ApiErrorKey.paymentHistoryLoadFailed);
    }
  }

  Future<List<MyMosqueSubscription>> getMySubscriptions() async {
    final uid = _requireUserId();
    try {
      final rows = await supabaseClient
          .from(_subscriptions)
          .select('*, mosques(name)')
          .eq('user_id', uid)
          .not('mosque_id', 'is', null)
          .order('created_at', ascending: false);
      return (rows as List).map((e) => MyMosqueSubscription.fromJson(e as Json)).toList();
    } catch (e) {
      throw _wrap(e, ApiErrorKey.paymentSubscriptionsLoadFailed);
    }
  }

  /// Active recurring gift of the caller to [mosqueId] (Sadaqa or fee).
  Future<MyMosqueSubscription?> getMyActiveSubscription(int mosqueId, {String? type}) async {
    final uid = supabaseClient.auth.currentUser?.id;
    if (uid == null) return null;
    try {
      var q = supabaseClient.from(_subscriptions).select('*, mosques(name)').eq('user_id', uid).eq('mosque_id', mosqueId).inFilter('status', ['active', 'past_due']);
      if (type != null) q = q.eq('type', type);
      final rows = await q.order('created_at', ascending: false).limit(1);
      if ((rows as List).isEmpty) return null;
      return MyMosqueSubscription.fromJson(rows.first as Json);
    } catch (e) {
      talker.error('[mosque-donation] activeSub', e);
      return null;
    }
  }

  /// Receipts of the caller (all mosques) or, for an admin, of one mosque.
  Future<List<MosqueReceipt>> getReceipts({int? mosqueId, int? year}) async {
    final uid = _requireUserId();
    try {
      var q = supabaseClient.from(_receipts).select();
      q = mosqueId != null ? q.eq('mosque_id', mosqueId) : q.eq('user_id', uid);
      if (year != null) q = q.eq('year', year);
      final rows = await q.order('created_at', ascending: false).limit(200);
      return (rows as List).map((e) => MosqueReceipt.fromJson(e as Json)).toList();
    } catch (e) {
      throw _wrap(e, ApiErrorKey.paymentHistoryLoadFailed);
    }
  }

  /// Signed URL (1h) of an existing receipt PDF.
  Future<String?> receiptUrl(String storagePath) async {
    try {
      return await supabaseClient.storage.from('mosque-receipts').createSignedUrl(storagePath, 3600);
    } catch (e) {
      talker.error('[mosque-donation] receiptUrl', e);
      return null;
    }
  }

  /// Generates (or returns the existing) receipt. Either one gift
  /// ([transactionId]) or a yearly summary ([mosqueId] + [year], admins may
  /// pass [userId] for a donor).
  Future<GeneratedReceipt> generateReceipt({int? transactionId, int? mosqueId, int? year, String? userId}) async {
    _requireUserId();
    try {
      final res = await supabaseClient.functions.invoke(_fnReceipt, body: {
        if (transactionId != null) 'transactionId': transactionId,
        if (mosqueId != null) 'mosqueId': mosqueId,
        if (year != null) 'year': year,
        if (userId != null) 'userId': userId,
      });
      final data = res.data;
      final id = (data?['receiptId'] as num?)?.toInt();
      if (id == null) throw ServerException(type: .badRequest, messageKey: _mapFunctionError(data, ApiErrorKey.mosqueReceiptFailed));
      return GeneratedReceipt(receiptId: id, amount: _toDouble(data?['amount']), number: data?['number'] as String?, url: data?['url'] as String?);
    } catch (e) {
      throw _fnError(e, ApiErrorKey.mosqueReceiptFailed);
    }
  }

  // ── Admin ─────────────────────────────────────────────────────────────────

  Future<MosqueStripeAccount> getStripeAccount(int mosqueId) async {
    try {
      final row = await supabaseClient.from(_stripeAccounts).select().eq('mosque_id', mosqueId).maybeSingle();
      return row == null ? const MosqueStripeAccount() : MosqueStripeAccount.fromRow(row);
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueLoadFailed);
    }
  }

  /// `action: 'start'` → hosted onboarding URL (account created on first call).
  Future<String> startStripeOnboarding(int mosqueId, {bool canIssueTaxReceipts = false}) async {
    _requireUserId();
    try {
      final res = await supabaseClient.functions.invoke(_fnOnboarding, body: {'mosqueId': mosqueId, 'action': 'start', 'canIssueTaxReceipts': canIssueTaxReceipts});
      final url = res.data?['url'] as String?;
      if (url == null) throw ServerException(type: .badRequest, messageKey: _mapFunctionError(res.data, ApiErrorKey.mosqueStripeFailed));
      return url;
    } catch (e) {
      throw _fnError(e, ApiErrorKey.mosqueStripeFailed);
    }
  }

  /// `action: 'status'` → refreshes the row from Stripe and flips
  /// `mosques.donations_enabled`.
  Future<MosqueStripeAccount> refreshStripeStatus(int mosqueId) async {
    _requireUserId();
    try {
      final res = await supabaseClient.functions.invoke(_fnOnboarding, body: {'mosqueId': mosqueId, 'action': 'status'});
      final data = res.data;
      if (data is! Map || data['accountId'] == null) {
        // No account yet — not an error.
        return const MosqueStripeAccount();
      }
      return MosqueStripeAccount.fromStatus(Map<String, dynamic>.from(data));
    } catch (e) {
      throw _fnError(e, ApiErrorKey.mosqueStripeFailed);
    }
  }

  Future<MosqueDonationSettings> saveSettings(MosqueDonationSettings s) async {
    try {
      final row = await supabaseClient.from(_settings).upsert(s.toJson(), onConflict: 'mosque_id').select().single();
      return MosqueDonationSettings.fromJson(row);
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueSaveFailed);
    }
  }

  Future<MosqueCampaignModel> createCampaign(int mosqueId, MosqueCampaignDraft d) async {
    final uid = _requireUserId();
    try {
      final row = await supabaseClient.from(_campaigns).insert({...d.toJson(mosqueId), 'status': 'active', 'created_by': uid}).select().single();
      return MosqueCampaignModel.fromJson(row);
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueSaveFailed);
    }
  }

  Future<MosqueCampaignModel> updateCampaign(int mosqueId, MosqueCampaignDraft d) async {
    try {
      final patch = d.toJson(mosqueId)..remove('mosque_id');
      final row = await supabaseClient.from(_campaigns).update(patch).eq('id', d.id!).select().single();
      return MosqueCampaignModel.fromJson(row);
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueSaveFailed);
    }
  }

  Future<MosqueCampaignModel> extendCampaign(int campaignId, DateTime endsAt) async {
    try {
      final row = await supabaseClient
          .from(_campaigns)
          .update({'ends_at': endsAt.toUtc().toIso8601String(), 'status': 'active', 'closed_at': null, 'closed_reason': null, 'reminded_at': null})
          .eq('id', campaignId)
          .select()
          .single();
      return MosqueCampaignModel.fromJson(row);
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueSaveFailed);
    }
  }

  Future<MosqueCampaignModel> closeCampaign(int campaignId, {String reason = 'manual'}) async {
    try {
      final row = await supabaseClient
          .from(_campaigns)
          .update({'status': 'closed', 'closed_at': DateTime.now().toUtc().toIso8601String(), 'closed_reason': reason})
          .eq('id', campaignId)
          .select()
          .single();
      return MosqueCampaignModel.fromJson(row);
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueSaveFailed);
    }
  }

  Future<MosqueCampaignUpdate> postCampaignUpdate({required int mosqueId, required int campaignId, required String body, String? imageUrl}) async {
    try {
      final row = await supabaseClient
          .from(_campaignUpdates)
          .insert({'mosque_id': mosqueId, 'campaign_id': campaignId, 'body': body.trim(), 'image_url': imageUrl})
          .select()
          .single();
      return MosqueCampaignUpdate.fromJson(row);
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueSaveFailed);
    }
  }

  Future<MosqueDonationStats> getStats(int mosqueId, {int? year}) async {
    try {
      final data = await supabaseClient.rpc('fn_mosque_donation_stats', params: {'p_mosque_id': mosqueId, 'p_year': year});
      return MosqueDonationStats.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueLoadFailed);
    }
  }

  Future<List<MosqueDonorRow>> getDonors(int mosqueId, {int? year, String? type, int limit = 50, int offset = 0}) async {
    try {
      final rows = await supabaseClient.rpc('fn_mosque_donors', params: {
        'p_mosque_id': mosqueId,
        'p_year': year,
        'p_type': type,
        'p_limit': limit,
        'p_offset': offset,
      });
      return (rows as List).map((e) => MosqueDonorRow.fromJson(e as Json)).toList();
    } catch (e) {
      throw _wrap(e, ApiErrorKey.mosqueLoadFailed);
    }
  }
}
