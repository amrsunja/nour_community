import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/mosque_donation_models.dart';
import '../../data/mosque_repo.dart';
import '../state_management/mosque_profile_provider.dart';
import '../widgets/mosque_donation_widgets.dart';
import '../widgets/mosque_format.dart';
import '../widgets/mosque_header.dart';

/// Public campaign page (devis B3): cover, progress, description, recent
/// donors, updates, amount picker → checkout. Realtime progress.
@RoutePage()
class MosqueCampaignPage extends HookConsumerWidget {
  const MosqueCampaignPage({super.key, @PathParam('id') required this.mosqueId, @PathParam('campaignId') required this.campaignId});

  final int mosqueId;
  final int campaignId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final appEvents = ref.read(appEventProvider);
    final repo = ref.read(mosqueRepoProvider);
    final mosque = ref.watch(mosqueProfileProvider(mosqueId).select((s) => s.mosque));
    final profilePresenter = ref.read(mosqueProfileProvider(mosqueId).notifier);

    final campaign = useState<MosqueCampaignModel?>(null);
    final updates = useState<List<MosqueCampaignUpdate>>(const []);
    final donors = useState<List<MosqueCampaignDonor>>(const []);
    final amount = useState<double>(50);
    final failed = useState(false);

    useEffect(() {
      StreamSubscription? sub;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        profilePresenter.init(trackView: false);
        final res = await repo.getCampaign(campaignId);
        res.when((c) {
          campaign.value = c;
          amount.value = (c.suggestedAmounts.length > 1 ? c.suggestedAmounts[1] : (c.suggestedAmounts.firstOrNull ?? 50)).toDouble();
        }, (e) {
          failed.value = true;
          appEvents.send(ShowErrorEvent(e));
        });
        (await repo.getCampaignUpdates(campaignId)).when((v) => updates.value = v, (_) {});
        donors.value = await repo.getCampaignRecentDonors(campaignId);
        sub = repo.watchCampaign(campaignId).listen((c) {
          if (c != null) campaign.value = c;
        });
      });
      return () => sub?.cancel();
    }, const []);

    final c = campaign.value;

    Future<void> donate() async {
      if (c == null) return;
      final ok = await nav.toMosqueCheckout(mosqueId: mosqueId, amount: amount.value, frequency: 'oneTime', campaignId: c.id);
      if (ok == true) donors.value = await repo.getCampaignRecentDonors(campaignId);
    }

    return UIGradientLinedScaffold(
      appBar: UIAppBar(
        title: l10n.mosque_campaign_title,
        onBack: () => context.router.maybePop(),
        leadingIcons: [
          if (c != null)
            UITap(
              onTap: () => Share.share('${c.title} — ${mosque?.name ?? ''}\n$website/mosque/$mosqueId/campaign/${c.id}'),
              child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.ios_share, color: UIColorsToken.textYellow)),
            ),
        ],
      ),
      body: c == null
          ? Center(
              child: failed.value
                  ? Text(l10n.error_api_mosque_load_failed, style: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph))
                  : const UICircularProgressBar(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 4, kPageHorzPadding, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (c.coverUrl != null && c.coverUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(aspectRatio: 16 / 9, child: CachedNetworkImage(imageUrl: c.coverUrl!, fit: BoxFit.cover)),
                    ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      if (mosque != null) ...[MosqueLogo(mosque: mosque, size: 28, radius: 14), const SizedBox(width: 8)],
                      Expanded(child: Text(mosque?.name ?? '', style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph))),
                      MosqueCampaignStatusPill(campaign: c, l10n: l10n),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(c.title, style: theme.typo.inter.largeTitle.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  UIProgressLine(current: c.collectedAmount, total: c.goalAmount <= 0 ? 1 : c.goalAmount, height: 10),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(MosqueFormat.money(c.collectedAmount), style: theme.typo.inter.title.copyWith(color: UIColorsToken.textYellow, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(l10n.mosque_campaign_of_goal(MosqueFormat.money(c.goalAmount)), style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph))),
                      Text('${c.percent}%', style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (donors.value.isNotEmpty) ...[
                        SizedBox(
                          width: 24.0 + 16 * (donors.value.length - 1),
                          height: 24,
                          child: Stack(
                            children: [
                              for (var i = 0; i < donors.value.length; i++)
                                Positioned(
                                  left: 16.0 * i,
                                  child: UIAvatar(
                                    url: donors.value[i].avatarUrl,
                                    initial: (donors.value[i].name ?? 'A').isEmpty ? 'A' : donors.value[i].name!.substring(0, 1).toUpperCase(),
                                    color: UIColorsToken.bgSurface,
                                    size: 24,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          [l10n.mosque_campaign_donors_count(c.donorsCount), if (c.isOpen) l10n.mosque_campaign_days_left(c.daysLeft) else l10n.mosque_campaign_closed].join(' · '),
                          style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph),
                        ),
                      ),
                    ],
                  ),
                  if (c.description != null && c.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(c.description!, style: theme.typo.inter.body.copyWith(color: UIColorsToken.white, height: 1.45)),
                  ],

                  // Give
                  if (c.isOpen) ...[
                    const SizedBox(height: 22),
                    UICard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.mosque_campaign_contribute, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          MosqueAmountPicker(amounts: c.suggestedAmounts, value: amount.value, onChanged: (v) => amount.value = v, l10n: l10n),
                          const SizedBox(height: 16),
                          UIButton.primary(label: l10n.mosque_donation_give(MosqueFormat.money(amount.value)), fullWidth: true, onTap: amount.value > 0 ? donate : null),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        c.isFunded ? l10n.mosque_campaign_funded_note : l10n.mosque_campaign_ended_note,
                        style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
                      ),
                    ),
                  ],

                  // Updates
                  if (updates.value.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    MosqueSectionHeader(title: l10n.mosque_campaign_updates),
                    const SizedBox(height: 10),
                    for (final u in updates.value) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (u.imageUrl != null) ...[
                              ClipRRect(borderRadius: BorderRadius.circular(10), child: CachedNetworkImage(imageUrl: u.imageUrl!, fit: BoxFit.cover)),
                              const SizedBox(height: 8),
                            ],
                            Text(u.body, style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.white)),
                            const SizedBox(height: 4),
                            Text(MosqueFormat.timeAgo(u.createdAt, l10n), style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                  const SizedBox(height: 12),
                  Center(child: Text(l10n.mosque_donation_secure_note, textAlign: TextAlign.center, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph))),
                ],
              ),
            ),
    );
  }
}
