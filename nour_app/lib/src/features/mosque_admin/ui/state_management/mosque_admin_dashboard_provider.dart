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

  const MosqueAdminDashboardState({this.isLoading = false, this.stats, this.recentPosts = const []});

  MosqueAdminDashboardState copyWith({bool? isLoading, MosqueDashboardStats? stats, List<MosquePostModel>? recentPosts}) =>
      MosqueAdminDashboardState(
        isLoading: isLoading ?? this.isLoading,
        stats: stats ?? this.stats,
        recentPosts: recentPosts ?? this.recentPosts,
      );

  @override
  List<Object?> get props => [isLoading, stats, recentPosts];
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
    final results = await Future.wait([repo.getDashboardStats(id), repo.getPosts(id, limit: 5)]);
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
}
