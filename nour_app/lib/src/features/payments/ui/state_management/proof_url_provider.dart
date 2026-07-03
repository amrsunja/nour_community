import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

const _proofBucket = 'payout-proofs';

/// Time-limited signed URL for a disbursement-proof object in the private
/// `payout-proofs` bucket. Works for any authenticated user (storage RLS allows
/// read), so it backs both the admin ledger and the public transparency
/// section. Returns null when the object is missing or unauthorized.
final proofSignedUrlProvider =
    FutureProvider.autoDispose.family<String?, String>((ref, path) async {
  if (path.isEmpty) return null;
  try {
    return await supabaseClient.storage
        .from(_proofBucket)
        .createSignedUrl(path, 3600);
  } catch (e) {
    talker.error('[proof] signedUrl', e);
    return null;
  }
});
