import 'dart:io' show Platform;

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/impact/data/datasources/impact_remote_datasource.dart';
import 'package:nour/src/features/impact/ui/state_management/impact_provider.dart';
import 'package:nour/src/features/impact/ui/widgets/impact_money.dart';

import '../../data/fee_policy.dart';
import '../../data/models/tx_enums.dart';
import '../state_management/checkout_provider.dart';
import '../state_management/checkout_state.dart';
import '../state_management/zakat_cart_provider.dart';

/// Zakat checkout — the multi-project variant of the checkout. Reads the
/// allocation from [zakatCartProvider] (set by the allocation sheet), charges
/// everything as ONE zakat PaymentIntent and, on webhook confirmation, shows
/// the zakat reward page.
@RoutePage()
class ZakatCheckoutPage extends HookConsumerWidget {
  const ZakatCheckoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final typo = UITheme.of(context).typo;
    final nav = ref.read(navigationServicesProvider);
    final langCode = Localizations.localeOf(context).languageCode;

    final cart = ref.watch(zakatCartProvider);
    if (cart == null || cart.items.isEmpty) {
      // Deep link / restored route without an allocation — nothing to pay.
      return Scaffold(
        appBar: UIAppBar(
          onBack: () => context.router.maybePop(),
          title: l10n.checkout_title,
        ),
        body: const SizedBox.shrink(),
      );
    }

    final args = CheckoutArgs(
      projectId: cart.items.first.project.id,
      amount: cart.allocated,
      frequency: DonationFrequency.oneTime, // zakat is never recurring
      isZakat: true,
      items: cart.paymentItems,
    );
    final presenter = ref.read(checkoutProvider(args).notifier);
    final state = ref.watch(checkoutProvider(args));

    // Wallet sheets can background the app; re-check on resume.
    useOnAppLifecycleStateChange((_, current) {
      if (current == AppLifecycleState.resumed) presenter.onAppResumed();
    });

    // Success → zakat reward page (replaces checkout so "back" lands on the
    // calculator).
    ref.listen<CheckoutState>(checkoutProvider(args), (prev, next) {
      if (prev?.phase != CheckoutPhase.success &&
          next.phase == CheckoutPhase.success) {
        ref.read(impactProvider.notifier).refresh();
        nav.toZakatReward(replace: true);
      }
    });

    const currency = 'EUR';
    final fee = state.coverFees
        ? FeePolicy.estimate(cart.allocated, state.method)
        : 0.0;
    final total = cart.allocated + fee;
    final feePreview = FeePolicy.estimate(cart.allocated, state.method);

