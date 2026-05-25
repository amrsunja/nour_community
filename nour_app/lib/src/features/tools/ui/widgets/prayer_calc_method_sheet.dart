import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/utils/enums/calculation_method_type.dart';

/// Bottom-sheet content listing every [CalculationMethodType] with a short
/// explanation. The currently selected method is highlighted. Selecting a row
/// invokes [onSelect] and closes the sheet.
class PrayerCalcMethodSheet extends StatelessWidget {
  const PrayerCalcMethodSheet({
    super.key,
    required this.title,
    required this.selected,
    required this.onSelect,
  });

  final String title;
  final CalculationMethodType selected;
  final ValueChanged<CalculationMethodType> onSelect;

  /// Helper to present this sheet with the project's dark styling.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required CalculationMethodType selected,
    required ValueChanged<CalculationMethodType> onSelect,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: UIColorsToken.bgPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PrayerCalcMethodSheet(
        title: title,
        selected: selected,
        onSelect: onSelect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final media = MediaQuery.of(context);

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: UIColorsToken.stroke,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.typo.inter.largeTitle.copyWith(
                        color: UIColorsToken.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                physics: const BouncingScrollPhysics(),
                itemCount: CalculationMethodType.values.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final method = CalculationMethodType.values[index];
                  return UIGradientCard(
                    selected: method == selected,
                    onTap: () {
                      onSelect(method);
                      Navigator.of(context).maybePop();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                method.name,
                                style: theme.typo.inter.title.copyWith(
                                  color: UIColorsToken.white,
                                ),
                              ),
                            ),
                            if (method == selected)
                              const Icon(
                                Icons.check_circle,
                                color: UIColorsToken.textYellow,
                                size: 20,
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          method.description,
                          style: theme.typo.inter.bodyMedium.copyWith(
                            color: UIColorsToken.textParagraph,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
