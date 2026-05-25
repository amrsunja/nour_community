import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Footer card on the Prayer times page showing the secondary times:
/// Chourouk (sunrise) on the left and the Jumu'a time on the right.
class PrayerExtraTimesWidget extends StatelessWidget {
  const PrayerExtraTimesWidget({
    super.key,
    required this.chouroukLabel,
    required this.chouroukTime,
    required this.jumuaLabel,
    required this.jumuaTime,
  });

  final String chouroukLabel;
  final String chouroukTime;
  final String jumuaLabel;
  final String jumuaTime;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final style = theme.typo.inter.title.copyWith(
      color: UIColorsToken.textYellow,
    );

    return UICard(
      disableBorder: true,
      borderRadius: 10,
      color: UIColorsToken.yellow.withValues(alpha: 0.2),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Center(child: Text('$chouroukLabel $chouroukTime', style: style)),
          ),
          Container(
            width: 1,
            height: 22,
            color: UIColorsToken.textYellow.withValues(alpha: 0.5),
          ),
          Expanded(
            child: Center(
              child: Text(
                '$jumuaLabel $jumuaTime',
                textAlign: TextAlign.center,
                style: style,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
