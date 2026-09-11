import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/features/onboarding/domain/onboarding_step.dart';
import 'package:nour/src/features/onboarding/ui/state_management/onboarding_provider.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';

import '../widgets/onboarding_screen_2.dart';
import '../widgets/onboarding_screen_3.dart';
import '../widgets/onboarding_screen_4.dart';
import '../widgets/onboarding_screen_5.dart';
import '../widgets/onboarding_screen_6.dart';
import '../widgets/onboarding_screen_7.dart';
import '../widgets/onboarding_screen_8.dart';
import '../widgets/onboarding_screen_9.dart';
import '../widgets/onboarding_screen_mosque.dart';

@RoutePage()
class OnboardingPage extends HookConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final provider = ref.read(onboardingProvider.notifier);
    final nav = ref.read(navigationServicesProvider);
    final profile = ref.watch(profileProvider).profile;

    // Persisted step. Anything below [OnboardingStep.first] means the profile
    // type was never chosen (fresh account, or a profile written by an older
    // app version) → send the user back to the profile-type screen.
    final step = profile?.lastOnboardingScreen ?? 0;
    final needsProfileType = step < OnboardingStep.first;
    final currentPage = OnboardingStep.pageIndex(step);
    final pageController = usePageController(initialPage: currentPage);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (needsProfileType) {
          nav.toProfileType(resetStack: true);
          return;
        }
        if (!pageController.hasClients) return;
        pageController.animateToPage(
          currentPage,
          duration: Durations.medium2,
          curve: Curves.fastOutSlowIn
        );
      });

      return null;
    }, [profile?.lastOnboardingScreen]);

    final isFirst = step <= OnboardingStep.first;
    final canSkip = step < OnboardingStep.last;

    void onBack() {
      // First step → back to the profile-type screen (session is kept; picking
      // "worshipper" again simply resumes here).
      if (isFirst) {
        nav.toProfileType(resetStack: true);
        return;
      }
      provider.goToPreviousPage();
    }

    return UIGradientLinedScaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding, vertical: 4),
            child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  UIIcon(
                    UIIconsToken.icons.chevronLeft,
                    color: UIColorsToken.yellow,
                    onTap: onBack,
                  ),

                  AnimatedOpacity(
                    opacity: canSkip ? 1 : 0,
                    duration: Durations.medium2,
                    child: UITap(
                      onTap: () async {
                        if (!canSkip) return ;

                        provider.changePage(OnboardingStep.last);
                      },
                      child: Text(
                        l10n.onboarding_skip,
                        style: theme.typo.inter.bodyMedium,
                      ),
                    ),
                  )
                ],
              ),
          ).animate(effects: [FadeEffect()]),
          Expanded(
            child: PageView(
              controller: pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                OnboardingScreen2(),
                OnboardingScreen3(),
                OnboardingScreen4(),
                OnboardingScreen5(),
                OnboardingScreenMosque(),
                OnboardingScreen6(),
                OnboardingScreen7(),
                OnboardingScreen8(),
                OnboardingScreen9(),
              ],
            ),
          ),
          UISliderProgressBar(
            totalCount: OnboardingStep.pageCount,
            currentIndex: currentPage
          ),
        ],
      ),
    ).animate(effects: [FadeEffect(duration: Duration(milliseconds: 600))]);
  }
}
