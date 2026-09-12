import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/config/app_config.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/core/utils/url_launcher_service.dart';
import 'package:nour/src/features/auth/ui/state_management/auth_provider.dart';
import 'package:nour/src/features/mosque_admin/ui/widgets/mosque_settings_avatar.dart';
import 'package:nour/src/features/mosques/data/models/mosque_enums.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';
import 'package:nour/src/features/profile/ui/widgets/delete_account_sheet.dart';
import 'package:nour/src/features/profile/ui/widgets/profile_menu_row.dart';
import 'package:nour/src/features/profile/ui/widgets/profile_section.dart';

/// Settings for a **mosque** account — same layout as the worshipper profile
/// page, minus the worshipper-only entries: no dashboard card, no Journey section
/// (statistics / favourites), no app-settings row and no account-information
/// row. The identity block shows the mosque logo (editable) instead of the
/// manager's personal avatar.
@RoutePage()
class MosqueSettingsPage extends HookConsumerWidget {
  const MosqueSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.read(navigationServicesProvider);
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);

    final profile = ref.watch(profileProvider.select((s) => s.profile));
    final mosque = ref.watch(myMosqueProvider.select((s) => s.mosque));
    final session = ref.watch(authSessionProvider);

    final name = (mosque?.name.trim().isNotEmpty ?? false)
        ? mosque!.name.trim()
        : ((profile?.name?.trim().isNotEmpty ?? false)
            ? profile!.name!.trim()
            : l10n.profile_guest);
    final handle = _handle(mosque?.city ?? profile?.name, session.email);

    Future<void> onLogout() async {
      final auth = ref.read(authProvider.notifier);

      await auth.logout().then((value) async {
        if (!value) return;

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

      await auth.authorization();
      ref.read(navigationServicesProvider).toRoot();
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UIAppBar(
            onBack: () => context.router.maybePop(),
            title: l10n.mosque_settings_title,
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
                  // ---------- Identity (mosque logo) ----------
                  const Center(child: MosqueSettingsAvatar()),
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

                  const UISpace.vert(28),

                  // ---------- Legal information (read-only) ----------
                  // Mirrors the "Let's register your mosque" onboarding step.
                  // These columns are protected server-side (§4.10 guard
                  // trigger), so they are displayed, never edited.
                  if (mosque != null) ...[
                    ProfileSection(
                      title: l10n.mosque_settings_legal_section,
                      children: [
                        _ReadOnlyRow(
                          icon: Icons.badge_outlined,
                          label: l10n.mosque_register_legal_name,
                          value: mosque.legalName,
                        ),
                        _ReadOnlyRow(
                          icon: Icons.account_balance_outlined,
                          label: l10n.mosque_register_legal_status,
                          value: _legalStatusLabel(l10n, mosque.legalStatus),
                        ),
                        _ReadOnlyRow(
                          icon: Icons.numbers_outlined,
                          label: l10n.mosque_register_rna,
                          value: mosque.rna,
                        ),
                        _ReadOnlyRow(
                          icon: Icons.confirmation_number_outlined,
                          label: l10n.mosque_register_siren,
                          value: mosque.siren,
                        ),
                      ],
                    ),
                    const UISpace.vert(24),
                  ],

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
                        icon: Icons.notifications_none,
                        label: l10n.push_settings_title,
                        onTap: () => nav.toPushSettings(),
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
                      // A mosque account is never anonymous (§3.1), but keep
                      // the same guard as ProfilePage.
                      if (!session.isAnonymous)
                        ProfileMenuRow(
                          icon: Icons.logout,
                          label: l10n.profile_logout,
                          onTap: onLogout,
                        ),
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
                      style: theme.typo.inter.bodySmall.copyWith(
                        color: UIColorsToken.yellow.withValues(alpha: 0.3),
                      ),
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

  String? _legalStatusLabel(AppLocale l10n, MosqueLegalStatus? status) =>
      switch (status) {
        MosqueLegalStatus.association1901 => l10n.mosque_legal_status_1901,
        MosqueLegalStatus.association1905 => l10n.mosque_legal_status_1905,
        MosqueLegalStatus.other => l10n.mosque_legal_status_other,
        null => null,
      };

  /// `@local` from the account email, otherwise the mosque city, otherwise null.
  String? _handle(String? fallback, String? email) {
    if (email != null && email.contains('@')) {
      return '@${email.split('@').first}';
    }
    final trimmed = fallback?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    return '@${trimmed.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}';
  }
}

/// Non-tappable settings row: leading gold [icon], [label] above its [value].
/// Same card as [ProfileMenuRow] minus the chevron — legal identity is set at
/// registration and can only be changed by Nour support.
class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.icon, required this.label, this.value});

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final l10n = AppLocale.of(context);
    final display = (value?.trim().isNotEmpty ?? false)
        ? value!.trim()
        : l10n.mosque_settings_legal_missing;

    return UIGradientCard(
      padding: const EdgeInsets.all(14),
      reverseGradient: true,
      child: Row(
        children: [
          Icon(icon, size: 24, color: UIColorsToken.textYellow),
          const UISpace.horz(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.typo.inter.bodySmall
                      .copyWith(color: UIColorsToken.textParagraph),
                ),
                const UISpace.vert(2),
                Text(
                  display,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typo.inter.title
                      .copyWith(color: UIColorsToken.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
