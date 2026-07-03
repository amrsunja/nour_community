import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:nour/src/features/impact/data/models/impact_project_model.dart';
import 'package:nour/src/features/payments/data/models/payout_model.dart';
import 'package:nour/src/features/payments/data/models/transaction_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/project_analytics_model.dart';
import '../models/record_payout_params.dart';

final adminRemoteDataProvider = Provider((ref) => AdminRemoteDatasource());

/// Admin-only data access for the payments/donations administration tools.
/// Every read here is gated by RLS / SECURITY DEFINER admin checks, so a
/// non-admin caller simply gets nothing (or a thrown error from the RPC).
class AdminRemoteDatasource {
  static const _payoutsTable = 'payouts';
  static const _payoutItemsTable = 'payout_items';
  static const _transactionsTable = 'transactions';
  static const _projectsTable = 'impact_projects';
  static const _proofBucket = 'payout-proofs';

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

  // ── Analytics ──────────────────────────────────────────────────────────────

  /// Per-(project,type) donation aggregates via `fn_admin_project_analytics`.
  Future<List<ProjectAnalyticsModel>> fetchAnalytics() async {
    try {
      final rows = await supabaseClient.rpc('fn_admin_project_analytics');
      return (rows as List)
          .map((e) => ProjectAnalyticsModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } catch (e) {
      talker.error('[admin] fetchAnalytics', e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.adminAnalyticsLoadFailed,
      );
    }
  }

  /// All projects (incl. inactive) with their organization — used to render
  /// titles in the analytics list and to populate the record-payout picker.
  Future<List<ImpactProjectModel>> fetchAllProjects() async {
    try {
      final response = await supabaseClient
          .from(_projectsTable)
          .select('*, partner_organizations(*), project_categories(*)')
          .order('position', ascending: true);
      return (response as List)
          .map((e) => ImpactProjectModel.fromJson(e))
          .toList();
    } catch (e) {
      talker.error('[admin] fetchAllProjects', e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.adminAnalyticsLoadFailed,
      );
    }
  }

  // ── Payouts ────────────────────────────────────────────────────────────────

  /// The full payout ledger, newest first (admin sees every status).
  Future<List<PayoutModel>> fetchPayouts() async {
    try {
      final response = await supabaseClient
          .from(_payoutsTable)
          .select()
          .order('created_at', ascending: false);
      return (response as List).map((e) => PayoutModel.fromJson(e)).toList();
    } catch (e) {
      talker.error('[admin] fetchPayouts', e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.adminPayoutsLoadFailed,
      );
    }
  }

  /// Uploads a disbursement receipt to the private `payout-proofs` bucket and
  /// returns its object path (stored on the payout row as `proof_url`).
  Future<String> uploadProof({
    required Uint8List bytes,
    required String fileExt,
    required String contentType,
  }) async {
    final userId = _requireUserId();
    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final path = 'payouts/$userId/$ts.$fileExt';
      await supabaseClient.storage.from(_proofBucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );
      return path;
    } catch (e) {
      talker.error('[admin] uploadProof', e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.adminPayoutProofUploadFailed,
      );
    }
  }

  /// Signed URL for a proof object (private bucket → time-limited link).
  Future<String?> signedProofUrl(String path, {int expiresIn = 3600}) async {
    try {
      return await supabaseClient.storage
          .from(_proofBucket)
          .createSignedUrl(path, expiresIn);
    } catch (e) {
      talker.error('[admin] signedProofUrl', e);
      return null;
    }
  }

  /// Records a payout and (optionally) links the exact transaction_items it
  /// settled for a gold-standard audit trail.
  Future<void> createPayout(
    RecordPayoutParams params, {
    List<int> transactionItemIds = const [],
  }) async {
    final userId = _requireUserId();
    try {
      final inserted = await supabaseClient
          .from(_payoutsTable)
          .insert(params.toInsert(userId))
          .select('id')
          .single();

      final payoutId = inserted['id'] as int;

      if (transactionItemIds.isNotEmpty) {
        await supabaseClient.from(_payoutItemsTable).insert([
          for (final id in transactionItemIds)
            {'payout_id': payoutId, 'transaction_item_id': id},
        ]);
      }
    } catch (e) {
      talker.error('[admin] createPayout', e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.adminPayoutCreateFailed,
      );
    }
  }

  // ── Received transactions ────────────────────────────────────────────────

  /// Every received transaction (admin reads all via RLS), newest first.
  Future<List<TransactionModel>> fetchTransactions() async {
    try {
      final response = await supabaseClient
          .from(_transactionsTable)
          .select('*, transaction_items(*)')
          .order('created_at', ascending: false)
          .limit(200);
      return (response as List)
          .map((e) => TransactionModel.fromJson(e))
          .toList();
    } catch (e) {
      talker.error('[admin] fetchTransactions', e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.adminTransactionsLoadFailed,
      );
    }
  }
}
