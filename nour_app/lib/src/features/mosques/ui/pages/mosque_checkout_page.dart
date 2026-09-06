import 'dart:io' show Platform;

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/features/impact/ui/widgets/impact_money.dart';
import 'package:nour/src/features/payments/data/models/tx_enums.dart';
import 'package:nour/src/features/payments/ui/state_management/checkout_state.dart';
import 'package:nour/src/features/payments/ui/widgets/checkout_widgets.dart';

import '../../data/models/mosque_donation_models.dart';
import '../../data/mosque_repo.dart';
import '../state_management/mosque_checkout_provider.dart';
import '../state_management/mosque_profile_provider.dart';
import '../widgets/mosque_header.dart';

/// Mosque checkout (devis B2/B3/B6) — `mosque/:id/checkout?amount=&frequency=&campaignId=&membershipId=`.
///
/// Direct charge on the mosque's Stripe Connect account: no platform fee,
/// no "cover fees" option. Success shows a thank-you card and pops back.
@RoutePage()
class MosqueCheckoutPage extends HookConsumerWidget {
  const MosqueCheckoutPage({
    super.key,
    @PathParam('id') required this.mosqueId,
    @QueryParam('amount') this.amount = 10,
    @QueryParam('frequency') this.frequency = 'oneTime',
    @QueryParam('campaignId') this.campaignId,
    @QueryParam('membershipId') this.membershipId,
  });

  final int mosqueId;
  final double amount;
  final String frequency;
  final int? campaignId;
  final int? membershipId;

  DonationFrequency get _frequency => DonationFrequency.values.firstWhere((f) => f.name == frequency, orElse: () => DonationFrequency.oneTime);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final typo = UITheme.of(context).typo;
    final nav = ref.read(navigationServicesProvider);

    final args = MosqueCheckoutArgs(mosqueId: mosqueId, amount: amount, frequency: _frequency, campaignId: campaignId, membershipId: membershipId);
    final presenter = ref.read(mosqueCheckoutProvider(args).notifier);
    final state = ref.watch(mosqueCheckoutProvider(args));

