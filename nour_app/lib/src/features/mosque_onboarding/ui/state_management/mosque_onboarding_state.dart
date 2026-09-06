import 'package:equatable/equatable.dart';

import '../../data/models/mosque_onboarding_draft.dart';

class MosqueOnboardingState extends Equatable {
  final bool isLoading;
  final bool restored;
  final MosqueOnboardingDraft draft;

  const MosqueOnboardingState({
    this.isLoading = false,
    this.restored = false,
    this.draft = MosqueOnboardingDraft.empty,
  });

  int get pageIndex => draft.step.index;
  static int get pageCount => MosqueOnboardingStep.values.length;

  MosqueOnboardingState copyWith({
    bool? isLoading,
    bool? restored,
    MosqueOnboardingDraft? draft,
  }) {
    return MosqueOnboardingState(
      isLoading: isLoading ?? this.isLoading,
      restored: restored ?? this.restored,
      draft: draft ?? this.draft,
    );
  }

  @override
  List<Object?> get props => [isLoading, restored, draft];
}
