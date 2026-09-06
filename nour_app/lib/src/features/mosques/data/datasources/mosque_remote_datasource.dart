import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:nour/src/features/mosque_onboarding/data/models/mosque_onboarding_draft.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/mosque_enums.dart';
import '../models/mosque_model.dart';

final mosqueRemoteDataProvider = Provider((ref) => MosqueRemoteDatasource());

/// The caller's own mosque (any status) + role, from `fn_my_mosque`.
class MyMosque {
  const MyMosque({required this.mosque, required this.role});
  final MosqueModel mosque;
  final MosqueAdminRole role;
}

/// Account-level reads/writes of the mosques module (registration, own
/// mosque). Public catalogue / profile reads live in `MosqueCatalogDatasource`.
class MosqueRemoteDatasource {
  static const _mosquesTable = 'mosques';

  String _requireUserId() {
    final authUser = supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw ServerException(type: .unauthorized, messageKey: ApiErrorKey.userNotAuthenticated);
    }
    return authUser.id;
  }

  /// Registers the mosque for the freshly signed-up manager. Idempotent.
  Future<int> registerMosque(MosqueOnboardingDraft draft) async {
    _requireUserId();
    try {
      final result = await supabaseClient.rpc('fn_register_mosque', params: {
        'p_legal_name': draft.legalName,
        'p_legal_status': (draft.legalStatus ?? MosqueLegalStatus.other).dbValue,
        'p_rna': draft.rna?.trim().toUpperCase(),
        'p_siren': draft.siren?.trim(),
        'p_country_code': draft.countryCode ?? 'FR',
        'p_language': draft.language ?? 'fr',
      });
      return (result as num).toInt();
    } on PostgrestException catch (e) {
      talker.error(e);
      final key = switch (e.message) {
        final m when m.contains('profile_is_worshipper') => ApiErrorKey.mosqueRegisterIsWorshipper,
        final m when m.contains('anonymous_not_allowed') => ApiErrorKey.mosqueRegisterAnonymous,
        final m when m.contains('invalid_siren') => ApiErrorKey.mosqueRegisterInvalidSiren,
        final m when m.contains('invalid_rna') => ApiErrorKey.mosqueRegisterInvalidRna,
        final m when m.contains('mosques_siren_uniq') || m.contains('duplicate key') => ApiErrorKey.mosqueRegisterDuplicate,
        _ => ApiErrorKey.mosqueRegisterFailed,
      };
      throw ServerException(type: .badRequest, messageKey: key);
    } catch (e) {
      talker.error(e);
      throw ServerException(type: .unknown, messageKey: ApiErrorKey.mosqueRegisterFailed);
    }
  }

  /// The caller's mosque (null when the account manages none).
  Future<MyMosque?> getMyMosque() async {
    _requireUserId();
    try {
      final rows = await supabaseClient.rpc('fn_my_mosque') as List;
      if (rows.isEmpty) return null;
      final row = rows.first as Map<String, dynamic>;
      final mosqueJson = row['mosque'];
      if (mosqueJson is! Map) return null;
      return MyMosque(
        mosque: MosqueModel.fromJson(mosqueJson.cast<String, dynamic>()),
        role: MosqueAdminRole.fromDb(row['role'] as String?),
      );
    } catch (e) {
      talker.error(e);
      throw ServerException(type: .badRequest, messageKey: ApiErrorKey.mosqueLoadFailed);
    }
  }

  /// Realtime stream of the status column of one mosque row.
  Stream<MosqueStatus> watchStatus(int mosqueId) {
    return supabaseClient
        .from(_mosquesTable)
        .stream(primaryKey: ['id'])
        .eq('id', mosqueId)
        .map((rows) => rows.isEmpty
            ? MosqueStatus.pendingReview
            : MosqueStatus.fromDb(rows.first['status'] as String?));
  }

  /// Admin-editable public profile columns.
  Future<MosqueModel> updateProfile(MosqueModel mosque) async {
    _requireUserId();
    try {
      final response = await supabaseClient
          .from(_mosquesTable)
          .update(mosque.toProfileUpdateJson())
          .eq('id', mosque.id)
          .select('*, mosque_imams(*)')
          .single();
      return MosqueModel.fromJson(response);
    } catch (e) {
      talker.error(e);
      throw ServerException(type: .badRequest, messageKey: ApiErrorKey.mosqueSaveFailed);
    }
  }
}
