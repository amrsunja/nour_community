import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/widgets/snackbar_provider.dart';
import 'package:nour/src/core/utils/islamic_tools/hijri_strings.dart';
import 'package:nour/src/core/utils/islamic_tools/hijri_tool.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';
import 'package:nour/src/features/mosques/data/models/mosque_prayer_day_model.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_format.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_prayers_tab.dart';

import '../state_management/mosque_admin_prayers_provider.dart';
import 'copy_prayer_times_sheet.dart';

/// Admin prayer schedule editor (Figma "Mosquée profile - Prayers" ×4):
/// month header (hijri + gregorian), week strip, per-slot rows with time +
/// iqama offset, sunrise / jumu'a, copy-from-day, today's overrides.
class PrayerScheduleEditor extends ConsumerWidget {
  const PrayerScheduleEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final snackbar = ref.read(snackbarProvider);
    final presenter = ref.read(mosqueAdminPrayersProvider.notifier);
    final state = ref.watch(mosqueAdminPrayersProvider);
    final lang = Localizations.localeOf(context).languageCode;

    final day = state.draft ?? state.selected;
    final selected = state.selectedDay;
    final weekStart = selected.subtract(Duration(days: selected.weekday % 7)); // Sunday-first like the mock
    final week = [for (var i = 0; i < 7; i++) weekStart.add(Duration(days: i))];
    final hijri = HijriTool.fromGregorian(selected);
    final monthLabel = '${HijriStrings.monthName(hijri.month, lang)} ${hijri.year}';
    final gregLabel = week.first.month == week.last.month
        ? DateFormat('MMMM yyyy', lang).format(selected)
        : '${DateFormat('MMMM', lang).format(week.first)} - ${DateFormat('MMMM yyyy', lang).format(week.last)}';
    final overridesToday = state.overridesFor(selected);

