import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';

import '../state_management/notifications_provider.dart';

/// Vertical list of local-notification toggle cards.
/// Reads the current values from [notificationsProvider] and persists each
/// flip through the presenter (which writes to SQLite).
class NotificationsSettingsWidget extends HookConsumerWidget {
  const NotificationsSettingsWidget({
    super.key,
    this.spacing = 12,
    this.animateEntry = false,
    this.entryBaseDelay = const Duration(milliseconds: 300),
  });

  final double spacing;
  final bool animateEntry;
  final Duration entryBaseDelay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(notificationsProvider.select((s) => s.settings));
    final presenter = ref.read(notificationsProvider.notifier);

    final items = <_NotificationItem>[
      _NotificationItem(
        label: 'Prayer times (5 prayers)',
        value: settings.prayers,
        onChange: presenter.setPrayers,
      ),
      _NotificationItem(
        label: 'Morning adkar reminder',
        value: settings.morningAdhkar,
        onChange: presenter.setMorningAdhkar,
      ),
      _NotificationItem(
        label: 'Evening adkar reminder',
        value: settings.eveningAdhkar,
        onChange: presenter.setEveningAdhkar,
      ),
      _NotificationItem(
        label: 'Daily ayah notification',
        value: settings.dailyAyah,
        onChange: presenter.setDailyAyah,
      ),
    ];


    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : spacing),
            child: animateEntry
              ? UIAppearAnimation(
                  delay: entryBaseDelay + Duration(milliseconds: i * 100),
                  offsetY: 18,
                  child: _NotificationCard(item: items[i]),
                )
              : _NotificationCard(item: items[i]),
          ),
      ],
    );
  }
}

class _NotificationItem {
  _NotificationItem({
    required this.label,
    required this.value,
    required this.onChange,
  });

  final String label;
  final bool value;
  final Future<bool> Function(bool) onChange;
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);

    return UIGradientCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.label,
              style: theme.typo.inter.title.copyWith(
                color: UIColorsToken.white,
              ),
            ),
          ),
          UIToggle(
            checked: item.value,
            onCheck: (v) => item.onChange(v),
          ),
        ],
      ),
    );
  }
}
