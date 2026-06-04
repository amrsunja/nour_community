import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/core/utils/enums/gender_type.dart';
import 'package:nour/src/core/utils/enums/level_type.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';

/// Profile → Account → Account information.
///
/// Lets the user edit their display name, gender, daily practice time and
/// level in one place, then persist every changed field at once via the
/// primary Save button. Mirrors the field/card patterns of onboarding
/// screens 4 (level), 5 (daily practice time) and 9 (name + gender).
@RoutePage()
class AccountInformationPage extends HookConsumerWidget {
  const AccountInformationPage({super.key});

  static const List<({int value, String display})> _timeOptions = [
    (value: 5, display: '5'),
    (value: 10, display: '10'),
    (value: 20, display: '20'),
    (value: 30, display: '30+'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final presenter = ref.read(profileProvider.notifier);
    final profile = ref.watch(profileProvider.select((s) => s.profile));
    final isLoading = ref.watch(profileProvider.select((s) => s.isLoading));

    final nameController = useTextEditingController(text: profile?.name ?? '');
    final selectedGender = useState<GenderType?>(profile?.gender);
    final selectedTime = useState<int?>(profile?.dailyPracticeTime);
    final selectedLevel = useState<LevelType?>(profile?.level);

    Future<void> onSave() async {
      final name = nameController.text.trim();

      if (name.isNotEmpty && name != profile?.name) {
        if (!await presenter.updateName(name)) return;
      }

      final gender = selectedGender.value;
      if (gender != null && gender != profile?.gender) {
        if (!await presenter.updateGender(gender)) return;
      }

      final time = selectedTime.value;
      if (time != null && time != profile?.dailyPracticeTime) {
        if (!await presenter.updateDailyPracticeTime(time)) return;
        profile?.dailyPracticeTime = time;
      }

      final level = selectedLevel.value;
      if (level != null && level != profile?.level) {
        if (!await presenter.updateLevel(level)) return;
      }

      if (context.mounted) context.router.maybePop();
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UIAppBar(
            title: l10n.account_information_title,
            onBack: () => context.router.maybePop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                kPageHorzPadding,
                16,
                kPageHorzPadding,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---------- Name ----------
                  UIInputField(
                    controller: nameController,
                    labelText: l10n.account_information_name_label,
                    hintText: l10n.account_information_name_hint,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.done,
                  ),
                  const UISpace.vert(28),

                  // ---------- Gender ----------
                  Text(
                    l10n.account_information_gender_question,
                    style: theme.typo.inter.title
                        .copyWith(color: UIColorsToken.white),
                  ),
                  const UISpace.vert(12),
                  Row(
                    children: [
                      Expanded(
                        child: _GenderChip(
                          label: l10n.account_information_gender_male,
                          selected: selectedGender.value == GenderType.male,
                          onTap: () => selectedGender.value = GenderType.male,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GenderChip(
                          label: l10n.account_information_gender_female,
                          selected: selectedGender.value == GenderType.female,
                          onTap: () => selectedGender.value = GenderType.female,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GenderChip(
                          label: l10n.account_information_gender_skip,
                          selected:
                              selectedGender.value == GenderType.undefined,
                          onTap: () =>
                              selectedGender.value = GenderType.undefined,
                        ),
                      ),
                    ],
                  ),
                  const UISpace.vert(28),

                  // ---------- Daily practice time ----------
                  Text(
                    l10n.account_information_daily_practice_title,
                    style: theme.typo.inter.title
                        .copyWith(color: UIColorsToken.white),
                  ),
                  const UISpace.vert(12),
                  _TimeGrid(
                    options: _timeOptions,
                    selectedValue: selectedTime.value,
                    unitLabel: l10n.account_information_minutes_per_day,
                    onSelect: (v) => selectedTime.value = v,
                  ),
                  const UISpace.vert(28),

                  // ---------- Level ----------
                  Text(
                    l10n.account_information_level_title,
                    style: theme.typo.inter.title
                        .copyWith(color: UIColorsToken.white),
                  ),
                  const UISpace.vert(12),
                  ...LevelType.values.indexed.map((entry) {
                    final i = entry.$1;
                    final level = entry.$2;
                    return Padding(
                      padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
                      child: UILevelCard(
                        title: level.title(l10n),
                        description: level.description(l10n),
                        selected: selectedLevel.value == level,
                        onTap: () => selectedLevel.value = level,
                      ),
                    );
                  }),
                  const UISpace.vert(32),

                  // ---------- Save ----------
                  UIButton.primary(
                    label: l10n.common_save,
                    fullWidth: true,
                    isBusy: isLoading,
                    onTap: onSave,
                  ),
                ],
              ),
            ),
          ),
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

class _TimeGrid extends StatelessWidget {
  const _TimeGrid({
    required this.options,
    required this.selectedValue,
    required this.unitLabel,
    required this.onSelect,
  });

  final List<({int value, String display})> options;
  final int? selectedValue;
  final String unitLabel;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row < options.length; row += 2)
          Padding(
            padding: EdgeInsets.only(top: row == 0 ? 0 : 12),
            child: Row(
              children: [
                Expanded(
                  child: _TimeCard(
                    option: options[row],
                    selected: selectedValue == options[row].value,
                    unitLabel: unitLabel,
                    onTap: () => onSelect(options[row].value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeCard(
                    option: options[row + 1],
                    selected: selectedValue == options[row + 1].value,
                    unitLabel: unitLabel,
                    onTap: () => onSelect(options[row + 1].value),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.option,
    required this.selected,
    required this.unitLabel,
    required this.onTap,
  });

  final ({int value, String display}) option;
  final bool selected;
  final String unitLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final accent = UIColorsToken.textYellow;

    return UITap(
      onTap: onTap,
      child: UISelecteableCard(
        selected: selected,
        child: SizedBox(
          height: 110,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: theme.typo.inter.hero.copyWith(
                  color: selected ? accent : UIColorsToken.white,
                  fontWeight: FontWeight.w700,
                ),
                child: UIGlowingBlock(
                  shadow: UIShadowToken.texts,
                  child: Text(option.display),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                unitLabel,
                style: theme.typo.inter.bodySmall.copyWith(
                  color: selected ? accent : UIColorsToken.textParagraph,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
