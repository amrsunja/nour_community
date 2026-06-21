import 'package:flutter/widgets.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Compact streak pill — a flame glyph followed by a `current/total` count.
///
/// ```dart
/// UIStreakCard(current: 2, total: 7)
/// ```
class UIStreakCard extends StatelessWidget {
  const UIStreakCard({
    super.key,
    required this.current,
    this.total = 7,
    this.onTap,
  });

  final int current;
  final int total;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;

    return UITap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: UIColorsToken.bgSecondaryGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30,
              child: Image.asset(Assets.images.illustration10.path)
            ),
            const UISpace.horz(6),
            Text(
              '$current/$total',
              style: typo.inter.title.copyWith(color: UIColorsToken.textYellow),
            ),
          ],
        ),
      ),
    );
  }
}
