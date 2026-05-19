import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/enums/level_type.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
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
}
