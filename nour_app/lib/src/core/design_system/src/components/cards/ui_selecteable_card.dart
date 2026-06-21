import 'package:flutter/widgets.dart';
import 'package:nour/src/core/design_system/design_system.dart';

class UISelecteableCard extends StatelessWidget {
  const UISelecteableCard({
    super.key,
    required this.child,
    required this.selected,
  });

  final Widget child;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final accent = UIColorsToken.textYellow;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: selected ? Color(0xff252219) : Color(0xff1A1A1A),
        border: Border.all(
          color: selected
            ? accent
            : UIColorsToken.white.withValues(alpha: 0),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: child,
    );
  }
}
