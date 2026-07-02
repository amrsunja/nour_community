import 'package:equatable/equatable.dart';

/// The donation flow is a small state machine driven by [DonationPhase].
///
/// idle       → nothing started (form editable)
/// preparing  → creating the PaymentIntent + presenting the native sheet
/// processing → sheet closed OK; waiting for the webhook to confirm (truth)
/// success    → webhook flipped the tx to `succeeded`
/// failed     → payment failed (sheet error or webhook `failed`)
/// cancelled  → user dismissed the sheet
enum DonationPhase { idle, preparing, processing, success, failed, cancelled }

class DonationState extends Equatable {
  final DonationPhase phase;
  final int? transactionId;

  const DonationState({
    this.phase = DonationPhase.idle,
    this.transactionId,
  });

  bool get isBusy =>
      phase == DonationPhase.preparing || phase == DonationPhase.processing;

  DonationState copyWith({
    DonationPhase? phase,
    int? transactionId,
  }) => DonationState(
    phase: phase ?? this.phase,
    transactionId: transactionId ?? this.transactionId,
  );

  @override
  List<Object?> get props => [phase, transactionId];
}
