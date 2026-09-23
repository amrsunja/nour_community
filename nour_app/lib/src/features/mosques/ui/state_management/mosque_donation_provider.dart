import 'package:equatable/equatable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/features/payments/data/models/tx_enums.dart';

import '../../data/models/mosque_donation_models.dart';
import '../../data/mosque_repo.dart';

/// Worshipper view of a mosque's Donation tab: Sadaqa card settings, active
/// campaigns and the caller's own recurring gift.
class MosqueDonationState extends Equatable {
  final bool isLoading;
  final bool loaded;
  final MosqueDonationSettings? settings;
  final List<MosqueCampaignModel> campaigns;
  final MyMosqueSubscription? mySubscription;
  final DonationFrequency frequency;
  final double amount;
  final bool cancelBusy;

  const MosqueDonationState({
    this.isLoading = false,
    this.loaded = false,
    this.settings,
    this.campaigns = const [],
    this.mySubscription,
    this.frequency = DonationFrequency.oneTime,
    this.amount = 50,
    this.cancelBusy = false,
  });

  List<MosqueCampaignModel> get activeCampaigns => campaigns.where((c) => c.isOpen).toList();
  List<MosqueCampaignModel> get closedCampaigns => campaigns.where((c) => !c.isOpen).toList();

  MosqueDonationState copyWith({
    bool? isLoading,
    bool? loaded,
    MosqueDonationSettings? settings,
    List<MosqueCampaignModel>? campaigns,
    MyMosqueSubscription? mySubscription,
    bool clearSubscription = false,
    DonationFrequency? frequency,
    double? amount,
    bool? cancelBusy,
  }) =>
      MosqueDonationState(
        isLoading: isLoading ?? this.isLoading,
        loaded: loaded ?? this.loaded,
        settings: settings ?? this.settings,
        campaigns: campaigns ?? this.campaigns,
        mySubscription: clearSubscription ? null : (mySubscription ?? this.mySubscription),
        frequency: frequency ?? this.frequency,
        amount: amount ?? this.amount,
        cancelBusy: cancelBusy ?? this.cancelBusy,
      );

  @override
  List<Object?> get props => [isLoading, loaded, settings, campaigns, mySubscription, frequency, amount, cancelBusy];
}

final mosqueDonationProvider = StateNotifierProvider.autoDispose.family<MosqueDonationPresenter, MosqueDonationState, int>((ref, mosqueId) {
  return MosqueDonationPresenter(mosqueId: mosqueId, repo: ref.read(mosqueRepoProvider), appEvents: ref.read(appEventProvider));
});

class MosqueDonationPresenter extends Presenter<MosqueDonationState> {
  MosqueDonationPresenter({required this.mosqueId, required this.repo, required this.appEvents}) : super(const MosqueDonationState());

  final int mosqueId;
  final MosqueRepo repo;
  final AppEvents appEvents;

  Future<void> init() async {
    if (state.loaded || state.isLoading) return;
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    final settingsF = repo.getDonationSettings(mosqueId);
    final campaignsF = repo.getCampaigns(mosqueId);
    final subF = repo.getMyActiveSubscription(mosqueId, type: 'mosque_sadaqa');
    final settingsRes = await settingsF;
    final campaignsRes = await campaignsF;
    final sub = await subF;
    if (!mounted) return;

    final settings = settingsRes.when((v) => v, (e) {
      appEvents.send(ShowErrorEvent(e));
      return null;
    });
    final campaigns = campaignsRes.when((v) => v, (_) => const <MosqueCampaignModel>[]);

    final freqs = settings?.frequencies ?? const [DonationFrequency.oneTime];
    final frequency = freqs.contains(state.frequency) ? state.frequency : (freqs.isEmpty ? DonationFrequency.oneTime : freqs.first);
    final amounts = settings?.suggestedAmounts ?? const [10, 50, 100, 150];
    final amount = state.loaded ? state.amount : (amounts.length > 1 ? amounts[1] : amounts.first).toDouble();

    state = state.copyWith(
      isLoading: false,
      loaded: true,
      settings: settings,
      campaigns: campaigns,
      mySubscription: sub,
      clearSubscription: sub == null,
      frequency: frequency,
      amount: amount,
    );
  }

  void setFrequency(DonationFrequency f) => state = state.copyWith(frequency: f);
  void setAmount(double v) => state = state.copyWith(amount: v);

  Future<bool> cancelMySubscription() async {
    final sub = state.mySubscription;
    if (sub == null || state.cancelBusy) return false;
    state = state.copyWith(cancelBusy: true);
    final res = await repo.cancelMosqueSubscription(sub.id);
    if (!mounted) return false;
    return res.when((_) {
      state = state.copyWith(cancelBusy: false, clearSubscription: true);
      return true;
    }, (e) {
      appEvents.send(ShowErrorEvent(e));
      state = state.copyWith(cancelBusy: false);
      return false;
    });
  }
}
