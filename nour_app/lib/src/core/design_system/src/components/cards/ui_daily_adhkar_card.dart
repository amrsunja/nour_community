import 'package:flutter/material.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Daily dhikr goal card: a title with a percentage, an animated
/// [UIProgressLine], a subtitle, and a circular "start" action button.
///
/// ```dart
/// UIDailyAdhkarCard(
///   title: 'Daily Ajr Goal',
///   subtitle: '10/50 dikr per day',
///   currentCount: 10,
///   totalCount: 50,
///   buttonTitle: 'Start dikr',
///   onTap: () {},
/// )
/// ```
class UIDailyAdhkarCard extends StatelessWidget {
  const UIDailyAdhkarCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.totalCount,
    required this.buttonTitle,
    this.currentCount = 0,
    this.onTap,
  });

  final String title;

  /// Secondary line, e.g. `10/50 dikr per day`.
  final String subtitle;

  /// Progress denominator (e.g. 33).
  final int totalCount;

  /// Progress numerator; drives the percentage and progress fill.
  final int currentCount;

  final String buttonTitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final percent =
        totalCount <= 0 ? 0 : ((currentCount / totalCount) * 100).round();

    return UIBgArabicTextCard(
      height: 224,
      arabicBgText: 'سُبْحَانَ اللَّهِ\nسُبْحَانَ اللَّهِ',
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typo.inter.title.copyWith(color: UIColorsToken.white),
                  ),
                ),
                Text(
                  '$percent%',
                  style: typo.inter.title.copyWith(
                    color: UIColorsToken.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const UISpace.vert(16),
            UIProgressLine(
              current: currentCount.toDouble(),
              total: totalCount.toDouble(),
            ),
            const UISpace.vert(10),
            Text(
              subtitle,
              style: typo.inter.body.copyWith(color: UIColorsToken.white),
            ),
            const UISpace.vert(10),
            Center(
              child: _StartButton(
                title: buttonTitle,
                typo: typo,
                onTap: onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({
    required this.title,
    required this.typo,
    this.onTap,
  });

  final String title;
  final UITypographyToken typo;
  final VoidCallback? onTap;

  static const double _size = 100;

  @override
  Widget build(BuildContext context) {
    return UITap(
      onTap: onTap,
      child: Container(
        width: _size,
        height: _size,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: UIColorsToken.yellow, width: 1.5),
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: UIColorsToken.yellow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                Assets.images.illustration7.path,
                height: 28
              ),
              const UISpace.vert(4),
              Text(
                title,
                style: typo.inter.bodyMedium.copyWith(
                  color: UIColorsToken.white,
                  fontSize: 12,
                  fontWeight: .bold
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
