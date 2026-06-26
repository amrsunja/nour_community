import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/config/app_config.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/routing/app_router.gr.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/core/utils/url_launcher_service.dart';
import 'package:nour/src/features/auth/ui/state_management/auth_provider.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';
import 'package:nour/src/features/profile/ui/widgets/delete_account_sheet.dart';
import 'package:nour/src/features/profile/ui/widgets/profile_avatar.dart';
import 'package:nour/src/features/profile/ui/widgets/profile_menu_row.dart';
import 'package:nour/src/features/profile/ui/widgets/profile_section.dart';

@RoutePage()
class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.read(navigationServicesProvider);
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

    Future<void> onDeleteAccount() async {
      final confirmed = await DeleteAccountSheet.show(context);
      if (confirmed != true) return;

      final auth = ref.read(authProvider.notifier);
      final ok = await auth.deleteUser();
      if (!ok) return;

      // Same re-auth bounce as logout: provisions a fresh anonymous session and
      // RootRoute routes the (incomplete) profile to onboarding.
      await auth.authorization();
      ref.read(navigationServicesProvider).toRoot();
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
                        onTap: () => nav.toProfileStatistics(),
                      ),
                      ProfileMenuRow(
                        icon: Icons.favorite_border,
                        label: l10n.profile_favourites,
                        onTap: () => nav.toFavorites(),
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
                        onTap: () => nav.toRemindersSettings(),
                      ),
                      ProfileMenuRow(
                        icon: Icons.settings_outlined,
                        label: l10n.profile_settings,
                        onTap: () => nav.toSettings(),
                      ),
                      /*ProfileMenuRow(
                        icon: Icons.menu_book_outlined,
                        label: l10n.profile_reading_preferences,
                        onTap: () {},
                      ),
                      */
                    ],
                  ),
                  const UISpace.vert(24),

                  // ---------- Account ----------
                  ProfileSection(
                    title: l10n.profile_account,
                    children: [
                      ProfileMenuRow(
                        icon: Icons.person_outline,
                        label: l10n.profile_account_information,
                        onTap: () => nav.toAccountInformation(),
                      ),
                      ProfileMenuRow(
                        icon: Icons.help_outline,
                        label: l10n.profile_help_support,
                        onTap: () => UrlLauncherService.sendEmail(
                          kSupportEmail,
                          subject: kSupportSubject,
                        ),
                      ),
                      ProfileMenuRow(
                        icon: Icons.info_outline,
                        label: l10n.profile_about,
                        onTap: () => nav.toWebView(
                          url: kAboutSawmUrl,
                          title: l10n.profile_about,
                        ),
                      ),
                      ProfileMenuRow(
                        icon: Icons.privacy_tip_outlined,
                        label: l10n.profile_privacy_policy,
                        onTap: () => nav.toWebView(
                          url: kPrivacyPolicyUrl,
                          title: l10n.profile_privacy_policy,
                        ),
                      ),
                      ProfileMenuRow(
                        icon: Icons.description_outlined,
                        label: l10n.profile_terms_of_use,
                        onTap: () => nav.toWebView(
                          url: kTermsOfUseUrl,
                          title: l10n.profile_terms_of_use,
                        ),
                      ),
                      // Logout only applies to a permanent (connected) account.
                      if (!session.isAnonymous)
                        ProfileMenuRow(
                          icon: Icons.logout,
                          label: l10n.profile_logout,
                          onTap: onLogout,
                        ),
                      // Delete is offered for BOTH anonymous and permanent
                      // accounts: App Store Guideline 5.1.1(v) requires in-app
                      // account deletion for any app that creates accounts —
                      // anonymous sessions included. delete_account() removes
                      // the caller's auth.users row (cascades all owned data);
                      // it works for anonymous users since they hold the
                      // `authenticated` role and a non-null auth.uid().
                      ProfileMenuRow(
                        icon: Icons.delete_outline,
                        label: l10n.profile_delete_account,
                        onTap: onDeleteAccount,
                      ),
                    ],
                  ),

                  const UISpace.vert(30),
                  Center(
                    child: Text(
                      '$kAppName - ${AppConfig.shared.appVersion}',
                      style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.yellow.withValues(alpha: 0.3)),
                    ),
                  )
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
