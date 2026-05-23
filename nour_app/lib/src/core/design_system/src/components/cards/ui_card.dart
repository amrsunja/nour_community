import 'package:flutter/widgets.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/utils/app_vibrations.dart';

class UICard extends StatelessWidget {
  const UICard({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.colors,
    this.color,
    this.borderRadius = 14,
    this.begin = .topCenter,
    this.end = .bottomCenter,
    this.shadows,
    this.disableBorder = false,
    required this.child,
    this.onTap,
  });

  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final List<Color>? colors;
  final Color? color;
  final double borderRadius;
  final bool disableBorder;
  final Alignment begin;
  final Alignment end;
  final List<BoxShadow>? shadows;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return UITap(
      onTap: onTap == null ? null : () {
        AppVibrations.selection();
        onTap!();
      },
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: color,
          gradient: color != null ? null : LinearGradient(
            begin: begin,
            end: end,
            colors: colors ?? [
              Color(0xff2A2E27),
              Color(0xff1A1A1A)
            ],
          ),
          border: disableBorder ? null : Border.all(
            color: UIColorsToken.white.withValues(alpha: 0.06),
            width: 1,
          ),
          boxShadow: shadows ?? [
            BoxShadow(
              color: UIColorsToken.black.withValues(alpha: 0.45),
              blurRadius: 28,
              spreadRadius: -4,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}


