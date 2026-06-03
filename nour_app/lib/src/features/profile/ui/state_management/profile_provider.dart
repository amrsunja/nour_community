import 'dart:async';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/enums/gender_type.dart';
import 'package:nour/src/core/utils/enums/language_type.dart';
import 'package:nour/src/core/utils/enums/level_type.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_state.dart';

import '../../data/profile_repo.dart';


final profileProvider = StateNotifierProvider<ProfilePresenter, ProfileState>((ref) {
  return ProfilePresenter(
    repo: ref.read(profileRepoProvider),
    appEvents: ref.read(appEventProvider),
    locale: ref.read(l10nProvider),
  );
});

class ProfilePresenter extends Presenter<ProfileState> {
  final ProfileRepo repo;
  final AppEvents appEvents;
  final AppLocale locale;

  ProfilePresenter({
    required this.repo,
    required this.appEvents,
    required this.locale,
  }) : super(ProfileState(
      isLoading: false,
      profile: null
    ));

  StreamSubscription<dynamic>? _profileSub;

  Future<bool> initProfile() async {
    final response = await repo.getProfile();

    return response.when(
      (s) async {
        state = state.copyWith(profile: s);
        return true;
      },
      (error) {
        appEvents.send(ShowErrorEvent(error));
        return false;
      }
    );
  }

  /// Subscribes to the live profile row so `current_streak` / `earned_ajr_count`
  /// reflect Supabase updates the instant a trigger writes them (idempotent —
  /// safe to call more than once). The last good state is preserved on error.
  void subscribeRealtime() {
    _profileSub?.cancel();
    _profileSub = repo.watchProfile().listen(
      (profile) => state = state.copyWith(profile: profile),
      onError: (Object e) => talker.error('profile realtime: $e'),
    );
  }

  @override
  void dispose() {
    _profileSub?.cancel();
    super.dispose();
  }

  /// Uploads [file] as the user's new avatar. Toggles [AvatarStatus.uploading]
  /// so the UI can show progress, then writes the returned URL onto the live
  /// profile (Realtime will echo the same change). Returns true on success.
  Future<bool> uploadAvatar(File file) async {
    state = state.copyWith(avatarStatus: AvatarStatus.uploading);
    final response = await repo.uploadAvatar(file);

    return response.when(
      (url) {
        state.profile?.avatar = url;
        state = state.copyWith(avatarStatus: AvatarStatus.idle);
        return true;
      },
      (error) {
        state = state.copyWith(avatarStatus: AvatarStatus.idle);
        appEvents.send(ShowErrorEvent(error));
        return false;
      },
    );
  }

  /// Removes the user's avatar from storage and clears it on the profile.
  Future<bool> deleteAvatar() async {
    state = state.copyWith(avatarStatus: AvatarStatus.deleting);
    final response = await repo.deleteAvatar();

    return response.when(
      (_) {
        state.profile?.avatar = null;
        state = state.copyWith(avatarStatus: AvatarStatus.idle);
        return true;
      },
      (error) {
        state = state.copyWith(avatarStatus: AvatarStatus.idle);
        appEvents.send(ShowErrorEvent(error));
        return false;
      },
    );
  }

  /// Persists [minutes] of daily practice to the user's Supabase profile.
  /// Returns true on success so the caller can decide what to do next.
  Future<bool> updateDailyPracticeTime(int minutes) async {
    state = state.copyWith(isLoading: true);
    final response = await repo.updateDailyPracticeTime(minutes);

    return response.when(
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
      (error) {
        state = state.copyWith(isLoading: false);
        appEvents.send(ShowErrorEvent(error));
        return false;
      },
    );
  }

  /// Persists the chosen [level] to the user's Supabase profile.
  /// Returns true on success so the caller can advance the page.
  Future<bool> updateLevel(LevelType level) async {
    state = state.copyWith(isLoading: true);
    final response = await repo.updateLevel(level);

    return response.when(
      (_) {
        state.profile?.level = level;
        state = state.copyWith(isLoading: false);
        return true;
      },
      (error) {
        state = state.copyWith(isLoading: false);
        appEvents.send(ShowErrorEvent(error));
        return false;
      },
    );
  }

  /// Persists the user's display [name] to the Supabase profile.
  Future<bool> updateName(String name) async {
    state = state.copyWith(isLoading: true);
    final response = await repo.updateName(name);

    return response.when(
      (_) {
        state.profile?.name = name;
        state = state.copyWith(isLoading: false);
        return true;
      },
      (error) {
        state = state.copyWith(isLoading: false);
        appEvents.send(ShowErrorEvent(error));
        return false;
      },
    );
  }

  /// Persists the user's [gender] to the Supabase profile.
  Future<bool> updateGender(GenderType gender) async {
    state = state.copyWith(isLoading: true);
    final response = await repo.updateGender(gender);

    return response.when(
      (_) {
        state.profile?.gender = gender;
        state = state.copyWith(isLoading: false);
        return true;
      },
      (error) {
        state = state.copyWith(isLoading: false);
        appEvents.send(ShowErrorEvent(error));
        return false;
      },
    );
  }

  /// Persists the user's preferred [lang] to the Supabase profile.
  Future<bool> updateLanguage(LanguageType lang) async {
    state = state.copyWith(isLoading: true);
    final response = await repo.updateLanguage(lang);

    return response.when(
      (_) {
        state.profile?.language = lang;
        state = state.copyWith(isLoading: false);
        return true;
      },
      (error) {
        state = state.copyWith(isLoading: false);
        appEvents.send(ShowErrorEvent(error));
        return false;
      },
    );
  }

  /// Persists the last onboarding [page] index so users can resume later.
  Future<bool> updateLastOnboardingScreen(int page) async {
    state = state.copyWith(isLoading: true);
    final response = await repo.updateLastOnboardingScreen(page);

    return response.when(
      (_) {
        state.profile?.lastOnboardingScreen = page;
        state = state.copyWith(isLoading: false);
        return true;
      },
      (error) {
        state = state.copyWith(isLoading: false);
        appEvents.send(ShowErrorEvent(error));
        return false;
      },
    );
  }

  /// Flags the user's onboarding as completed in the Supabase profile.
  Future<bool> markOnboardingCompleted() async {
    state = state.copyWith(isLoading: true);
    final response = await repo.markOnboardingCompleted();

    return response.when(
      (_) {
        state.profile?.onboardingCompleted = true;
        state = state.copyWith(isLoading: false);
        return true;
      },
      (error) {
        state = state.copyWith(isLoading: false);
        appEvents.send(ShowErrorEvent(error));
        return false;
      },
    );
  }
}