    final profilePresenter = ref.read(mosqueProfileProvider(mosqueId).notifier);
    final mosque = ref.watch(mosqueProfileProvider(mosqueId).select((s) => s.mosque));
    final campaign = useState<MosqueCampaignModel?>(null);
    final succeeded = useState(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => profilePresenter.init());
      if (campaignId != null) {
        ref.read(mosqueRepoProvider).getCampaign(campaignId!).then((r) => r.when((c) => campaign.value = c, (_) {}));
      }
      return null;
    }, const []);

    useOnAppLifecycleStateChange((_, current) {
      if (current == AppLifecycleState.resumed) presenter.onAppResumed();
    });

    ref.listen<CheckoutState>(mosqueCheckoutProvider(args), (prev, next) {
      if (prev?.phase != CheckoutPhase.success && next.phase == CheckoutPhase.success) {
        succeeded.value = true;
        profilePresenter.refresh();
      }
    });

    const currency = 'EUR';
    final total = state.amount;
    final title = campaign.value?.title ?? mosque?.name ?? '';
    final subtitle = args.isMembership
        ? l10n.mosque_checkout_membership_fee
        : args.isCampaign
            ? l10n.mosque_checkout_campaign_gift
            : l10n.mosque_checkout_sadaqa;

    return Scaffold(
      appBar: UIAppBar(onBack: state.isBusy ? null : () => context.router.maybePop(), title: l10n.checkout_title),
      bottomNavigationBar: succeeded.value
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.isRecurring)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        state.frequency == DonationFrequency.monthly
                            ? l10n.checkout_recurring_note_month(ImpactFormat.money(total, currency))
                            : l10n.checkout_recurring_note_year(ImpactFormat.money(total, currency)),
                        textAlign: TextAlign.center,
                        style: typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph),
                      ),
                    ),
                  UIButton.primary(
                    label: state.isBusy ? l10n.checkout_pay_button : '${l10n.checkout_pay_button} · ${ImpactFormat.money(total, currency)}',
                    fullWidth: true,
                    isBusy: state.isBusy,
                    onTap: mosque == null ? null : () => presenter.pay(currency: currency, label: title),
                  ),
                ],
              ),
            ),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: mosque == null
                ? const Center(child: UICircularProgressBar())
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckoutSectionTitle(l10n.checkout_my_donation),
                        const UISpace.vert(12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            campaign.value?.coverUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: SizedBox(width: 96, height: 96, child: CachedNetworkImage(imageUrl: campaign.value!.coverUrl!, fit: BoxFit.cover)),
                                  )
                                : MosqueLogo(mosque: mosque, size: 96, radius: 16),
                            const UISpace.horz(14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w600)),
                                  const UISpace.vert(4),
                                  Text(subtitle, style: typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph)),
                                  const UISpace.vert(12),
                                  Container(
                                    height: 46,
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(12)),
                                    child: Row(
                                      children: [
                                        CheckoutStepButton(icon: Icons.remove, onTap: state.isBusy ? null : presenter.decrement),
                                        Expanded(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              switch (state.frequency) {
                                                DonationFrequency.monthly => l10n.donate_per_month(ImpactFormat.money(state.amount, currency)),
                                                DonationFrequency.yearly => l10n.donate_per_year(ImpactFormat.money(state.amount, currency)),
                                                DonationFrequency.oneTime => ImpactFormat.money(state.amount, currency),
                                              },
                                              style: typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ),
                                        CheckoutStepButton(icon: Icons.add, onTap: state.isBusy ? null : presenter.increment),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const UISpace.vert(26),
                        if (!args.isMembership) ...[
                          CheckoutSectionTitle(l10n.checkout_options_title),
                          const UISpace.vert(12),
                          CheckoutOptionTile(
                            title: l10n.checkout_anonymous_title,
                            subtitle: l10n.checkout_anonymous_hint,
                            checked: state.isAnonymous,
                            enabled: !state.isBusy,
                            onChanged: presenter.setAnonymous,
                          ),
                          const UISpace.vert(26),
                        ],
                        CheckoutSectionTitle(l10n.checkout_payment_method),
                        const UISpace.vert(12),
                        for (final m in _methods(state)) ...[
                          CheckoutMethodTile(method: m, selected: state.method == m, enabled: !state.isBusy, l10n: l10n, onTap: () => presenter.setMethod(m)),
                          const UISpace.vert(10),
                        ],
                        const UISpace.vert(8),
                        Center(
                          child: Text(
                            l10n.mosque_checkout_direct_note(mosque.name),
                            textAlign: TextAlign.center,
                            style: typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          if (state.phase == CheckoutPhase.processing || state.phase == CheckoutPhase.failed)
            Positioned.fill(
              child: CheckoutStatusOverlay(
                failed: state.phase == CheckoutPhase.failed,
                timedOut: state.timedOut && state.phase != CheckoutPhase.failed,
                l10n: l10n,
                onKeepWaiting: presenter.keepWaiting,
                onCheckLater: () {
                  presenter.reset();
                  nav.toMyDonations(replace: true);
                },
                onRetry: presenter.reset,
              ),
            ),
          if (succeeded.value)
            Positioned.fill(
              child: _SuccessOverlay(
                l10n: l10n,
                amountLabel: ImpactFormat.money(state.amount, currency),
                mosqueName: mosque?.name ?? '',
                isMembership: args.isMembership,
                onDone: () => context.router.maybePop(true),
              ),
            ),
        ],
      ),
    );
  }

  static List<PaymentMethodKind> _methods(CheckoutState state) => [
        PaymentMethodKind.card,
        if (Platform.isIOS && state.applePayAvailable) PaymentMethodKind.applePay,
        if (Platform.isAndroid && state.googlePayAvailable) PaymentMethodKind.googlePay,
      ];
}

class _SuccessOverlay extends StatelessWidget {
  const _SuccessOverlay({required this.l10n, required this.amountLabel, required this.mosqueName, required this.isMembership, required this.onDone});

  final AppLocale l10n;
  final String amountLabel;
  final String mosqueName;
  final bool isMembership;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Container(
      color: UIColorsToken.bgPrimary.withValues(alpha: 0.96),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(28),
      child: UIAppearAnimation(
        child: UICard(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite, color: UIColorsToken.textYellow, size: 48),
              const UISpace.vert(16),
              Text(l10n.mosque_checkout_success_title, textAlign: TextAlign.center, style: typo.inter.title.copyWith(color: UIColorsToken.white)),
              const UISpace.vert(8),
              Text(
                isMembership ? l10n.mosque_checkout_success_membership(amountLabel, mosqueName) : l10n.mosque_checkout_success_message(amountLabel, mosqueName),
                textAlign: TextAlign.center,
                style: typo.inter.bodyMedium.copyWith(color: UIColorsToken.textParagraph),
              ),
              const UISpace.vert(22),
              UIButton.primary(label: l10n.common_done, fullWidth: true, onTap: onDone),
            ],
          ),
        ),
      ),
    );
  }
}
