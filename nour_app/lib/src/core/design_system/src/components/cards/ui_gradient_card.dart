import 'package:flutter/widgets.dart';
import 'package:nour/src/core/design_system/design_system.dart';

class UIGradientCard extends StatelessWidget {
  const UIGradientCard({
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.selected = false,
    required this.child,
  });

  final EdgeInsets padding;
  final bool selected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final accent = UIColorsToken.textYellow;
    final selectedBg = Color(0xff252219);
    final unselectedBg = Color(0xff1A1A1A);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: padding,
      decoration: BoxDecoration(
        border: Border.all(
          color: selected
            ? accent
            : UIColorsToken.white.withValues(alpha: 0),
          width: selected ? 1 : 1,
        ),
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0, 0.1,0.8],
          colors: [
            selectedBg,
            selected ? selectedBg : unselectedBg,
            selected ? selectedBg : unselectedBg,
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


