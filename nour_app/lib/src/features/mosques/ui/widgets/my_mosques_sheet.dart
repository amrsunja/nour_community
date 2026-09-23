import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';

import '../../data/models/mosque_model.dart';
import '../state_management/my_mosques_provider.dart';
import 'mosque_header.dart';

/// "Your mosque(s)" bottom sheet (Figma 1245:10598): principal + secondary
/// slots, drag to reorder, remove, Save.
class MyMosquesSheet extends HookConsumerWidget {
  const MyMosquesSheet({super.key, this.candidate, this.fromSearch = false});

  /// A mosque to add (from "Add to my mosques"): principal if the slot is
  /// free, else secondary.
  final MosqueModel? candidate;

  /// `true` when the sheet is opened from the mosque search page. Tapping an
  /// empty slot then saves the current selection and closes the sheet — the
  /// search map underneath is already the picker, so pushing another one
  /// would stack a duplicate route and lose the unsaved principal.
  final bool fromSearch;

  static Future<bool> show(
    BuildContext context, {
    MosqueModel? candidate,
    bool fromSearch = false,
  }) async {
    final res = await UIBottomSheet.show<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MyMosquesSheet(candidate: candidate, fromSearch: fromSearch),
    );
    return res ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final state = ref.watch(myMosquesProvider);
    final presenter = ref.read(myMosquesProvider.notifier);
    final nav = ref.read(navigationServicesProvider);

    final initial = useMemoized(() {
      final list = <MosqueModel>[if (state.principal != null) state.principal!, if (state.secondary != null) state.secondary!];
      final c = candidate;
      if (c != null && !list.any((m) => m.id == c.id)) {
        if (list.length >= 2) list.removeLast();
        list.add(c);
      }
      return list;
    });
    final items = useState<List<MosqueModel>>(initial);

    Future<bool> save() async {
      final ok = await presenter.save(
        principal: items.value.isNotEmpty ? items.value[0].id : null,
        secondary: items.value.length > 1 ? items.value[1].id : null,
      );
      if (ok && context.mounted) Navigator.of(context).pop(true);
      return ok;
    }

    // Empty slot tap: persist the current selection first so the principal is
    // never dropped, then close. From the search page we stop there — the map
    // behind the sheet is already the picker; elsewhere we push it.
    Future<void> pickAnother() async {
      if (items.value.isEmpty) {
        Navigator.of(context).pop(false);
        if (!fromSearch) nav.toMosqueSearch();
        return;
      }
      final ok = await save();
      if (ok && !fromSearch) nav.toMosqueSearch();
    }

    Widget slot(String title, MosqueModel? m, int index) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
            const SizedBox(height: 8),
            if (m == null)
              UITap(
                onTap: pickAnother,
                child: Container(
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: UIColorsToken.stroke.withValues(alpha: .3)),
                  ),
                  child: Text(
                    index == 0 ? l10n.my_mosques_no_principal : l10n.my_mosques_no_secondary,
                    style: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph),
                  ),
                ),
              )
            else
              Container(
                key: ValueKey(m.id),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: index == 0 ? UIColorsToken.bgSecondaryGreen : UIColorsToken.bgSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.drag_indicator, color: UIColorsToken.textParagraph, size: 18),
                    const SizedBox(width: 8),
                    MosqueLogo(mosque: m, size: 32, radius: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        [m.name, if ((m.city ?? '').isNotEmpty) m.city!].join(' - '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white),
                      ),
                    ),
                    UITap(
                      onTap: () => items.value = [for (final x in items.value) if (x.id != m.id) x],
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(color: UIColorsToken.red.withValues(alpha: .2), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.close, color: UIColorsToken.red, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Text(l10n.my_mosques_title, textAlign: TextAlign.center, style: theme.typo.inter.largeTitle.copyWith(color: UIColorsToken.white)),
          const SizedBox(height: 4),
          Text(l10n.my_mosques_subtitle, textAlign: TextAlign.center, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
          const SizedBox(height: 20),
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: true,
            proxyDecorator: (child, _, __) => Material(color: Colors.transparent, child: child),
            onReorder: (oldIndex, newIndex) {
              final list = [...items.value];
              if (newIndex > oldIndex) newIndex -= 1;
              final item = list.removeAt(oldIndex);
              list.insert(newIndex, item);
              items.value = list;
            },
            children: [
              for (var i = 0; i < 2; i++)
                Padding(
                  key: ValueKey('slot-$i-${i < items.value.length ? items.value[i].id : 'empty'}'),
                  padding: const EdgeInsets.only(bottom: 16),
                  child: slot(
                    i == 0 ? l10n.my_mosques_principal : l10n.my_mosques_secondary,
                    i < items.value.length ? items.value[i] : null,
                    i,
                  ),
                ),
            ],
          ),
          UIButton.primary(label: l10n.common_save, fullWidth: true, isBusy: state.isLoading, onTap: save),
        ],
      ),
    );
  }
}
