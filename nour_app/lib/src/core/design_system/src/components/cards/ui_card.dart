import 'package:flutter/widgets.dart';
import 'package:nour/src/core/design_system/design_system.dart';

class UICard extends StatelessWidget {
  const UICard({
    super.key,
    this.width,
    this.height,
    this.padding,
    required this.child,
  });

  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xff2A2E27),
            Color(0xff1A1A1A)
          ],
        ),
        border: Border.all(
          color: UIColorsToken.white.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: UIColorsToken.black.withValues(alpha: 0.45),
            blurRadius: 28,
            spreadRadius: -4,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}


