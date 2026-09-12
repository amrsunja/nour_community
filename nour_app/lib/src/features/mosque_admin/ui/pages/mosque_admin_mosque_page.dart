import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/widgets/snackbar_provider.dart';
import 'package:nour/src/core/routing/app_router.gr.dart';
import 'package:nour/src/features/mosques/data/models/mosque_enums.dart';
import 'package:nour/src/features/mosques/data/models/mosque_post_model.dart';
import 'package:nour/src/features/mosques/ui/state_management/mosque_profile_provider.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_header.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_information_tab.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_post_card.dart';
import 'package:nour/src/features/settings/ui/state_management/app_config_provider.dart';

import '../state_management/mosque_admin_mosque_provider.dart';
import '../state_management/mosque_admin_prayers_provider.dart';
import '../widgets/admin_edit_sheets.dart';
import '../widgets/mosque_admin_donation_tab.dart';
import '../widgets/prayer_schedule_editor.dart';

/// Admin "Mosque" tab: the public profile in edit mode (Figma
/// "Mosquée profile - Prayers / Information / News / Donation" admin frames).
@RoutePage()
class MosqueAdminMosquePage extends HookConsumerWidget {
  const MosqueAdminMosquePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final snackbar = ref.read(snackbarProvider);
    final my = ref.watch(myMosqueProvider);
    final mosqueId = my.mosque?.id;
    final donationsFlag = ref.watch(appConfigProvider.select((c) => c.mosqueDonationsEnabled));
    final tab = useState(MosqueTab.prayers);

    if (mosqueId == null) {
      return const UIGradientLinedScaffold(body: Center(child: UICircularProgressBar()));
    }

