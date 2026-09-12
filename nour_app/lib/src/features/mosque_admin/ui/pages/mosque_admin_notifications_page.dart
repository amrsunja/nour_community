import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/routing/deep_links_services.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_format.dart';
import 'package:nour/src/features/notifications/data/datasrouces/push_remote_datasource.dart';

/// Bell on the admin dashboard: the account's received pushes (approval,
/// system messages). Shared shape with a future worshipper inbox.
@RoutePage()
class MosqueAdminNotificationsPage extends HookConsumerWidget {
  const MosqueAdminNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final future = useMemoized(() => ref.read(pushRemoteDataProvider).myNotifications());
    final snap = useFuture(future);

    return Scaffold(
      appBar: UIAppBar(title: l10n.push_settings_title, onBack: () => context.router.maybePop()),
      body: snap.connectionState != ConnectionState.done
          ? const Center(child: UICircularProgressBar())
          : (snap.data ?? const []).isEmpty
              ? Center(child: Text(l10n.mosque_admin_no_notifications, style: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph)))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 40),
                  itemCount: snap.data!.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final n = snap.data![i];
                    final link = (n['data'] as Map?)?['link']?.toString();
                    return UICard(
                      padding: const EdgeInsets.all(14),
                      onTap: link == null || link.isEmpty ? null : () => ref.read(deepLinksServicesProvider).open(link),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(n['title']?.toString() ?? '', style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white))),
                              Text(
                                MosqueFormat.timeAgo(DateTime.tryParse(n['sent_at']?.toString() ?? '') ?? DateTime.now(), l10n),
                                style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph),
                              ),
                            ],
                          ),
                          if ((n['body']?.toString() ?? '').isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(n['body'].toString(), style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
                          ],
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
