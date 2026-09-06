import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/features/settings/ui/state_management/app_config_provider.dart';

/// Chip on the Prayer times page (Figma "Prayer time"): the principal mosque
/// whose schedule is displayed, or "Add your mosque". Opens the My mosques sheet.
class MosquePrayerSourceChip extends ConsumerWidget {
  const MosquePrayerSourceChip({super.key, required this.mosqueName, required this.isMosqueSource, required this.onTap});

  final String? mosqueName;
  final bool isMosqueSource;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    if (!ref.watch(appConfigProvider.select((c) => c.mosquesEnabled))) return const SizedBox.shrink();
    return UITap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: UIColorsToken.bgSecondaryGreen, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            const Icon(Icons.mosque_outlined, size: 18, color: UIColorsToken.textYellow),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                mosqueName ?? l10n.prayer_times_add_mosque,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white),
              ),
            ),
            Icon(mosqueName == null ? Icons.add : Icons.edit_outlined, size: 18, color: UIColorsToken.textYellow),
          ],
        ),
      ),
    );
  }
}
