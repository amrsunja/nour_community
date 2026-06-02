import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Dashboard "Next prayer" banner.
///
/// Wide dark card showing the upcoming prayer's name and a live countdown,
/// with the prayer's illustration bleeding in from the right and a
/// "View all" action that routes to the full prayer-times page.
class NextPrayerWidget extends HookWidget {
  const NextPrayerWidget({
    super.key,
    required this.prayerName,
    required this.countdownTarget,
    required this.viewAllLabel,
    required this.nextPrayerLabel,
    this.backgroundImage,
    this.onViewAll,
  });

  /// Localized name of the next prayer (e.g. "Maghrib").
  final String prayerName;

  /// Absolute time of the next prayer; drives the live countdown.
  final DateTime countdownTarget;

  /// Label for the "View all" action.
  final String viewAllLabel;

  /// Caption above the prayer name (e.g. "Next prayer").
  final String nextPrayerLabel;

  /// Slot illustration shown faded on the right edge.
  final AssetGenImage? backgroundImage;

  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);

    return UICard(
      height: 150,
      width: .infinity,
      onTap: onViewAll,
      padding: EdgeInsets.zero,
      color: UIColorsToken.black80,
      disableBorder: true,
      shadows: [],
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            if (backgroundImage != null)
              Positioned.fill(
                left: 170,
                child: _Background(image: backgroundImage!),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          nextPrayerLabel,
                          style: theme.typo.inter.headline.copyWith(
                            color: UIColorsToken.textParagraph,
                          ),
                        ),
                      ),
                      UITap(
                        onTap: onViewAll,
                        child: Text(
                          viewAllLabel,
                          style: theme.typo.inter.bodyMedium.copyWith(
                            color: UIColorsToken.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  Text(
                    prayerName,
                    style: theme.typo.inter.title.copyWith(
                      color: UIColorsToken.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _Countdown(target: countdownTarget),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background({required this.image});

  final AssetGenImage image;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: 0.6,
          child: Image.asset(image.path, fit: BoxFit.cover),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                UIColorsToken.black80,
                UIColorsToken.black80.withValues(alpha: 0.7),
                UIColorsToken.black80.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.35, 0.85],
            ),
          ),
        ),
      ],
    );
  }
}

class _Countdown extends HookWidget {
  const _Countdown({required this.target});

  final DateTime target;

  static String _two(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);

    Duration compute() {
      final diff = target.difference(DateTime.now());
      return diff.isNegative ? Duration.zero : diff;
    }

    final remaining = useState<Duration>(compute());

    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 1), (_) {
        remaining.value = compute();
      });
      return timer.cancel;
    }, [target]);

    final d = remaining.value;
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;

    return Text(
      '${_two(h)} : ${_two(m)} : ${_two(s)}',
      style: theme.typo.inter.largeTitle.copyWith(
        color: UIColorsToken.white,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
