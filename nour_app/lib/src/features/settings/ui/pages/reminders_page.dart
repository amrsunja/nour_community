import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';
import 'package:nour/src/features/notifications/ui/state_management/notifications_provider.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';

/// Settings › Reminders. A simple, single-screen list of the app's local
/// notification toggles (five prayers grouped, morning/evening adhkar, daily
/// ayah). Reads/persists through [notificationsProvider] — same presenter that
/// drives onboarding and the prayer-times page, so flipping a toggle here
/// (re)schedules the underlying notifications.
@RoutePage()
class RemindersPage extends HookConsumerWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final theme = UITheme.of(context);
    final settings = ref.watch(notificationsProvider.select((s) => s.settings));
    final presenter = ref.read(notificationsProvider.notifier);

    // A mosque account has no computed schedule: its reminders fire from the
    // times its admin published. Say so when nothing is published yet,
    // otherwise the toggles look broken.
    final isMosque = ref.watch(
        profileProvider.select((s) => s.profile?.isMosqueAccount ?? false));
    final mosqueHasTimes =
        ref.watch(myMosqueProvider.select((s) => s.hasPublishedPrayerTimes));
    final showMosqueHint = isMosque && !mosqueHasTimes;

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        presenter.initSettings();
      });
      return null;
    }, const []);

    // Prayer & adhkar reminders schedule against the user's location, so
    // enabling them is gated on location permission.
    Future<bool> locationGate(bool enable) async {
      if (!enable) return true; // Disabling never needs location.
      return presenter.ensureLocationForScheduling();
    }

    final items = <_ReminderItem>[
      _ReminderItem(
        icon: UIIconsToken.icons.notif,
        label: l10n.notifications_prayer_times_label,
        value: settings.allPrayers,
        onChange: presenter.setAllPrayers,
        onBeforeChange: locationGate,
      ),
      _ReminderItem(
        icon: UIIconsToken.icons.dhikr,
        label: l10n.notifications_morning_adhkar_label,
        value: settings.morningAdhkar,
        onChange: presenter.setMorningAdhkar,
        onBeforeChange: locationGate,
      ),
      _ReminderItem(
        icon: UIIconsToken.icons.dhikr,
        label: l10n.notifications_evening_adhkar_label,
        value: settings.eveningAdhkar,
        onChange: presenter.setEveningAdhkar,
        onBeforeChange: locationGate,
      ),
      _ReminderItem(
        icon: UIIconsToken.icons.tafsir,
        label: l10n.notifications_daily_ayah_label,
        value: settings.dailyAyah,
        onChange: presenter.setDailyAyah,
      ),
    ];

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UIAppBar(
            title: l10n.profile_reminders,
            onBack: () => context.router.maybePop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                kPageHorzPadding,
                12,
                kPageHorzPadding,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showMosqueHint) ...[
                    UICard(
                      padding: const EdgeInsets.all(14),
                      disableBorder: true,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline,
                              size: 20, color: UIColorsToken.textYellow),
                          const UISpace.horz(12),
                          Expanded(
                            child: Text(
                              l10n.mosque_reminders_no_times_hint,
                              style: theme.typo.inter.bodySmall
                                  .copyWith(color: UIColorsToken.textParagraph),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const UISpace.vert(12),
                  ],
                  for (var i = 0; i < items.length; i++)
                    Padding(
                      padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
                      child: UIAppearAnimation(
                        delay: Duration(milliseconds: 120 + i * 90),
                        offsetY: 16,
                        child: _ReminderCard(item: items[i]),
                      ),
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

class _ReminderItem {
  _ReminderItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChange,
    this.onBeforeChange,
  });

  final String icon;
  final String label;
  final bool value;
  final Future<bool> Function(bool) onChange;
  final Future<bool> Function(bool)? onBeforeChange;
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.item});

  final _ReminderItem item;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);

    return UIGradientCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: UIColorsToken.textYellow.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: UIIconsToken.toIcon(
              item.icon,
              color: UIColorsToken.textYellow,
              size: 20,
            ),
          ),
          const UISpace.horz(14),
          Expanded(
            child: Text(
              item.label,
              style: theme.typo.inter.title.copyWith(
                color: UIColorsToken.white,
              ),
            ),
          ),
          const UISpace.horz(8),
          UIToggle(
            checked: item.value,
            onBeforeChange: item.onBeforeChange,
            onCheck: (v) => item.onChange(v),
          ),
        ],
      ),
    );
  }
}
