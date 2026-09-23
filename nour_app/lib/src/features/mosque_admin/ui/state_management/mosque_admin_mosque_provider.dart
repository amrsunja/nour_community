import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/features/mosques/data/datasources/mosque_admin_remote_datasource.dart';
import 'package:nour/src/features/mosques/data/models/mosque_enums.dart';
import 'package:nour/src/features/mosques/data/models/mosque_imam_model.dart';
import 'package:nour/src/features/mosques/data/models/mosque_model.dart';
import 'package:nour/src/features/mosques/data/models/mosque_post_model.dart';
import 'package:nour/src/features/mosques/data/mosque_repo.dart';
import 'package:nour/src/features/mosques/ui/state_management/mosque_profile_provider.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';

class MosqueAdminMosqueState extends Equatable {
  final bool isSaving;
  final BroadcastQuota? quota;

  const MosqueAdminMosqueState({this.isSaving = false, this.quota});

  MosqueAdminMosqueState copyWith({bool? isSaving, BroadcastQuota? quota}) =>
      MosqueAdminMosqueState(isSaving: isSaving ?? this.isSaving, quota: quota ?? this.quota);

  @override
  List<Object?> get props => [isSaving, quota];
}

final mosqueAdminMosqueProvider =
    StateNotifierProvider<MosqueAdminMosquePresenter, MosqueAdminMosqueState>((ref) {
  return MosqueAdminMosquePresenter(repo: ref.read(mosqueRepoProvider), appEvents: ref.read(appEventProvider), ref: ref);
});

/// Write side of the admin "Mosque" tab: profile fields, services, imams,
/// media uploads, post moderation, broadcasts. Reads come from
/// [mosqueProfileProvider] (same widgets as the public profile).
class MosqueAdminMosquePresenter extends Presenter<MosqueAdminMosqueState> {
  final MosqueRepo repo;
  final AppEvents appEvents;
  final Ref ref;

  MosqueAdminMosquePresenter({required this.repo, required this.appEvents, required this.ref})
      : super(const MosqueAdminMosqueState());

  MosqueModel? get _mosque => ref.read(myMosqueProvider).mosque;

  void _apply(MosqueModel m) {
    ref.read(myMosqueProvider.notifier).setMosque(m);
    ref.read(mosqueProfileProvider(m.id).notifier).setMosque(m);
  }

  Future<bool> saveMosque(MosqueModel updated) async {
    state = state.copyWith(isSaving: true);
    final res = await repo.updateProfile(updated);
    return res.when((m) {
      state = state.copyWith(isSaving: false);
      _apply(m);
      return true;
    }, (error) {
      state = state.copyWith(isSaving: false);
      appEvents.send(ShowErrorEvent(error));
      return false;
    });
  }

  Future<bool> toggleService(MosqueService s) async {
    final m = _mosque;
    if (m == null) return false;
    final next = m.services.contains(s) ? m.services.where((x) => x != s).toList() : [...m.services, s];
    _apply(m.copyWith(services: next)); // optimistic
    final ok = await saveMosque(m.copyWith(services: next));
    if (!ok) _apply(m);
    return ok;
  }

  Future<bool> setCapacity({int? total, int? men, int? women}) async {
    final m = _mosque;
    if (m == null) return false;
    return saveMosque(m.copyWith(capacityTotal: total ?? m.capacityTotal, capacityMen: men ?? m.capacityMen, capacityWomen: women ?? m.capacityWomen));
  }

  Future<bool> setFounded(int? year) async {
    final m = _mosque;
    if (m == null) return false;
    return saveMosque(m.copyWith(foundedYear: year));
  }

  Future<bool> setLanguages(List<String> codes) async {
    final m = _mosque;
    if (m == null) return false;
    return saveMosque(m.copyWith(khutbahLanguages: codes));
  }

  Future<bool> upsertImam(MosqueImamModel imam) async {
    final m = _mosque;
    if (m == null) return false;
    final res = await repo.upsertImam(imam);
    return res.when((saved) {
      final list = [...m.imams.where((i) => i.id != saved.id), saved]..sort((a, b) => a.position.compareTo(b.position));
      _apply(m.copyWith(imams: list));
      return true;
    }, (error) {
      appEvents.send(ShowErrorEvent(error));
      return false;
    });
  }

  Future<bool> deleteImam(int id) async {
    final m = _mosque;
    if (m == null) return false;
    final res = await repo.deleteImam(id);
    return res.when((_) {
      _apply(m.copyWith(imams: m.imams.where((i) => i.id != id).toList()));
      return true;
    }, (error) {
      appEvents.send(ShowErrorEvent(error));
      return false;
    });
  }

  /// Uploads a picture to `mosque-media/<id>/<folder>/` and returns its URL.
  Future<String?> upload(File file, {required String folder}) async {
    final m = _mosque;
    if (m == null) return null;
    final res = await repo.uploadMedia(mosqueId: m.id, folder: folder, file: file);
    return res.when((url) => url, (error) {
      appEvents.send(ShowErrorEvent(error));
      return null;
    });
  }

  // ── Posts ─────────────────────────────────────────────────────────────────

  Future<void> loadQuota() async {
    final m = _mosque;
    if (m == null) return;
    final res = await repo.getBroadcastQuota(m.id);
    res.when((q) => state = state.copyWith(quota: q), (_) {});
  }

  Future<int?> notifyPost(MosquePostModel post) async {
    final res = await repo.notifyFollowers(mosqueId: post.mosqueId, postId: post.id);
    return await res.when((n) async {
      await ref.read(mosqueProfileProvider(post.mosqueId).notifier).loadPosts();
      await loadQuota();
      return n;
    }, (error) async {
      appEvents.send(ShowErrorEvent(error));
      return null;
    });
  }

  Future<bool> archivePost(MosquePostModel post) async {
    final res = await repo.archivePost(post.id);
    return res.when((_) {
      ref.read(mosqueProfileProvider(post.mosqueId).notifier).loadPosts();
      return true;
    }, (error) {
      appEvents.send(ShowErrorEvent(error));
      return false;
    });
  }

  Future<bool> deletePost(MosquePostModel post) async {
    final res = await repo.deletePost(post.id);
    return res.when((_) {
      ref.read(mosqueProfileProvider(post.mosqueId).notifier).loadPosts();
      return true;
    }, (error) {
      appEvents.send(ShowErrorEvent(error));
      return false;
    });
  }
}
