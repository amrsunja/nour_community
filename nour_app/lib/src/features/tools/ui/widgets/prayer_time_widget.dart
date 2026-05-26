import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// A single prayer row on the Prayer times page.
///
/// Two visual states:
///  - default: name, time, "+offset" badge and a notification bell.
///  - next ([isNext] = true): wrapped in a dark card with the prayer's
///    background image (at 0.5 opacity, fading in from the right) plus a live
///    countdown to [countdownTarget].
class PrayerTimeWidget extends HookWidget {
  const PrayerTimeWidget({
    super.key,
    required this.title,
    required this.time,
    required this.offsetMinutes,
    required this.notify,
    required this.onToggleNotify,
    this.isNext = false,
    this.backgroundImage,
    this.countdownTarget,
  });

  final String title;
  final DateTime time;
  final int offsetMinutes;
  final bool notify;
  final VoidCallback onToggleNotify;
  final bool isNext;
  final AssetGenImage? backgroundImage;
  final DateTime? countdownTarget;

  static String _two(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);

    final content = Stack(
      children: [
        if (isNext && backgroundImage != null)
          Positioned.fill(
            left: 180,
            child: _Background(image: backgroundImage!)
          ),
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.typo.inter.headline.copyWith(
                            color: UIColorsToken.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${_two(time.hour)}:${_two(time.minute)}',
                              style: theme.typo.inter.largeTitle.copyWith(
                                color: UIColorsToken.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '+$offsetMinutes',
                                style: theme.typo.inter.headline.copyWith(
                                  color: UIColorsToken.textParagraph,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  UITap(
                    onTap: onToggleNotify,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4),
                      child: UIIcon(
                        notify
                            ? UIIconsToken.icons.notif
                            : UIIconsToken.icons.notNotif,
                      ),
                    ),
                  ),
                ],
              ),
              if (isNext && countdownTarget != null) ...[
                const SizedBox(height: 28),
                _Countdown(target: countdownTarget!),
              ],
            ],
          ),
        ),
      ],
    );

    if (!isNext) return content;

    return Container(
      height: 150,
      width: .infinity,
      decoration: BoxDecoration(
        color: UIColorsToken.black80,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
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
          opacity: 0.5,
          child: Image.asset(image.path, fit: BoxFit.cover),
        ),
        // Fade the image out towards the left so the text stays legible.
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
      style: theme.typo.inter.title.copyWith(
        color: UIColorsToken.white,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
