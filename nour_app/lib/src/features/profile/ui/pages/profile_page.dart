import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/routing/app_router.gr.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/auth/ui/state_management/auth_provider.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';
import 'package:nour/src/features/profile/ui/widgets/profile_avatar.dart';
import 'package:nour/src/features/profile/ui/widgets/profile_menu_row.dart';
import 'package:nour/src/features/profile/ui/widgets/profile_section.dart';

@RoutePage()
class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);

    final profile = ref.watch(profileProvider.select((s) => s.profile));
    final session = ref.watch(authSessionProvider);
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));

    final name = (profile?.name?.trim().isNotEmpty ?? false)
        ? profile!.name!.trim()
        : l10n.profile_guest;
    final handle = _handle(profile?.name, session.email);

    Future<void> onConnect() => context.router.push(const SignInRoute());

    Future<void> onLogout() async {
      final auth = ref.read(authProvider.notifier);

      await auth.logout().then((value) async {
        if (!value) return ;

        await auth.authorization();
        ref.read(navigationServicesProvider).toRoot();
      });
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UIAppBar(
            onBack: () => context.router.maybePop(),
            title: l10n.profile_title,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                kPageHorzPadding,
                16,
                kPageHorzPadding,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---------- Identity ----------
                  Center(
                    child: ProfileAvatar(
                      initial: name.isNotEmpty ? name[0] : '?',
                    ),
                  ),
                  const UISpace.vert(16),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: theme.typo.inter.title
                        .copyWith(color: UIColorsToken.white),
                  ),
                  if (handle != null) ...[
                    const UISpace.vert(4),
                    Text(
                      handle,
                      textAlign: TextAlign.center,
                      style: theme.typo.inter.bodyMedium
                          .copyWith(color: UIColorsToken.textParagraph),
                    ),
                  ],

                  // ---------- Connect (anonymous only) ----------
                  if (session.isAnonymous) ...[
                    const UISpace.vert(24),
                    UIButton.primary(
                      label: l10n.profile_connect_account,
                      fullWidth: true,
                      isBusy: isLoading,
                      onTap: onConnect,
                    ),
                  ],

                  const UISpace.vert(28),

                  // ---------- Journey ----------
                  ProfileSection(
                    title: l10n.profile_journey,
                    children: [
                      ProfileMenuRow(
                        icon: Icons.emoji_events_outlined,
                        label: l10n.profile_statistics,
                        onTap: () => ref
                            .read(navigationServicesProvider)
                            .toProfileStatistics(),
                      ),
                      ProfileMenuRow(
                        icon: Icons.favorite_border,
                        label: l10n.profile_favourites,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const UISpace.vert(24),

                  // ---------- Preferences ----------
                  ProfileSection(
                    title: l10n.profile_preferences,
                    children: [
                      ProfileMenuRow(
                        icon: Icons.history,
                        label: l10n.profile_reminders,
                        onTap: () {},
                      ),
                      ProfileMenuRow(
                        icon: Icons.settings_outlined,
                        label: l10n.profile_settings,
                        onTap: () {},
                      ),
                      ProfileMenuRow(
                        icon: Icons.menu_book_outlined,
                        label: l10n.profile_reading_preferences,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const UISpace.vert(24),

                  // ---------- Account ----------
                  ProfileSection(
                    title: l10n.profile_account,
                    children: [
                      ProfileMenuRow(
                        icon: Icons.help_outline,
                        label: l10n.profile_help_support,
                        onTap: () {},
                      ),
                      ProfileMenuRow(
                        icon: Icons.info_outline,
                        label: l10n.profile_about,
                        onTap: () {},
                      ),
                    ],
                  ),

                  // ---------- Logout (connected only) ----------
                  if (!session.isAnonymous) ...[
                    const UISpace.vert(32),
                    UIButton.textual(
                      label: l10n.profile_logout,
                      fullWidth: true,
                      isBusy: isLoading,
                      contentColor: UIColorsToken.red,
                      onTap: onLogout,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// `@local` from the linked email, otherwise a slug of the display name,
  /// otherwise null (renders nothing).
  String? _handle(String? name, String? email) {
    if (email != null && email.contains('@')) {
      return '@${email.split('@').first}';
    }
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final slug = trimmed.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    return '@$slug';
  }
}
