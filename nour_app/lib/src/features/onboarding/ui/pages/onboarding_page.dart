import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/routing/app_router.gr.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/onboarding/ui/state_management/onboarding_provider.dart';
import 'package:nour/src/features/onboarding/ui/widgets/onboarding_screen_1.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';

import '../widgets/onboarding_screen_2.dart';
import '../widgets/onboarding_screen_3.dart';
import '../widgets/onboarding_screen_4.dart';
import '../widgets/onboarding_screen_5.dart';
import '../widgets/onboarding_screen_6.dart';
import '../widgets/onboarding_screen_7.dart';
import '../widgets/onboarding_screen_8.dart';
import '../widgets/onboarding_screen_9.dart';

@RoutePage()
class OnboardingPage extends HookConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final provider = ref.read(onboardingProvider.notifier);
    final profile = ref.watch(profileProvider).profile;

    int currentPage = profile?.lastOnboardingScreen ?? 0;
    final pageController = usePageController(initialPage: currentPage);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        pageController.animateToPage(
          currentPage,
          duration: Durations.medium2,
          curve: Curves.fastOutSlowIn
        );
      });

      return null;
    }, [profile?.lastOnboardingScreen]);



    final showBars = currentPage > 0;
    final canSkip = currentPage < 8;

    return UIGradientLinedScaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          AnimatedOpacity(
            opacity: showBars  ? 1 : 0,
            duration: Durations.medium2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding, vertical: 4),
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  UIIcon(
                    UIIconsToken.icons.chevronLeft,
                    color: UIColorsToken.yellow,
                    onTap: () {
                      if (!showBars) return ;

                      provider.goToPreviousPage();
                    },
                  ),

                  AnimatedOpacity(
                    opacity: canSkip ? 1 : 0,
                    duration: Durations.medium2,
                    child: UITap(
                      onTap: () async {
                        if (!showBars) return ;
                    
                        provider.changePage(8);
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
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                OnboardingScreen1(),
                OnboardingScreen2(),
                OnboardingScreen3(),
                OnboardingScreen4(),
                OnboardingScreen5(),
                OnboardingScreen6(),
                OnboardingScreen7(),
                OnboardingScreen8(),
                OnboardingScreen9(),
              ],
            ),
          ),
          AnimatedOpacity(
            opacity: showBars ? 1 : 0,
            duration: Durations.medium2,
            child: UISliderProgressBar(
              totalCount: 9,
              currentIndex: currentPage
            ),
          )
        ],
      ),
    ).animate(effects: [FadeEffect(duration: Duration(milliseconds: 600))]);
  }
}