    Future<void> pickTime(PrayerSlot? slot, {bool sunrise = false, bool jumua = false}) async {
      final current = sunrise ? day?.sunrise : jumua ? day?.jumua : day?.scheduled[slot!];
      final t = await showTimePicker(
        context: context,
        initialTime: current ?? const TimeOfDay(hour: 12, minute: 0),
        builder: (ctx, child) => MediaQuery(data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true), child: child!),
      );
      if (t == null) return;
      if (sunrise) {
        presenter.setSunrise(t);
      } else if (jumua) {
        presenter.setJumua(t);
      } else {
        presenter.setTime(slot!, t);
      }
    }

    Future<void> openCopy() async {
      final res = await CopyPrayerTimesSheet.show(context, days: state.days, initialTarget: selected);
      if (res == null) return;
      final n = await presenter.copy(from: res.from, toStart: res.toStart, toEnd: res.toEnd);
      if (n != null) snackbar.showSuccess(l10n.mosque_prayers_copied_from(DateFormat('MMM d', lang).format(res.from)));
    }

    Future<void> createOverride() async {
      final r = await _OverrideSheet.show(context, l10n: l10n, day: day);
      if (r == null) return;
      if (await presenter.addOverride(day: selected, slot: r.$1, time: r.$2, reason: r.$3)) {
        snackbar.showSuccess(l10n.mosque_override_created);
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.mosque_admin_prayer_times, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white)),
          const SizedBox(height: 12),
          Row(
            children: [
              UIIcon(UIIconsToken.icons.chevronLeft, color: UIColorsToken.yellow, onTap: () => presenter.selectDay(selected.subtract(const Duration(days: 7)))),
              Expanded(
                child: Column(
                  children: [
                    Text(monthLabel, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                    Text(gregLabel, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
                  ],
                ),
              ),
              Transform.flip(
                flipX: true,
                child: UIIcon(UIIconsToken.icons.chevronLeft, color: UIColorsToken.yellow, onTap: () => presenter.selectDay(selected.add(const Duration(days: 7)))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final d in week)
                Expanded(
                  child: _DayCell(
                    day: d,
                    selected: d == selected,
                    filled: state.days.containsKey(d),
                    lang: lang,
                    onTap: () => presenter.selectDay(d),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.isLoading && state.days.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: UICircularProgressBar()))
          else ...[
            if (day == null || day.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: UIColorsToken.yellow.withValues(alpha: .6)),
                  color: UIColorsToken.yellow.withValues(alpha: .08),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: UIColorsToken.textYellow, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.mosque_prayers_not_set_title, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                          Text(l10n.mosque_prayers_not_set_hint, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            for (final slot in IslamicTools.orderedSlots)
              _SlotRow(
                title: MosquePrayersTab.slotTitle(l10n, slot),
                time: MosqueFormat.hhmm(day?.scheduled[slot]),
                offset: day?.offsetFor(slot) ?? MosquePrayerDayModel.defaultOffsets[slot]!,
                overridden: overridesToday.any((o) => o.slot == slot),
                onEdit: () => pickTime(slot),
                onOffset: (v) => presenter.setOffset(slot, v),
              ),
            Row(
              children: [
                Expanded(
                  child: _SmallCell(label: l10n.prayer_times_chourouk, value: MosqueFormat.hhmm(day?.sunrise), onEdit: () => pickTime(null, sunrise: true)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SmallCell(label: l10n.prayer_times_jumua, value: MosqueFormat.hhmm(day?.jumua), onEdit: () => pickTime(null, jumua: true)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (state.isDirty)
              Row(
                children: [
                  Expanded(child: UIButton.textual(label: l10n.common_cancel, fullWidth: true, contentColor: UIColorsToken.white, onTap: presenter.discard)),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: UIButton.primary(label: l10n.common_save, fullWidth: true, isBusy: state.isSaving, onTap: presenter.save)),
                ],
              )
            else
              UIButton.secondary(label: l10n.mosque_prayers_copy_from_day, fullWidth: true, onTap: state.days.isEmpty ? null : openCopy),
            const SizedBox(height: 24),
            Text(l10n.mosque_overrides_title, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white)),
            const SizedBox(height: 12),
            UICard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16, color: UIColorsToken.white),
                      const SizedBox(width: 8),
                      Text(l10n.mosque_overrides_shift_title, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(l10n.mosque_overrides_shift_hint, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
                  const SizedBox(height: 12),
                  UIButton.secondary(label: l10n.mosque_overrides_create, fullWidth: true, onTap: (day == null || day.isEmpty) ? null : createOverride),
                  if (overridesToday.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(l10n.mosque_overrides_applied, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
                    const SizedBox(height: 8),
                    for (final o in overridesToday)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(MosquePrayersTab.slotTitle(l10n, o.slot), style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.notifications_active_outlined, size: 14, color: UIColorsToken.greenAccent),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(MosqueFormat.hhmm(o.time), style: theme.typo.inter.title.copyWith(color: UIColorsToken.white)),
                                      const SizedBox(width: 6),
                                      Text(
                                        MosqueFormat.hhmm(day?.scheduled[o.slot]),
                                        style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph, decoration: TextDecoration.lineThrough),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            UITap(
                              onTap: () => presenter.removeOverride(o),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(color: UIColorsToken.red.withValues(alpha: .2), borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.close, color: UIColorsToken.red, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.selected, required this.filled, required this.lang, required this.onTap});
  final DateTime day;
  final bool selected;
  final bool filled;
  final String lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final hijri = HijriTool.fromGregorian(day);
    final color = selected ? UIColorsToken.white : (filled ? UIColorsToken.white : UIColorsToken.textParagraph);
    return UITap(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? UIColorsToken.textYellow : Colors.transparent),
          color: filled && !selected ? UIColorsToken.bgSurface : Colors.transparent,
        ),
        child: Column(
          children: [
            Text(DateFormat('E', lang).format(day).substring(0, 1).toUpperCase(),
                style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
            const SizedBox(height: 4),
            Text('${hijri.day}', style: theme.typo.inter.title.copyWith(color: color)),
            Text(DateFormat('MMM d', lang).format(day), style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({required this.title, required this.time, required this.offset, required this.overridden, required this.onEdit, required this.onOffset});
  final String title;
  final String time;
  final int offset;
  final bool overridden;
  final VoidCallback onEdit;
  final ValueChanged<int> onOffset;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: UITap(
              onTap: onEdit,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: theme.typo.inter.headline.copyWith(color: UIColorsToken.white)),
                      if (overridden) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.notifications_active_outlined, size: 14, color: UIColorsToken.greenAccent),
                      ],
                    ],
                  ),
                  Text(time, style: theme.typo.inter.largeTitle.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          UITap(onTap: () => onOffset(offset - 5), child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.remove, size: 16, color: UIColorsToken.textParagraph))),
          Text('+$offset', style: theme.typo.inter.headline.copyWith(color: UIColorsToken.textParagraph)),
          UITap(onTap: () => onOffset(offset + 5), child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.add, size: 16, color: UIColorsToken.textParagraph))),
          const SizedBox(width: 8),
          UITap(onTap: onEdit, child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.edit_outlined, size: 18, color: UIColorsToken.textParagraph))),
        ],
      ),
    );
  }
}

class _SmallCell extends StatelessWidget {
  const _SmallCell({required this.label, required this.value, required this.onEdit});
  final String label;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return UICard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      onTap: onEdit,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
                Text(value, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white)),
              ],
            ),
          ),
          const Icon(Icons.edit_outlined, size: 16, color: UIColorsToken.textParagraph),
        ],
      ),
    );
  }
}

