import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/features/analytics/data/analytics_repo.dart';
import 'package:nour/src/features/mosques/data/models/mosque_enums.dart';

import '../../data/datasources/mosque_onboarding_local_datasource.dart';
import '../../data/models/mosque_onboarding_draft.dart';
import 'mosque_onboarding_state.dart';

final mosqueOnboardingProvider =
    StateNotifierProvider<MosqueOnboardingPresenter, MosqueOnboardingState>((ref) {
  return MosqueOnboardingPresenter(
    local: ref.read(mosqueOnboardingLocalDataProvider),
    ref: ref,
  );
});

/// Sessionless mosque onboarding: every change is persisted locally so the
/// manager can resume after a cold start (§3.2).
class MosqueOnboardingPresenter extends Presenter<MosqueOnboardingState> {
  final MosqueOnboardingLocalDatasource local;
  final Ref ref;

  MosqueOnboardingPresenter({required this.local, required this.ref})
      : super(const MosqueOnboardingState());

  Future<void> restore() async {
    final draft = await local.read();
    state = state.copyWith(restored: true, draft: draft ?? MosqueOnboardingDraft.empty);
  }

  Future<void> _save(MosqueOnboardingDraft draft) async {
    state = state.copyWith(draft: draft);
    await local.write(draft);
  }

  Future<void> goTo(MosqueOnboardingStep step) async {
    ref.read(analyticsRepoProvider).trackOnboardingPage(100 + step.index);
    await _save(state.draft.copyWith(step: step));
  }

  Future<void> next() async {
    final i = state.draft.step.index;
    if (i >= MosqueOnboardingStep.values.length - 1) return;
    await goTo(MosqueOnboardingStep.values[i + 1]);
  }

  Future<void> previous() async {
    final i = state.draft.step.index;
    if (i <= 0) return;
    await goTo(MosqueOnboardingStep.values[i - 1]);
  }

  /// "Skip" from the feature screens jumps to the country step.
  Future<void> skipFeatures() => goTo(MosqueOnboardingStep.country);

  Future<void> setCountry(String code) => _save(state.draft.copyWith(countryCode: code));

  Future<void> setLanguage(String code) => _save(state.draft.copyWith(language: code));

  Future<void> setRegistration({
    required String legalName,
    required MosqueLegalStatus legalStatus,
    required String? rna,
    required String siren,
  }) =>
      _save(state.draft.copyWith(
        legalName: legalName.trim(),
        legalStatus: legalStatus,
        rna: rna?.trim().toUpperCase(),
        siren: siren.trim(),
      ));

  /// "Start over": wipe the draft and go back to the first step.
  Future<void> reset() async {
    await local.clear();
    state = const MosqueOnboardingState(restored: true);
  }
}
