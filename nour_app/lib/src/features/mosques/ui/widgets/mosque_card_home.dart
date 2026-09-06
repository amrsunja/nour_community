import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/features/settings/ui/state_management/app_config_provider.dart';
import 'package:nour/src/features/tools/ui/state_management/prayer_times_provider.dart';
import 'package:nour/src/features/tools/ui/state_management/prayer_times_state.dart';

import '../state_management/my_mosques_provider.dart';
import 'mosque_format.dart';
import 'mosque_header.dart';

/// Dashboard "My mosque" card (Figma "Home - mosque news"): empty state with
/// "Find a mosque", or the principal mosque + next prayer there.
class MosqueCardHome extends ConsumerWidget {
  const MosqueCardHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final enabled = ref.watch(appConfigProvider.select((c) => c.mosquesEnabled));
    final my = ref.watch(myMosquesProvider);
    final prayers = ref.watch(prayerTimesProvider);

    if (!enabled) return const SizedBox.shrink();

    final mosque = my.principal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.home_my_mosque, style: theme.typo.inter.headline.copyWith(color: UIColorsToken.white)),
        const SizedBox(height: 12),
        if (mosque == null)
          UICard(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(l10n.home_no_mosque_title, textAlign: TextAlign.center, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white)),
                const SizedBox(height: 6),
                Text(l10n.home_no_mosque_subtitle, textAlign: TextAlign.center, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
                const SizedBox(height: 16),
                UIButton.primary(label: l10n.home_find_mosque, fullWidth: true, onTap: nav.toMosqueSearch),
              ],
            ),
          )
        else
          UICard(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            onTap: () => nav.toMosqueProfile(mosqueId: mosque.id),
            child: Row(
              children: [
                MosqueLogo(mosque: mosque, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mosque.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white)),
                      const SizedBox(height: 2),
                      Text(
                        prayers.source == PrayerSource.mosque && prayers.nextSlot != null && prayers.nextTime != null
                            ? '${l10n.dashboard_next_prayer} · ${MosqueFormat.hhmmDate(prayers.nextTime!)}'
                            : (mosque.city ?? ''),
                        style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: UIColorsToken.textYellow),
              ],
            ),
          ),
      ],
    );
  }
}
