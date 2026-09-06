import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/mosques/data/models/mosque_member_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state_management/mosque_admin_community_provider.dart';

/// Admin Community tab (Figma "Community - Nour mosques").
@RoutePage()
class MosqueAdminCommunityPage extends HookConsumerWidget {
  const MosqueAdminCommunityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final presenter = ref.read(mosqueAdminCommunityProvider.notifier);
    final state = ref.watch(mosqueAdminCommunityProvider);
    final lang = Localizations.localeOf(context).languageCode;

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => presenter.load());
      return null;
    }, const []);

    Future<void> exportCsv() async {
      final csv = await presenter.exportMembersCsv();
      if (csv == null) return;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/members_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv');
      await file.writeAsString(csv);
      await Share.shareXFiles([XFile(file.path, mimeType: 'text/csv')]);
    }

    Future<void> onMenu(MosqueCommunityMember m) async {
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
                leading: const Icon(Icons.badge_outlined, color: UIColorsToken.textYellow),
                title: Text(m.name ?? '', style: theme.typo.inter.title.copyWith(color: UIColorsToken.white)),
                subtitle: Text(
                  [if (m.email != null) m.email!, if (m.phone != null) m.phone!, if (m.volunteer) l10n.mosque_admin_filter_volunteers].join(' · '),
                  style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph),
                ),
              ),
              if (m.email != null)
                ListTile(
                  leading: const Icon(Icons.mail_outline, color: UIColorsToken.white),
                  title: Text(l10n.mosque_action_email, style: theme.typo.inter.body.copyWith(color: UIColorsToken.white)),
                  onTap: () => Navigator.of(ctx).pop('email'),
                ),
              if (m.phone != null)
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: UIColorsToken.white),
                  title: Text(l10n.mosque_action_call, style: theme.typo.inter.body.copyWith(color: UIColorsToken.white)),
                  onTap: () => Navigator.of(ctx).pop('call'),
                ),
              if (m.isMember)
                ListTile(
                  leading: const Icon(Icons.person_remove_outlined, color: UIColorsToken.red),
                  title: Text(l10n.mosque_admin_remove_member, style: theme.typo.inter.body.copyWith(color: UIColorsToken.red)),
                  onTap: () => Navigator.of(ctx).pop('remove'),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
      switch (action) {
        case 'email':
          await launchUrl(Uri.parse('mailto:${m.email}'));
        case 'call':
          await launchUrl(Uri.parse('tel:${m.phone}'));
        case 'remove':
          await presenter.removeMember(m);
      }
    }

    final filters = [
      (CommunityFilter.all, l10n.mosque_admin_filter_all),
      (CommunityFilter.followers, l10n.mosque_admin_filter_followers),
      (CommunityFilter.members, l10n.mosque_admin_filter_members),
      (CommunityFilter.volunteers, l10n.mosque_admin_filter_volunteers),
    ];

    return UIGradientLinedScaffold(
      appBar: UIAppBar(
        title: l10n.mosque_admin_tab_community,
        leadingIcons: [
          UITap(onTap: exportCsv, child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.download_outlined, color: UIColorsToken.textYellow))),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 4, kPageHorzPadding, 0),
            child: UIInputField(
              hintText: l10n.mosque_admin_search_community,
              onChanged: presenter.setQuery,
              textInputAction: TextInputAction.search,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
              children: [
                for (final f in filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: UITap(
                      onTap: () => presenter.setFilter(f.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: state.filter == f.$1 ? UIColorsToken.bgPriYellow : null,
                          color: state.filter == f.$1 ? null : Colors.transparent,
                        ),
                        child: Text(f.$2,
                            style: theme.typo.inter.bodyMedium.copyWith(color: state.filter == f.$1 ? UIColorsToken.black : UIColorsToken.white)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: state.isLoading && state.items.isEmpty
                ? const Center(child: UICircularProgressBar())
                : state.items.isEmpty
                    ? Center(child: Text(l10n.mosque_admin_community_empty, style: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph)))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 4, kPageHorzPadding, 120),
                        physics: const BouncingScrollPhysics(),
                        itemCount: state.items.length + (state.hasMore ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          if (i >= state.items.length) {
                            return UIButton.textual(label: l10n.common_load_more, fullWidth: true, onTap: () => presenter.load(more: true));
                          }
                          final m = state.items[i];
                          return UICard(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            onTap: () => onMenu(m),
                            child: Row(
                              children: [
                                ClipOval(
                                  child: SizedBox(
                                    width: 44,
                                    height: 44,
                                    child: m.avatarUrl != null
                                        ? CachedNetworkImage(imageUrl: m.avatarUrl!, fit: BoxFit.cover)
                                        : Container(
                                            color: _color(m.userId),
                                            alignment: Alignment.center,
                                            child: Text(m.initials, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(m.name ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis,
                                                style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: m.isMember ? UIColorsToken.textYellowDarker : Colors.transparent,
                                              border: Border.all(color: m.isMember ? UIColorsToken.textYellowDarker : UIColorsToken.stroke),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              m.isMember ? l10n.mosque_member_badge : l10n.mosque_follower_badge,
                                              style: theme.typo.inter.smallCaption.copyWith(color: m.isMember ? UIColorsToken.textYellow : UIColorsToken.textParagraph),
                                            ),
                                          ),
                                          if (m.volunteer) ...[
                                            const SizedBox(width: 6),
                                            const Icon(Icons.volunteer_activism_outlined, size: 14, color: UIColorsToken.textYellow),
                                          ],
                                        ],
                                      ),
                                      Text(l10n.mosque_since_year(m.since.year),
                                          style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.more_vert, color: UIColorsToken.textParagraph, size: 18),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  static Color _color(String id) {
    const palette = [Color(0xffC59F54), Color(0xff2E8BC0), Color(0xffE0555A), Color(0xff5BA55B), Color(0xff8E6CD1)];
    return palette[id.hashCode.abs() % palette.length];
  }
}

