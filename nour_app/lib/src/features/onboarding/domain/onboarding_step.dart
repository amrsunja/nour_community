/// Frontend index of every worshipper onboarding screen. The value is what
/// gets persisted in `profiles.last_onboarding_screen`.
///
/// Indices 0 and 1 are routes ([WelcomePage], [ProfileTypePage]) and are NOT
/// part of the onboarding [PageView]; the PageView starts at [first].
/// Older app versions stored 0..9 for the same screens shifted by one —
/// anything `< first` is treated as "profile type not chosen yet".
abstract final class OnboardingStep {
  static const int welcome = 0;
  static const int profileType = 1;
  static const int tools = 2;        // OnboardingScreen2
  static const int screen3 = 3;
  static const int screen4 = 4;
  static const int screen5 = 5;
  static const int mosque = 6;       // OnboardingScreenMosque
  static const int screen6 = 7;
  static const int screen7 = 8;
  static const int screen8 = 9;
  static const int screen9 = 10;

  static const int first = tools;
  static const int last = screen9;

  /// Number of screens inside the PageView.
  static const int pageCount = last - first + 1;

  /// PageView child index for a persisted step.
  static int pageIndex(int step) => (step - first).clamp(0, pageCount - 1);
}