    return Scaffold(
      appBar: UIAppBar(
        onBack: state.isBusy ? null : () => context.router.maybePop(),
        title: l10n.checkout_title,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        // min-height Column: bottomNavigationBar gives BOUNDED constraints and
        // UIButton's busy state (a Center) would expand to fill them — the
        // full-screen gold button bug. The Column makes the height unbounded
        // so the button keeps its intrinsic size while the spinner shows.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UIButton.primary(
              label: state.isBusy
                  ? l10n.checkout_pay_button
                  : '${l10n.checkout_pay_button} · ${ImpactFormat.moneyPrecise(total, currency)}',
              fullWidth: true,
              isBusy: state.isBusy,
              onTap: () => presenter.pay(
                currency: currency,
                projectTitle: l10n.zakat_checkout_title,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(l10n.zakat_checkout_my_zakat),
                  const UISpace.vert(4),
                  Text(
                    l10n.zakat_checkout_allocated_to,
                    style: typo.inter.bodySmall
                        .copyWith(color: UIColorsToken.textParagraph),
                  ),
                  const UISpace.vert(12),
                  for (final item in cart.items) ...[
                    _AllocationTile(item: item, langCode: langCode),
                    const UISpace.vert(10),
                  ],
                  const UISpace.vert(16),

                  _SectionTitle(l10n.checkout_options_title),
                  const UISpace.vert(12),
                  _OptionTile(
                    title: l10n.checkout_anonymous_title,
                    subtitle: l10n.checkout_anonymous_hint,
                    checked: state.isAnonymous,
                    enabled: !state.isBusy,
                    onChanged: presenter.setAnonymous,
                  ),
                  const UISpace.vert(10),
                  _OptionTile(
                    title: l10n.checkout_cover_fees_title(
                      ImpactFormat.moneyPrecise(feePreview, currency),
                    ),
                    subtitle: l10n.checkout_cover_fees_hint,
                    checked: state.coverFees,
                    enabled: !state.isBusy,
                    onChanged: presenter.setCoverFees,
                  ),
                  const UISpace.vert(20),

                  _SectionTitle(l10n.checkout_payment_method),
                  const UISpace.vert(12),
                  for (final m in _methods(state)) ...[
                    _MethodTile(
                      method: m,
                      selected: state.method == m,
                      enabled: !state.isBusy,
                      l10n: l10n,
                      onTap: () => presenter.setMethod(m),
                    ),
                    const UISpace.vert(10),
                  ],
                  const UISpace.vert(12),

                  // Totals breakdown (zakat / fees / total).
                  _TotalsCard(
                    zakat: cart.allocated,
                    fee: fee,
                    total: total,
                    currency: currency,
                    l10n: l10n,
                  ),
                ],
              ),
            ),
          ),

          if (state.phase == CheckoutPhase.processing ||
              state.phase == CheckoutPhase.failed)
            Positioned.fill(
              child: _StatusOverlay(
                state: state,
                l10n: l10n,
                onKeepWaiting: presenter.keepWaiting,
                onCheckLater: () {
                  presenter.reset();
                  nav.toMyDonations(replace: true);
                },
                onRetry: presenter.reset,
              ),
            ),
        ],
      ),
    );
  }

  static List<PaymentMethodKind> _methods(CheckoutState state) => [
        PaymentMethodKind.card,
        if (Platform.isIOS && state.applePayAvailable) PaymentMethodKind.applePay,
        if (Platform.isAndroid && state.googlePayAvailable)
          PaymentMethodKind.googlePay,
        if (kPayPalEnabled && state.paypalAvailable) PaymentMethodKind.paypal,
      ];
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Text(
      text,
      style: typo.inter.title.copyWith(
        color: UIColorsToken.white,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _AllocationTile extends StatelessWidget {
  const _AllocationTile({required this.item, required this.langCode});

  final ZakatCartItem item;
  final String langCode;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final p = item.project;
    final cover = ImpactRemoteDatasource.publicStoryImageUrl(
      p.galleryImages.isNotEmpty ? p.galleryImages.first : p.coverImageUrl,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: UIColorsToken.bgSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 64,
              height: 48,
              child: cover != null
                  ? CachedNetworkImage(imageUrl: cover, fit: BoxFit.cover)
                  : Container(color: UIColorsToken.black80),
            ),
          ),
          const UISpace.horz(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title(langCode),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typo.inter.bodyMedium.copyWith(
                    color: UIColorsToken.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (p.subtitle(langCode).isNotEmpty) ...[
                  const UISpace.vert(2),
                  Text(
                    p.subtitle(langCode),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: typo.inter.bodySmall
                        .copyWith(color: UIColorsToken.textParagraph),
                  ),
                ],
              ],
            ),
          ),
          const UISpace.horz(10),
          Text(
            ImpactFormat.money(item.amount, p.currency),
            style: typo.inter.title.copyWith(
              color: UIColorsToken.textYellow,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({
    required this.zakat,
    required this.fee,
    required this.total,
    required this.currency,
    required this.l10n,
  });

  final double zakat;
  final double fee;
  final double total;
  final String currency;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;

    Widget line(String label, String value, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: typo.inter.bodyMedium.copyWith(
                  color: bold
                      ? UIColorsToken.white
                      : UIColorsToken.textParagraph,
                ),
              ),
              Text(
                value,
                style: (bold ? typo.inter.title : typo.inter.bodyMedium)
                    .copyWith(
                  color: UIColorsToken.white,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        );

    return Column(
      children: [
        line(l10n.donate_type_zakat, ImpactFormat.moneyPrecise(zakat, currency)),
        if (fee > 0)
          line(l10n.zakat_checkout_fees, ImpactFormat.moneyPrecise(fee, currency)),
        Divider(color: UIColorsToken.white.withValues(alpha: 0.12), height: 16),
        line(
          l10n.zakat_checkout_total,
          ImpactFormat.moneyPrecise(total, currency),
          bold: true,
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.title,
    required this.subtitle,
    required this.checked,
    required this.enabled,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool checked;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return UITap(
      onTap: enabled ? () => onChanged(!checked) : null,
      child: UISelecteableCard(
        selected: checked,
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: checked
                      ? UIColorsToken.textYellow
                      : UIColorsToken.textParagraph,
                  width: 1.5,
                ),
              ),
              child: checked
                  ? const Icon(Icons.check,
                      size: 16, color: UIColorsToken.textYellow)
                  : null,
            ),
            const UISpace.horz(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: typo.inter.title.copyWith(
                      color: checked
                          ? UIColorsToken.textYellow
                          : UIColorsToken.white,
                    ),
                  ),
                  const UISpace.vert(2),
                  Text(
                    subtitle,
                    style: typo.inter.bodySmall
                        .copyWith(color: UIColorsToken.textParagraph),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.method,
    required this.selected,
    required this.enabled,
    required this.l10n,
    required this.onTap,
  });

  final PaymentMethodKind method;
  final bool selected;
  final bool enabled;
  final AppLocale l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final label = switch (method) {
      PaymentMethodKind.paypal => l10n.checkout_method_paypal,
      PaymentMethodKind.card => l10n.checkout_method_card,
      PaymentMethodKind.applePay => l10n.checkout_method_apple_pay,
      PaymentMethodKind.googlePay => l10n.checkout_method_google_pay,
    };
    final Widget mark = switch (method) {
      PaymentMethodKind.paypal =>
        const Icon(Icons.paypal, color: Color(0xff003087), size: 26),
      PaymentMethodKind.card =>
        const Icon(Icons.credit_card, color: Color(0xff2A5DB0), size: 26),
      PaymentMethodKind.applePay =>
        Image.asset(Assets.images.apple.path, width: 24, height: 24),
      PaymentMethodKind.googlePay =>
        Image.asset(Assets.images.google.path, width: 24, height: 24),
    };

    return UITap(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: UIColorsToken.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? UIColorsToken.textYellow : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: UIColorsToken.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: mark,
            ),
            const UISpace.horz(14),
            Expanded(
              child: Text(
                label,
                style: typo.inter.title.copyWith(color: UIColorsToken.white),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? UIColorsToken.textYellow
                      : UIColorsToken.textParagraph,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: UIColorsToken.textYellow,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusOverlay extends StatelessWidget {
  const _StatusOverlay({
    required this.state,
    required this.l10n,
    required this.onKeepWaiting,
    required this.onCheckLater,
    required this.onRetry,
  });

  final CheckoutState state;
  final AppLocale l10n;
  final VoidCallback onKeepWaiting;
  final VoidCallback onCheckLater;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final failed = state.phase == CheckoutPhase.failed;
    final timedOut = state.timedOut && !failed;

    final title = failed
        ? l10n.donate_failed_title
        : timedOut
            ? l10n.checkout_timeout_title
            : l10n.checkout_processing_title;
    final message = failed
        ? l10n.donate_failed_message
        : timedOut
            ? l10n.checkout_timeout_message
            : l10n.checkout_processing_message;

    return Container(
      color: UIColorsToken.bgPrimary.withValues(alpha: 0.92),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(28),
      child: UICard(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (failed)
              const Icon(Icons.error_outline, color: UIColorsToken.red, size: 48)
            else if (timedOut)
              const Icon(Icons.hourglass_bottom,
                  color: UIColorsToken.textYellow, size: 48)
            else
              const UICircularProgressBar(
                  color: UIColorsToken.textYellow, size: 40),
            const UISpace.vert(16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: typo.inter.title.copyWith(color: UIColorsToken.white),
            ),
            const UISpace.vert(8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: typo.inter.bodyMedium
                  .copyWith(color: UIColorsToken.textParagraph),
            ),
            const UISpace.vert(22),
            if (failed)
              UIButton.primary(
                  label: l10n.common_retry, fullWidth: true, onTap: onRetry)
            else if (timedOut) ...[
              UIButton.primary(
                  label: l10n.checkout_keep_waiting,
                  fullWidth: true,
                  onTap: onKeepWaiting),
              const UISpace.vert(6),
              UIButton.textual(
                  label: l10n.checkout_check_later,
                  fullWidth: true,
                  onTap: onCheckLater),
            ],
          ],
        ),
      ),
    );
  }
}
