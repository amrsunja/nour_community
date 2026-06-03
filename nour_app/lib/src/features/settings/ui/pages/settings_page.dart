import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';

/// Settings hub. Lists the configurable preferences as navigation cards. Each
/// card opens a dedicated page that persists its choice immediately (no save).
@RoutePage()
class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);

    final items = <_SettingsItem>[
      _SettingsItem(
        icon: UIIconsToken.icons.volume,
        label: l10n.settings_favorite_reciter,
        onTap: nav.toFavoriteReciterSettings,
      ),
      _SettingsItem(
        icon: UIIconsToken.icons.aa,
        label: l10n.settings_language,
        onTap: nav.toLanguageSettings,
      ),
    ];

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UIAppBar(
            title: l10n.settings_app,
            onBack: () => context.router.maybePop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                kPageHorzPadding,
                12,
                kPageHorzPadding,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < items.length; i++)
                    Padding(
                      padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
                      child: UIAppearAnimation(
                        delay: Duration(milliseconds: 120 + i * 90),
                        offsetY: 16,
                        child: _SettingsCard(item: items[i]),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem {
  _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.item});

  final _SettingsItem item;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);

    return UIGradientCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: item.onTap,
      reverseGradient: true,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: UIColorsToken.textYellow.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: UIIconsToken.toIcon(
              item.icon,
              color: UIColorsToken.textYellow,
              size: 20,
            ),
          ),
          const UISpace.horz(14),
          Expanded(
            child: Text(
              item.label,
              style: theme.typo.inter.title.copyWith(
                color: UIColorsToken.white,
              ),
            ),
          ),
          const UISpace.horz(8),
          const Icon(
            Icons.chevron_right,
            size: 22,
            color: UIColorsToken.yellow,
          ),
        ],
      ),
    );
  }
}
