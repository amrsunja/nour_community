import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/features/mosques/data/models/mosque_member_model.dart';
import 'package:nour/src/features/mosques/data/mosque_repo.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';

enum CommunityFilter { all, followers, members, volunteers }

class MosqueAdminCommunityState extends Equatable {
  final bool isLoading;
  final CommunityFilter filter;
  final String query;
  final List<MosqueCommunityMember> items;
  final bool hasMore;

  const MosqueAdminCommunityState({
    this.isLoading = false,
    this.filter = CommunityFilter.all,
    this.query = '',
    this.items = const [],
    this.hasMore = false,
  });

  MosqueAdminCommunityState copyWith({bool? isLoading, CommunityFilter? filter, String? query, List<MosqueCommunityMember>? items, bool? hasMore}) =>
      MosqueAdminCommunityState(
        isLoading: isLoading ?? this.isLoading,
        filter: filter ?? this.filter,
        query: query ?? this.query,
        items: items ?? this.items,
        hasMore: hasMore ?? this.hasMore,
      );

  @override
  List<Object?> get props => [isLoading, filter, query, items, hasMore];
}

final mosqueAdminCommunityProvider =
    StateNotifierProvider.autoDispose<MosqueAdminCommunityPresenter, MosqueAdminCommunityState>((ref) {
  return MosqueAdminCommunityPresenter(repo: ref.read(mosqueRepoProvider), appEvents: ref.read(appEventProvider), ref: ref);
});

class MosqueAdminCommunityPresenter extends Presenter<MosqueAdminCommunityState> {
  static const _page = 30;
  final MosqueRepo repo;
  final AppEvents appEvents;
  final Ref ref;
  Timer? _debounce;

  MosqueAdminCommunityPresenter({required this.repo, required this.appEvents, required this.ref})
      : super(const MosqueAdminCommunityState());

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  int? get _mosqueId => ref.read(myMosqueProvider).mosque?.id;

  Future<void> load({bool more = false}) async {
    final id = _mosqueId;
    if (id == null) return;
    state = state.copyWith(isLoading: true);
    final offset = more ? state.items.length : 0;
    final res = await repo.getCommunity(id, filter: state.filter.name, query: state.query.trim().isEmpty ? null : state.query.trim(), limit: _page, offset: offset);
    res.when(
      (list) => state = state.copyWith(
        isLoading: false,
        items: more ? [...state.items, ...list] : list,
        hasMore: list.length == _page,
      ),
      (error) {
        state = state.copyWith(isLoading: false);
        appEvents.send(ShowErrorEvent(error));
      },
    );
  }

  void setFilter(CommunityFilter f) {
    state = state.copyWith(filter: f);
    load();
  }

  void setQuery(String q) {
    state = state.copyWith(query: q);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), load);
  }

  Future<bool> removeMember(MosqueCommunityMember m) async {
    if (m.memberId == null) return false;
    final res = await repo.removeMember(m.memberId!);
    return res.when((_) {
      state = state.copyWith(items: state.items.where((x) => x.userId != m.userId).toList());
      unawaited(ref.read(myMosqueProvider.notifier).load(silent: true));
      return true;
    }, (error) {
      appEvents.send(ShowErrorEvent(error));
      return false;
    });
  }

  /// CSV of active members (devis B4) — built client-side.
  Future<String?> exportMembersCsv() async {
    final id = _mosqueId;
    if (id == null) return null;
    final res = await repo.getMembers(id);
    return res.when((members) {
      String esc(String? v) => '"${(v ?? '').replaceAll('"', '""')}"';
      final rows = [
        ['first_name', 'last_name', 'email', 'phone', 'birth_date', 'profession', 'volunteer', 'since'].join(','),
        for (final m in members)
          [
            esc(m.firstName), esc(m.lastName), esc(m.email), esc(m.phone),
            esc(m.birthDate.toIso8601String().substring(0, 10)), esc(m.profession),
            m.volunteer ? 'yes' : 'no', esc(m.createdAt.toIso8601String().substring(0, 10)),
          ].join(','),
      ];
      return rows.join('\n');
    }, (error) {
      appEvents.send(ShowErrorEvent(error));
      return null;
    });
  }
}
