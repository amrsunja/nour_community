import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';

import '../../data/models/mosque_onboarding_draft.dart';
import '../state_management/mosque_onboarding_provider.dart';
import '../state_management/mosque_onboarding_state.dart';
import '../widgets/mosque_onboarding_account_screen.dart';
import '../widgets/mosque_onboarding_country_screen.dart';
import '../widgets/mosque_onboarding_feature_screens.dart';
import '../widgets/mosque_onboarding_language_screen.dart';
import '../widgets/mosque_onboarding_register_screen.dart';
import '../widgets/mosque_onboarding_reminders_screen.dart';

/// Sessionless mosque-manager onboarding (Figma section "Onboarding mosquée").
/// Steps live in [MosqueOnboardingStep]; progress is persisted locally.
@RoutePage()
class MosqueOnboardingPage extends HookConsumerWidget {
  const MosqueOnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final presenter = ref.read(mosqueOnboardingProvider.notifier);
    final nav = ref.read(navigationServicesProvider);
    final state = ref.watch(mosqueOnboardingProvider);
    final pageController = usePageController(initialPage: state.pageIndex);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => presenter.restore());
      return null;
    }, const []);

    useEffect(() {
      if (!state.restored || !pageController.hasClients) return null;
      pageController.animateToPage(
        state.pageIndex,
        duration: Durations.medium2,
        curve: Curves.fastOutSlowIn,
      );
      return null;
    }, [state.pageIndex, state.restored]);

    final step = state.draft.step;
    final canSkip = step.index <= MosqueOnboardingStep.featureCalendar.index;
    final isFirst = step.index == 0;

    Future<void> onBack() async {
      if (isFirst) {
        // Leaving the flow keeps the draft (resume from Welcome).
        nav.toWelcome();
        return;
      }
      await presenter.previous();
    }

    Future<void> onStartOver() async {
      await presenter.reset();
      nav.toWelcome();
    }

    return UIGradientLinedScaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                UIIcon(
                  UIIconsToken.icons.chevronLeft,
                  color: UIColorsToken.yellow,
                  onTap: onBack,
                ),
                if (canSkip)
                  UITap(
                    onTap: presenter.skipFeatures,
                    child: Text(l10n.onboarding_skip, style: theme.typo.inter.bodyMedium),
                  )
                else
                  UITap(
                    onTap: onStartOver,
                    child: Text(
                      l10n.mosque_onboarding_start_over,
                      style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.textParagraph),
                    ),
                  ),
              ],
            ),
          ).animate(effects: [FadeEffect()]),
          Expanded(
            child: !state.restored
                ? const Center(child: UICircularProgressBar())
                : PageView(
                    controller: pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      MosqueOnboardingAnnouncementsScreen(),
                      MosqueOnboardingFundsScreen(),
                      MosqueOnboardingCalendarScreen(),
                      MosqueOnboardingCountryScreen(),
                      MosqueOnboardingLanguageScreen(),
                      MosqueOnboardingRemindersScreen(),
                      MosqueOnboardingRegisterScreen(),
                      MosqueOnboardingAccountScreen(),
                    ],
                  ),
          ),
          UISliderProgressBar(
            totalCount: MosqueOnboardingState.pageCount,
            currentIndex: state.pageIndex,
          ),
        ],
      ),
    ).animate(effects: [FadeEffect(duration: const Duration(milliseconds: 600))]);
  }
}
