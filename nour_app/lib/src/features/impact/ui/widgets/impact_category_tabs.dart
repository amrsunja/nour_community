import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

import '../../data/models/project_category_model.dart';

/// Horizontally scrollable category filter for the Impact page. The active pill
/// is filled gold; the rest are plain tappable labels.
class ImpactCategoryTabs extends StatelessWidget {
  const ImpactCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.langCode,
    required this.onSelected,
  });

  final List<ProjectCategoryModel> categories;
  final int selectedId;
  final String langCode;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const UISpace.horz(10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final active = category.id == selectedId;

          return UITap(
            onTap: () => onSelected(category.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: active ? UIColorsToken.yellow : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                category.title(langCode),
                style: typo.inter.bodyMedium.copyWith(
                  color: active
                      ? UIColorsToken.black
                      : UIColorsToken.textParagraph,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
