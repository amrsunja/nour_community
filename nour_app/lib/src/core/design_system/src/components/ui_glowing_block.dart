import 'package:flutter/widgets.dart';
import 'package:nour/src/core/design_system/design_system.dart';

class UIGlowingBlock extends StatelessWidget {
  const UIGlowingBlock({
    super.key,
    required this.child,
    this.shadow
  });

  final Widget child;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: .circular(1000),
        boxShadow: shadow ?? UIShadowToken.illustration
      ),
      child: child,
    );
  }
}


