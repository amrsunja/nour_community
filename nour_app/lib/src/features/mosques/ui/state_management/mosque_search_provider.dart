import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/geolocator/geolocator_tools.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import '../../data/models/mosque_search_item_model.dart';
import '../../data/mosque_repo.dart';

class MosqueSearchState extends Equatable {
  final bool isLoading;
  final bool hasLocation;
  final double? lat;
  final double? lng;
  final String query;
  final List<MosqueSearchItemModel> results;
  final int? highlightedId;

  const MosqueSearchState({
    this.isLoading = false,
    this.hasLocation = false,
    this.lat,
    this.lng,
    this.query = '',
    this.results = const [],
    this.highlightedId,
  });

  MosqueSearchState copyWith({
    bool? isLoading,
    bool? hasLocation,
    double? lat,
    double? lng,
    String? query,
    List<MosqueSearchItemModel>? results,
    int? highlightedId,
    bool clearHighlight = false,
  }) =>
      MosqueSearchState(
        isLoading: isLoading ?? this.isLoading,
        hasLocation: hasLocation ?? this.hasLocation,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        query: query ?? this.query,
        results: results ?? this.results,
        highlightedId: clearHighlight ? null : (highlightedId ?? this.highlightedId),
      );

  @override
  List<Object?> get props => [isLoading, hasLocation, lat, lng, query, results, highlightedId];
}

final mosqueSearchProvider = StateNotifierProvider.autoDispose<MosqueSearchPresenter, MosqueSearchState>((ref) {
  return MosqueSearchPresenter(repo: ref.read(mosqueRepoProvider), appEvents: ref.read(appEventProvider));
});

/// Search screen + onboarding "Select a mosque" step.
class MosqueSearchPresenter extends Presenter<MosqueSearchState> {
  final MosqueRepo repo;
  final AppEvents appEvents;
  Timer? _debounce;
  int _seq = 0;

  MosqueSearchPresenter({required this.repo, required this.appEvents}) : super(const MosqueSearchState());

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> init({bool openSettingsIfBlocked = false}) async {
    state = state.copyWith(isLoading: true);
    try {
      final pos = await GeolocatorTools.currentOrCachedPosition(openSettingsIfBlocked: openSettingsIfBlocked);
      state = state.copyWith(hasLocation: true, lat: pos.latitude, lng: pos.longitude);
    } catch (e) {
      talker.info('mosque search without location: $e');
      state = state.copyWith(hasLocation: false);
    }
    await _run();
  }

  Future<void> locate() => init(openSettingsIfBlocked: true);

  void setQuery(String q) {
    state = state.copyWith(query: q);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _run);
  }

  void highlight(int? id) => state = state.copyWith(highlightedId: id, clearHighlight: id == null);

  Future<void> _run() async {
    final seq = ++_seq;
    state = state.copyWith(isLoading: true);
    final q = state.query.trim();
    final res = await repo.search(
      query: q.isEmpty ? null : q,
      lat: state.hasLocation ? state.lat : null,
      lng: state.hasLocation ? state.lng : null,
      // Text search is global; "near you" is radius-bound.
      radiusKm: q.isEmpty && state.hasLocation ? 60 : null,
    );
    if (seq != _seq || !mounted) return;
    res.when(
      (list) => state = state.copyWith(isLoading: false, results: list),
      (error) {
        state = state.copyWith(isLoading: false);
        appEvents.send(ShowErrorEvent(error));
      },
    );
  }
}
