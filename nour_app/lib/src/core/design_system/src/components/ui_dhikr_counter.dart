import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/utils/app_vibrations.dart';

/// Tappable dhikr (Islamic remembrance) counter.
///
/// Visualises progress as a wrap of small "bulls" that fill up to
/// [totalCount]. When the count first reaches [totalCount] a smooth
/// celebratory wave runs across all bulls. Tapping past the total keeps
/// incrementing — counter text shows the raw current count (e.g. `35/33`).
///
/// Controlled component: the parent owns [currentCount] and updates it
/// inside [onChange].
class UIDhikrCounter extends StatefulWidget {
  const UIDhikrCounter({
    super.key,
    required this.totalCount,
    required this.onChange,
    this.currentCount = 0,
    this.bullSize = 17,
    this.diameter = 220,
    this.startAngle = -math.pi / 2,
  });

  final int totalCount;
  final int? currentCount;
  final ValueChanged<int> onChange;

  /// Diameter of each bull (unscaled).
  final double bullSize;

  /// Outer diameter of the bull ring; bulls sit on a circle slightly
  /// smaller than this so their glow stays inside.
  final double diameter;

  /// Angle (radians) where the first bull sits. Defaults to 12 o'clock.
  final double startAngle;

  @override
  State<UIDhikrCounter> createState() => _UIDhikrCounterState();
}

class _UIDhikrCounterState extends State<UIDhikrCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  int get _current => widget.currentCount ?? 0;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
  }

  @override
  void didUpdateWidget(covariant UIDhikrCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldCount = oldWidget.currentCount ?? 0;
    final newCount = widget.currentCount ?? 0;

    // Fire wave the first time we hit / cross the total.
    if (oldCount < widget.totalCount && newCount >= widget.totalCount) {
      _waveController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _onTap() {
    AppVibrations.buttonClick();
    widget.onChange(_current + 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final filled = _current.clamp(0, widget.totalCount);
    // Bulls sit on a ring that's inset by half the bull size so the glow
    // halo doesn't clip the outer box.
    final radius = (widget.diameter - widget.bullSize) / 2;

    return UITap(
      onTap: _onTap,
      child: SizedBox(
        width: widget.diameter,
        height: widget.diameter,
        child: AnimatedBuilder(
          animation: _waveController,
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Counter text in the center of the ring.
                Column(
                  mainAxisSize: .min,
                  children: [
                    Text(
                      '$_current',
                      style: theme.typo.inter.hero.copyWith(
                        color: UIColorsToken.white,
                        fontSize: 60
                      ),
                    ),
                    Text(
                      'of ${widget.totalCount}',
                      style: theme.typo.inter.bodyMedium.copyWith(
                        color: UIColorsToken.textYellow
                      ),
                    )
                  ],
                ),
                // Bulls positioned around the ring.
                ...List.generate(widget.totalCount, (i) {
                  final angle =
                      widget.startAngle + 2 * math.pi * i / widget.totalCount;
                  final offset = Offset(
                    radius * math.cos(angle),
                    radius * math.sin(angle),
                  );
                  return Transform.translate(
                    offset: offset,
                    child: _Bull(
                      isFilled: i < filled,
                      size: widget.bullSize,
                      waveValue: _waveValueFor(i),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Returns a 0..1 pulse value for the bull at [index] based on the
  /// current wave progress. Bulls light up sequentially so the wave
  /// reads left-to-right.
  double _waveValueFor(int index) {
    if (!_waveController.isAnimating && _waveController.value == 0) return 0;

    final total = widget.totalCount;
    const window = 0.35; // each bull pulse occupies 35% of the wave timeline
    final start = (1 - window) * (index / math.max(total - 1, 1));
    final t = ((_waveController.value - start) / window).clamp(0.0, 1.0);
    // sin curve → smooth in-and-out pulse 0 → 1 → 0
    return math.sin(t * math.pi);
  }
}

class _Bull extends StatelessWidget {
  const _Bull({
    required this.isFilled,
    required this.size,
    required this.waveValue,
  });

  final bool isFilled;
  final double size;
  final double waveValue;

  @override
  Widget build(BuildContext context) {
    // Pulse scale & glow during the completion wave.
    final scale = 1 + waveValue * 0.6;
    final glowOpacity = waveValue * 0.55;

    return Transform.scale(
      scale: scale,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isFilled
              ? UIColorsToken.textYellow
              : Color(0xff7A5D2A).withValues(alpha: 0.2),
          boxShadow: [
            BoxShadow(
              color: UIColorsToken.textYellow.withValues(alpha: glowOpacity),
              blurRadius: 12,
              spreadRadius: 1,
            ),
            if (isFilled)
              BoxShadow(
                color: UIColorsToken.textYellow.withValues(alpha: 0.5),
                blurRadius: 3,
                spreadRadius: 1,
              ),
          ]
        ),
      ),
    );
  }
}
