import 'package:equatable/equatable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/features/mosques/data/models/mosque_dashboard_stats_model.dart';
import 'package:nour/src/features/mosques/data/models/mosque_post_model.dart';
import 'package:nour/src/features/mosques/data/mosque_repo.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';

class MosqueAdminDashboardState extends Equatable {
  final bool isLoading;
  final MosqueDashboardStats? stats;
  final List<MosquePostModel> recentPosts;

  /// True once the entrance animation has played — it is a *first open* effect,
  /// not something to replay on every tab switch.
  final bool introPlayed;

  /// Period of the fundraising header — drives the RPC, not a client-side filter.
  final MosqueFundraisingPeriod fundraisingPeriod;
  final bool isFundraisingLoading;

  const MosqueAdminDashboardState({
    this.isLoading = false,
    this.stats,
    this.recentPosts = const [],
    this.fundraisingPeriod = MosqueFundraisingPeriod.year,
    this.isFundraisingLoading = false,
    this.introPlayed = false,
  });

  MosqueAdminDashboardState copyWith({
    bool? isLoading,
    MosqueDashboardStats? stats,
    List<MosquePostModel>? recentPosts,
    MosqueFundraisingPeriod? fundraisingPeriod,
    bool? isFundraisingLoading,
    bool? introPlayed,
  }) =>
      MosqueAdminDashboardState(
        isLoading: isLoading ?? this.isLoading,
        stats: stats ?? this.stats,
        recentPosts: recentPosts ?? this.recentPosts,
        fundraisingPeriod: fundraisingPeriod ?? this.fundraisingPeriod,
        isFundraisingLoading: isFundraisingLoading ?? this.isFundraisingLoading,
        introPlayed: introPlayed ?? this.introPlayed,
      );

  @override
  List<Object?> get props => [isLoading, stats, recentPosts, fundraisingPeriod, isFundraisingLoading, introPlayed];
}

final mosqueAdminDashboardProvider =
    StateNotifierProvider<MosqueAdminDashboardPresenter, MosqueAdminDashboardState>((ref) {
  return MosqueAdminDashboardPresenter(repo: ref.read(mosqueRepoProvider), appEvents: ref.read(appEventProvider), ref: ref);
});

class MosqueAdminDashboardPresenter extends Presenter<MosqueAdminDashboardState> {
  final MosqueRepo repo;
  final AppEvents appEvents;
  final Ref ref;

  MosqueAdminDashboardPresenter({required this.repo, required this.appEvents, required this.ref})
      : super(const MosqueAdminDashboardState());

  int? get _mosqueId => ref.read(myMosqueProvider).mosque?.id;

  Future<void> load() async {
    final id = _mosqueId;
    if (id == null) return;
    state = state.copyWith(isLoading: true);
    final results = await Future.wait([
      repo.getDashboardStats(id, period: state.fundraisingPeriod),
      repo.getPosts(id, limit: 5),
    ]);
    (results[0] as dynamic).when(
      (s) => state = state.copyWith(stats: s as MosqueDashboardStats),
      (error) => appEvents.send(ShowErrorEvent(error)),
    );
    (results[1] as dynamic).when(
      (p) => state = state.copyWith(recentPosts: (p as List).cast<MosquePostModel>()),
      (_) {},
    );
    state = state.copyWith(isLoading: false);
    // Keep the header counters fresh.
    await ref.read(myMosqueProvider.notifier).load(silent: true);
  }

  /// Called by the page once it has committed to playing the entrance
  /// animation, so coming back to the tab does not replay it.
  void markIntroPlayed() {
    if (state.introPlayed) return;
    state = state.copyWith(introPlayed: true);
  }

  /// Fundraising period picker — refetches the stats only, the rest of the page
  /// keeps what it has so the card is the only thing that flickers.
  Future<void> setFundraisingPeriod(MosqueFundraisingPeriod period) async {
    if (period == state.fundraisingPeriod) return;
    final id = _mosqueId;
    state = state.copyWith(fundraisingPeriod: period, isFundraisingLoading: id != null);
    if (id == null) return;
    final res = await repo.getDashboardStats(id, period: period);
    res.when(
      (s) => state = state.copyWith(stats: s, isFundraisingLoading: false),
      (error) {
        state = state.copyWith(isFundraisingLoading: false);
        appEvents.send(ShowErrorEvent(error));
      },
    );
  }
}