    final profilePresenter = ref.read(mosqueProfileProvider(mosqueId).notifier);
    final profile = ref.watch(mosqueProfileProvider(mosqueId));
    final admin = ref.read(mosqueAdminMosqueProvider.notifier);
    final adminState = ref.watch(mosqueAdminMosqueProvider);
    // Keep the (autoDispose) prayers provider alive for the whole page, not
    // just while the Prayers tab is mounted - otherwise switching to News /
    // Information disposes the loaded schedule and coming back shows nothing.
    // Loading itself is owned by [PrayerScheduleEditor].
    ref.watch(mosqueAdminPrayersProvider.select((s) => s.isLoading));

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        profilePresenter.init(trackView: false);
        admin.loadQuota();
      });
      return null;
    }, const []);

    // The header shows the freshest copy (myMosque is updated on every save).
    final mosque = my.mosque ?? profile.mosque;
    if (mosque == null) {
      return const UIGradientLinedScaffold(body: Center(child: UICircularProgressBar()));
    }

    Future<void> onPostMenu(MosquePostModel p) async {
      final quota = adminState.quota;
      final action = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: UIColorsToken.bgSurface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: UIColorsToken.white),
                title: Text(l10n.common_edit, style: theme.typo.inter.body.copyWith(color: UIColorsToken.white)),
                onTap: () => Navigator.of(ctx).pop('edit'),
              ),
              if (p.notifiedAt == null && p.status == MosquePostStatus.published)
                ListTile(
                  leading: const Icon(Icons.notifications_active_outlined, color: UIColorsToken.textYellow),
                  title: Text(l10n.mosque_post_notify_followers, style: theme.typo.inter.body.copyWith(color: UIColorsToken.white)),
                  subtitle: Text(
                    quota == null
                        ? ''
                        : quota.exhausted
                            ? l10n.error_api_mosque_broadcast_quota_exceeded
                            : l10n.mosque_post_quota_left(quota.remaining, quota.limit),
                    style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph),
                  ),
                  enabled: quota == null || !quota.exhausted,
                  onTap: () => Navigator.of(ctx).pop('notify'),
                ),
              if (p.status == MosquePostStatus.published)
                ListTile(
                  leading: const Icon(Icons.archive_outlined, color: UIColorsToken.white),
                  title: Text(l10n.mosque_post_archive, style: theme.typo.inter.body.copyWith(color: UIColorsToken.white)),
                  onTap: () => Navigator.of(ctx).pop('archive'),
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: UIColorsToken.red),
                title: Text(l10n.common_delete, style: theme.typo.inter.body.copyWith(color: UIColorsToken.red)),
                onTap: () => Navigator.of(ctx).pop('delete'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
      switch (action) {
        case 'edit':
          if (context.mounted) context.router.push(MosqueAdminPostFormRoute(type: p.type.dbValue, postId: p.id));
        case 'notify':
          final n = await admin.notifyPost(p);
          if (n != null) snackbar.showSuccess(l10n.mosque_post_notified(n));
        case 'archive':
          await admin.archivePost(p);
        case 'delete':
          await admin.deletePost(p);
      }
    }

    Widget body = switch (tab.value) {
      MosqueTab.prayers => const PrayerScheduleEditor(),
      MosqueTab.information => MosqueInformationTab(
          mosque: mosque,
          l10n: l10n,
          editable: true,
          onEditCapacity: () async {
            final r = await AdminEditSheets.capacity(context, l10n: l10n, total: mosque.capacityTotal, men: mosque.capacityMen, women: mosque.capacityWomen);
            if (r != null) await admin.setCapacity(total: r.$1, men: r.$2, women: r.$3);
          },
          onEditFounded: () async {
            final y = await AdminEditSheets.founded(context, l10n: l10n, year: mosque.foundedYear);
            if (y != null) await admin.setFounded(y);
          },
          onToggleService: admin.toggleService,
          onEditLanguages: () async {
            final codes = await AdminEditSheets.languages(context, l10n: l10n, selected: mosque.khutbahLanguages);
            if (codes != null) await admin.setLanguages(codes);
          },
          onEditImam: (imam) async {
            final r = await AdminEditSheets.imam(context, l10n: l10n, mosqueId: mosque.id, existing: imam, upload: (f) => admin.upload(f, folder: 'imams'));
            if (r == null) return;
            if (r.id == AdminEditSheets.deleteImam) {
              await admin.deleteImam(imam.id);
            } else {
              await admin.upsertImam(r);
            }
          },
          onAddImam: () async {
            final r = await AdminEditSheets.imam(context, l10n: l10n, mosqueId: mosque.id, upload: (f) => admin.upload(f, folder: 'imams'));
            if (r != null) await admin.upsertImam(r);
          },
        ),
      MosqueTab.news => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              if (!profile.postsLoaded)
                const Padding(padding: EdgeInsets.all(24), child: UICircularProgressBar())
              else if (profile.posts.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.mosque_admin_no_posts, textAlign: TextAlign.center, style: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph)),
                )
              else
                for (final p in profile.posts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MosquePostCard(post: p, l10n: l10n, adminStats: true, onMenu: () => onPostMenu(p)),
                  ),
              UIButton.primary(label: l10n.mosque_admin_create_post, fullWidth: true, onTap: () => context.router.push(const MosqueAdminCreatePostRoute())),
            ],
          ),
        ),
      MosqueTab.donation => MosqueAdminDonationTab(mosque: mosque),
    };

    return Scaffold(
      backgroundColor: UIColorsToken.bgPrimary,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MosqueHeader(
              mosque: mosque,
              l10n: l10n,
              tab: tab.value,
              onTab: (t) => tab.value = t,
              isOpen: mosque.openingStatus != 'closed',
              showDonationTab: donationsFlag,
              newsBadge: false,
              onCopiedAddress: () => snackbar.showInfo(l10n.mosque_address_copied),
              actions: UIButton.secondary(
                label: l10n.common_edit,
                fullWidth: true,
                assetIcon: UIIconsToken.icons.squarePen,
                onTap: () => context.router.push(const MosqueAdminEditProfileRoute()),
              ),
            ),
            if (adminState.isSaving) const LinearProgressIndicator(minHeight: 2, color: UIColorsToken.textYellow, backgroundColor: Colors.transparent),
            body,
          ],
        ),
      ),
    );
  }
}
