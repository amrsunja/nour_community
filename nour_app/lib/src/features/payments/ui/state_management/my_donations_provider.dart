import 'package:equatable/equatable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';

import 'package:nour/src/features/mosques/data/models/mosque_donation_models.dart';
import 'package:nour/src/features/mosques/data/mosque_repo.dart';

import '../../data/models/donation_subscription_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/payment_repo.dart';

class MyDonationsState extends Equatable {
  final bool isLoading;
  final bool hasError;
  final List<TransactionModel> history;
  final List<DonationSubscriptionModel> subscriptions;

  /// P3 — gifts to mosques (direct charges) and recurring mosque gifts.
  final List<MyMosqueDonation> mosqueDonations;
  final List<MyMosqueSubscription> mosqueSubscriptions;

  /// Subscription id currently being cancelled (button spinner).
  final int? cancellingId;

  const MyDonationsState({
    this.isLoading = false,
    this.hasError = false,
    this.history = const [],
    this.subscriptions = const [],
    this.mosqueDonations = const [],
    this.mosqueSubscriptions = const [],
    this.cancellingId,
  });

  MyDonationsState copyWith({
    bool? isLoading,
    bool? hasError,
    List<TransactionModel>? history,
    List<DonationSubscriptionModel>? subscriptions,
    List<MyMosqueDonation>? mosqueDonations,
    List<MyMosqueSubscription>? mosqueSubscriptions,
    int? cancellingId,
    bool clearCancelling = false,
  }) => MyDonationsState(
    isLoading: isLoading ?? this.isLoading,
    hasError: hasError ?? this.hasError,
    history: history ?? this.history,
    subscriptions: subscriptions ?? this.subscriptions,
    mosqueDonations: mosqueDonations ?? this.mosqueDonations,
    mosqueSubscriptions: mosqueSubscriptions ?? this.mosqueSubscriptions,
    cancellingId: clearCancelling ? null : (cancellingId ?? this.cancellingId),
  );

  @override
  List<Object?> get props => [isLoading, hasError, history, subscriptions, mosqueDonations, mosqueSubscriptions, cancellingId];
}

/// Auto-disposed with the My donations page.
final myDonationsProvider =
    StateNotifierProvider.autoDispose<MyDonationsPresenter, MyDonationsState>((ref) {
  return MyDonationsPresenter(
    repo: ref.read(paymentRepoProvider),
    mosqueRepo: ref.read(mosqueRepoProvider),
    appEvents: ref.read(appEventProvider),
  );
});

class MyDonationsPresenter extends Presenter<MyDonationsState> {
  MyDonationsPresenter({required this.repo, required this.mosqueRepo, required this.appEvents})
      : super(const MyDonationsState());

  final PaymentRepo repo;
  final MosqueRepo mosqueRepo;
  final AppEvents appEvents;

  Future<void> init() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, hasError: false);
    await _load();
  }

  Future<void> refresh() => _load();

  Future<void> _load() async {
    final historyRes = await repo.getHistory();
    final subsRes = await repo.getMySubscriptions();
    final mosqueTxRes = await mosqueRepo.getMyMosqueDonations();
    final mosqueSubsRes = await mosqueRepo.getMyMosqueSubscriptions();
    if (!mounted) return;

    var hasError = false;
    final history = historyRes.when(
      (v) => v,
      (error) {
        hasError = true;
        appEvents.send(ShowErrorEvent(error));
        return state.history;
      },
    );
    final subs = subsRes.when(
      (v) => v,
      (error) {
        hasError = true;
        return state.subscriptions;
      },
    );

    state = state.copyWith(
      isLoading: false,
      hasError: hasError,
      history: history,
      subscriptions: subs,
      mosqueDonations: mosqueTxRes.when((v) => v, (_) => state.mosqueDonations),
      mosqueSubscriptions: mosqueSubsRes.when((v) => v, (_) => state.mosqueSubscriptions),
    );
  }

  /// P3 — recurring mosque gift (runs on the connected account).
  Future<void> cancelMosqueSubscription(int id) async {
    if (state.cancellingId != null) return;
    state = state.copyWith(cancellingId: id);
    final res = await mosqueRepo.cancelMosqueSubscription(id);
    if (!mounted) return;
    res.when((_) {}, (error) => appEvents.send(ShowErrorEvent(error)));
    state = state.copyWith(clearCancelling: true);
    await _load();
  }

  Future<void> cancelSubscription(int id) async {
    if (state.cancellingId != null) return;
    state = state.copyWith(cancellingId: id);
    final res = await repo.cancelSubscription(id);
    if (!mounted) return;
    res.when(
      (_) {},
      (error) => appEvents.send(ShowErrorEvent(error)),
    );
    state = state.copyWith(clearCancelling: true);
    await _load();
  }
}
