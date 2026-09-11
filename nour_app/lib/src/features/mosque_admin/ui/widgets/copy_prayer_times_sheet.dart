import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';
import 'package:nour/src/features/mosques/data/models/mosque_prayer_day_model.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_format.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_prayers_tab.dart';

class CopyPrayerTimesResult {
  const CopyPrayerTimesResult({required this.from, required this.toStart, required this.toEnd});
  final DateTime from;
  final DateTime toStart;
  final DateTime toEnd;
}

/// "Copy prayer times" sheet (Figma 1333:17251 / 1333:17299): source day,
/// preview, "This day only" / "A date range" (From / To), overwrite warning.
class CopyPrayerTimesSheet extends ConsumerStatefulWidget {
  const CopyPrayerTimesSheet({super.key, required this.days, required this.initialTarget});

  final Map<DateTime, MosquePrayerDayModel> days;
  final DateTime initialTarget;

  static Future<CopyPrayerTimesResult?> show(BuildContext context, {required Map<DateTime, MosquePrayerDayModel> days, required DateTime initialTarget}) {
    return showModalBottomSheet<CopyPrayerTimesResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: UIColorsToken.bgPrimary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => CopyPrayerTimesSheet(days: days, initialTarget: initialTarget),
    );
  }

  @override
  ConsumerState<CopyPrayerTimesSheet> createState() => _CopyPrayerTimesSheetState();
}

class _CopyPrayerTimesSheetState extends ConsumerState<CopyPrayerTimesSheet> {
  late DateTime from;
  late DateTime toStart;
  late DateTime toEnd;
  bool range = false;

  @override
  void initState() {
    super.initState();
    // Default source: the closest filled day before the target, else the latest filled day.
    final filled = widget.days.keys.toList()..sort();
    from = filled.lastWhere((d) => d.isBefore(widget.initialTarget), orElse: () => filled.isEmpty ? widget.initialTarget : filled.last);
    toStart = widget.initialTarget;
    toEnd = widget.initialTarget;
  }

  Future<DateTime?> _pick(DateTime initial, {bool onlyFilled = false}) {
    return UIPickers.date(
      context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 400)),
      selectableDayPredicate: onlyFilled ? (d) => widget.days.containsKey(DateTime(d.year, d.month, d.day)) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final src = widget.days[from];
    String fmt(DateTime d) => DateFormat('MMM d, yyyy', lang).format(d);

    Widget dateField(String label, DateTime value, VoidCallback onTap) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
            const SizedBox(height: 6),
            UITap(
              onTap: onTap,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 16, color: UIColorsToken.textParagraph),
                    const SizedBox(width: 8),
                    Text(fmt(value), style: theme.typo.inter.body.copyWith(color: UIColorsToken.white)),
                  ],
                ),
              ),
            ),
          ],
        );

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.of(context).padding.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(width: 72, height: 5, decoration: BoxDecoration(color: UIColorsToken.white, borderRadius: BorderRadius.circular(3)))),
            const SizedBox(height: 20),
            Text(l10n.mosque_copy_title, textAlign: TextAlign.center, style: theme.typo.inter.display.copyWith(color: UIColorsToken.white)),
            const SizedBox(height: 4),
            Text(l10n.mosque_copy_subtitle, textAlign: TextAlign.center, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
            const SizedBox(height: 20),
            dateField(l10n.mosque_copy_from, from, () async {
              final d = await _pick(from, onlyFilled: true);
              if (d != null) setState(() => from = DateTime(d.year, d.month, d.day));
            }),
            const SizedBox(height: 16),
            Text(l10n.mosque_copy_times, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in IslamicTools.orderedSlots)
                  Container(
                    width: (MediaQuery.of(context).size.width - 48) / 3,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(MosquePrayersTab.slotTitle(l10n, s), style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
                        Text(MosqueFormat.hhmm(src?.scheduled[s]), style: theme.typo.inter.title.copyWith(color: UIColorsToken.white)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.mosque_copy_apply_to, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _Choice(label: l10n.mosque_copy_this_day, selected: !range, onTap: () => setState(() => range = false))),
                const SizedBox(width: 10),
                Expanded(child: _Choice(label: l10n.mosque_copy_date_range, selected: range, onTap: () => setState(() => range = true))),
              ],
            ),
            if (range) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: dateField(l10n.mosque_copy_from_date, toStart, () async {
                      final d = await _pick(toStart);
                      if (d != null) setState(() => toStart = DateTime(d.year, d.month, d.day));
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: dateField(l10n.mosque_copy_to_date, toEnd, () async {
                      final d = await _pick(toEnd);
                      if (d != null) setState(() => toEnd = DateTime(d.year, d.month, d.day));
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: UIColorsToken.textParagraph),
                  const SizedBox(width: 6),
                  Expanded(child: Text(l10n.mosque_copy_overwrite_warning, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph))),
                ],
              ),
            ],
            const SizedBox(height: 20),
            UIButton.primary(
              label: l10n.common_save,
              fullWidth: true,
              onTap: src == null
                  ? null
                  : () => Navigator.of(context).pop(CopyPrayerTimesResult(
                        from: from,
                        toStart: range ? toStart : widget.initialTarget,
                        toEnd: range ? (toEnd.isBefore(toStart) ? toStart : toEnd) : widget.initialTarget,
                      )),
            ),
          ],
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return UITap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: selected ? UIColorsToken.bgPriYellow : null,
          color: selected ? null : UIColorsToken.bgSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: theme.typo.inter.bodyMedium.copyWith(color: selected ? UIColorsToken.black : UIColorsToken.white)),
      ),
    );
  }
}
