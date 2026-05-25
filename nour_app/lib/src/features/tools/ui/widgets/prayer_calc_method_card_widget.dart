import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Green pill card at the top of the Prayer times page showing the active
/// calculation method. Tapping it (or the edit icon) opens the method sheet.
class PrayerCalcMethodCardWidget extends StatelessWidget {
  const PrayerCalcMethodCardWidget({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);

    return UICard(
      onTap: onTap,
      disableBorder: true,
      borderRadius: 10,
      shadows: [],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: const [Color(0xff404F3B), Color(0xff2C3427)],
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typo.inter.title,
            ),
          ),
          const SizedBox(width: 12),
          UIIcon(
            UIIconsToken.icons.squarePen,
            size: 24,
          )
        ],
      ),
    );
  }
}
