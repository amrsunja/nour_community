import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/core/utils/enums/gender_type.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';

class OnboardingScreen9 extends HookConsumerWidget {
  const OnboardingScreen9({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final navigationServices = ref.read(navigationServicesProvider);
    final l10n = ref.watch(l10nProvider);
    final profilePresenter = ref.read(profileProvider.notifier);
    final profile = ref.watch(profileProvider).profile;
    final isLoading = ref.watch(
      profileProvider.select((s) => s.isLoading),
    );

    final nameController = useTextEditingController(text: profile?.name ?? '');
    final selectedGender = useState<GenderType?>(profile?.gender);

    Future<void> onContinue() async {
      final name = nameController.text.trim();
      final gender = selectedGender.value;

      if (name.isNotEmpty && name != profile?.name) {
        final ok = await profilePresenter.updateName(name);
        if (!ok) return;
      }

      if (gender != null && gender != profile?.gender) {
        final ok = await profilePresenter.updateGender(gender);
        if (!ok) return;
      }

      final completed = await profilePresenter.markOnboardingCompleted();

      if (!completed) return ;

      final currentUserEmail = supabaseClient.auth.currentUser?.email;
      final needToSignIn = currentUserEmail == null || currentUserEmail.isEmpty;
      print(supabaseClient.auth.currentUser?.email);
      print(needToSignIn);

      navigationServices.toHome(openSignIn: needToSignIn);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const UISpace.vert(80),
                  UIAppearAnimation(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      l10n.onboarding_screen_9_title,
                      textAlign: TextAlign.center,
                      style: theme.typo.inter.largeTitle.copyWith(
                        color: UIColorsToken.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  UIAppearAnimation(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      l10n.onboarding_screen_9_description,
                      textAlign: TextAlign.center,
                      style: theme.typo.inter.bodyLarge.copyWith(
                        color: UIColorsToken.textParagraph,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  UIAppearAnimation(
                    delay: const Duration(milliseconds: 320),
                    offsetY: 18,
                    child: UIInputField(
                      controller: nameController,
                      labelText: l10n.onboarding_screen_9_name_label,
                      hintText: l10n.onboarding_screen_9_name_hint,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                  const SizedBox(height: 28),
                  UIAppearAnimation(
                    delay: const Duration(milliseconds: 460),
                    offsetY: 18,
                    child: Text(
                      l10n.onboarding_screen_9_gender_question,
                      style: theme.typo.inter.title.copyWith(
                        color: UIColorsToken.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  UIAppearAnimation(
                    delay: const Duration(milliseconds: 540),
                    offsetY: 18,
                    child: Row(
                      children: [
                        Expanded(
                          child: _GenderChip(
                            label: l10n.onboarding_screen_9_gender_male,
                            selected: selectedGender.value == GenderType.male,
                            onTap: () => selectedGender.value = GenderType.male,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _GenderChip(
                            label: l10n.onboarding_screen_9_gender_female,
                            selected: selectedGender.value == GenderType.female,
                            onTap: () => selectedGender.value = GenderType.female,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _GenderChip(
                            label: l10n.onboarding_screen_9_gender_skip,
                            selected: selectedGender.value == GenderType.undefined,
                            onTap: () => selectedGender.value = GenderType.undefined,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          UIAppearAnimation(
            delay: const Duration(milliseconds: 800),
            offsetY: 16,
            child: UIButton.primary(
              label: l10n.common_continue,
              fullWidth: true,
              isBusy: isLoading,
              onTap: onContinue,
            ),
          ),
          const UISpace.vert(10),
        ],
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final accent = UIColorsToken.textYellow;

    return UITap(
      onTap: onTap,
      child: UIGradientCard(
        selected: selected,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          style: theme.typo.inter.title.copyWith(
            color: selected ? accent : UIColorsToken.white,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