/// (slot, time, reason)
class _OverrideSheet {
  static Future<(PrayerSlot, TimeOfDay, String?)?> show(BuildContext context, {required AppLocale l10n, MosquePrayerDayModel? day}) async {
    PrayerSlot slot = PrayerSlot.maghrib;
    TimeOfDay? time;
    final reason = TextEditingController();
    return showModalBottomSheet<(PrayerSlot, TimeOfDay, String?)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: UIColorsToken.bgPrimary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final theme = UITheme.of(ctx);
          return Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.mosque_overrides_shift_title, textAlign: TextAlign.center, style: theme.typo.inter.display.copyWith(color: UIColorsToken.white)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final s in PrayerSlot.values)
                      ChoiceChip(
                        label: Text(MosquePrayersTab.slotTitle(l10n, s)),
                        selected: slot == s,
                        selectedColor: UIColorsToken.textYellow,
                        labelStyle: theme.typo.inter.bodyMedium.copyWith(color: slot == s ? UIColorsToken.black : UIColorsToken.white),
                        backgroundColor: UIColorsToken.bgSurface,
                        onSelected: (_) => setState(() => slot = s),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                UIButton.secondary(
                  label: time == null
                      ? '${l10n.mosque_override_new_time} (${MosqueFormat.hhmm(day?.scheduled[slot])})'
                      : MosqueFormat.hhmm(time),
                  fullWidth: true,
                  onTap: () async {
                    final t = await showTimePicker(
                      context: ctx,
                      initialTime: day?.scheduled[slot] ?? const TimeOfDay(hour: 12, minute: 0),
                      builder: (c, child) => MediaQuery(data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: true), child: child!),
                    );
                    if (t != null) setState(() => time = t);
                  },
                ),
                const SizedBox(height: 12),
                UIInputField(controller: reason, hintText: l10n.mosque_override_reason_hint, textInputAction: TextInputAction.done),
                const SizedBox(height: 16),
                UIButton.primary(
                  label: l10n.mosque_overrides_create,
                  fullWidth: true,
                  onTap: time == null ? null : () => Navigator.of(ctx).pop((slot, time!, reason.text.trim().isEmpty ? null : reason.text.trim())),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
