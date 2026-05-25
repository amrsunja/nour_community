import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// A single "Coming up" row on the Hijri calendar page: the event name with a
/// relative "In N days" subtitle. The soonest event is [highlighted].
class HijriEventCardWidget extends StatelessWidget {
  const HijriEventCardWidget({
    super.key,
    required this.name,
    required this.relative,
    this.highlighted = false,
  });

  final String name;
  final String relative;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: highlighted ? const Color(0xff252219) : UIColorsToken.black80,
        border: Border.all(
          color: highlighted ? UIColorsToken.textYellow : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.typo.inter.title.copyWith(
                  color: UIColorsToken.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                relative,
                style: theme.typo.inter.bodyMedium.copyWith(
                  color: UIColorsToken.textYellow.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
