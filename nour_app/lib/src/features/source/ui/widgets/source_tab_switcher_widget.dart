import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

/// The two source categories shown by [SourceTabSwitcherWidget].
enum SourceTab { quran, hadith }

/// Segmented pill switching between the Quran and Hadith sources, matching the
/// Source page header design (active segment filled yellow).
class SourceTabSwitcherWidget extends StatelessWidget {
  const SourceTabSwitcherWidget({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final SourceTab current;
  final ValueChanged<SourceTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocale.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _Segment(
            label: l10n.source_quran,
            selected: current == SourceTab.quran,
            onTap: () => onChanged(SourceTab.quran),
          ),
          _Segment(
            label: l10n.source_hadith,
            selected: current == SourceTab.hadith,
            onTap: () => onChanged(SourceTab.hadith),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Expanded(
      child: UITap(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: selected ? UIColorsToken.bgPriYellow : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: typo.inter.headline.copyWith(
              color: selected ? UIColorsToken.black : UIColorsToken.white,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
