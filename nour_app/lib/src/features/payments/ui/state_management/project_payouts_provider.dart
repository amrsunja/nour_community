import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/features/payments/data/models/payout_model.dart';
import 'package:nour/src/features/payments/data/payment_repo.dart';

/// Confirmed disbursement proofs for a project (public transparency section).
/// Returns an empty list on error so the section degrades gracefully.
final projectPayoutsProvider = FutureProvider.autoDispose
    .family<List<PayoutModel>, int>((ref, projectId) async {
  final res = await ref.read(paymentRepoProvider).getProjectPayouts(projectId);
  return res.when((payouts) => payouts, (_) => <PayoutModel>[]);
});
