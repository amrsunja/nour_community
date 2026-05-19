import 'package:flutter/widgets.dart';
import 'package:nour/src/core/design_system/design_system.dart';

class UIGradientCard extends StatelessWidget {
  const UIGradientCard({
    super.key,
    this.padding = const EdgeInsets.all(16),
    required this.child,
  });

  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0, 0.1,0.8],
          colors: [
            Color(0xff252219),
            Color(0xff1A1A1A),
            Color(0xff1A1A1A),
          ],
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


