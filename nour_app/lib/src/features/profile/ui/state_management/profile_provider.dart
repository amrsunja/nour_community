import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/locale/l10n.dart';
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
}
