import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

class CategoryBadgeWidget extends StatelessWidget {
  const CategoryBadgeWidget({super.key, required this.label, required this.urgent});

  final String label;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: urgent ? UIColorsToken.red : null,
        gradient: urgent ? null : UIColorsToken.bgPriYellow,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: typo.inter.bodySmall.copyWith(
          color: urgent ? UIColorsToken.white : UIColorsToken.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
