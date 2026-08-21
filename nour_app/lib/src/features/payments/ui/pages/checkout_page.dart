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
import 'package:nour/src/features/impact/data/models/impact_project_model.dart';
import 'package:nour/src/features/impact/ui/state_management/impact_project_detail_provider.dart';
import 'package:nour/src/features/impact/ui/state_management/impact_provider.dart';
import 'package:nour/src/features/impact/ui/widgets/impact_money.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';

import '../../data/fee_policy.dart';
import '../../data/models/tx_enums.dart';
import '../state_management/checkout_provider.dart';
import '../state_management/checkout_state.dart';

/// Step 2 of the donation flow — summary + options + payment method.
///
/// Route: `checkout/:projectId?amount=&frequency=&zakat=`. The project itself
/// comes from [impactProjectDetailProvider] (already loaded when we arrive from
/// the detail page; lazily loaded on deep links).
@RoutePage()
class CheckoutPage extends HookConsumerWidget {
  const CheckoutPage({
    super.key,
    @PathParam('projectId') required this.projectId,
    @QueryParam('amount') this.amount = 10,
    @QueryParam('frequency') this.frequency = 'oneTime',
    @QueryParam('zakat') this.isZakat = false,
  });

  final int projectId;
  final double amount;

  /// `oneTime` | `monthly` | `yearly` (see [DonationFrequency.name]).
  final String frequency;

  /// Hidden in the impact-project flow; the zakat calculator sets it.
  final bool isZakat;

  DonationFrequency get _frequency => DonationFrequency.values.firstWhere(
        (f) => f.name == frequency,
        orElse: () => DonationFrequency.oneTime,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final typo = UITheme.of(context).typo;
    final nav = ref.read(navigationServicesProvider);
    final langCode = Localizations.localeOf(context).languageCode;

    final args = CheckoutArgs(
      projectId: projectId,
      amount: amount,
      frequency: _frequency,
      isZakat: isZakat,
    );
    final presenter = ref.read(checkoutProvider(args).notifier);
    final state = ref.watch(checkoutProvider(args));

    final detailPresenter = ref.read(impactProjectDetailProvider(projectId).notifier);
    final project = ref.watch(
      impactProjectDetailProvider(projectId).select((s) => s.project),
    );
    final avatarUrl = ref.watch(profileProvider.select((s) => s.profile?.avatar));

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => detailPresenter.init());
      return null;
    }, const []);

    // Wallet sheets / PayPal browser can background the app; re-check on resume.
    useOnAppLifecycleStateChange((_, current) {
      if (current == AppLifecycleState.resumed) presenter.onAppResumed();
    });

    // Success → reward page (replaces checkout so "back" lands on the project).
    ref.listen<CheckoutState>(checkoutProvider(args), (prev, next) {
      if (prev?.phase != CheckoutPhase.success && next.phase == CheckoutPhase.success) {
        detailPresenter.refresh();
        ref.read(impactProvider.notifier).refresh();
        nav.toDonationReward(
          projectId: projectId,
          amount: next.amount,
          frequency: next.frequency,
          replace: true,
        );
      }
    });

    final currency = project?.currency ?? 'EUR';
    // Display estimate; the server-quoted value is what actually gets charged.
    final feePreview = FeePolicy.estimate(state.amount, state.method);
    final total = presenter.estimatedCharged;

    return Scaffold(
      appBar: UIAppBar(
        onBack: state.isBusy ? null : () => context.router.maybePop(),
        title: l10n.checkout_title,
      ),
      bottomNavigationBar: SafeArea(
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
              label: state.isBusy
                  ? l10n.checkout_pay_button
                  : '${l10n.checkout_pay_button} · ${ImpactFormat.money(total, currency)}',
              fullWidth: true,
              isBusy: state.isBusy,
              onTap: project == null
                  ? null
                  : () => presenter.pay(
                        currency: project.currency,
                        projectTitle: project.title(langCode),
                      ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: project == null
                ? const Center(child: UICircularProgressBar())
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(l10n.checkout_my_donation),
                        const UISpace.vert(12),
                        _DonationSummaryCard(
                          project: project,
                          langCode: langCode,
                          state: state,
                          avatarUrl: avatarUrl,
                          onIncrement: presenter.increment,
                          onDecrement: presenter.decrement,
                          l10n: l10n,
                        ),
                        const UISpace.vert(26),

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
                        const UISpace.vert(26),

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
                        const UISpace.vert(8),
                        Center(
                          child: Text(
                            l10n.checkout_total(ImpactFormat.moneyPrecise(total, currency)),
                            style: typo.inter.bodyMedium.copyWith(
                              color: UIColorsToken.textParagraph,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Processing / timeout / failed overlay.
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

  /// Order mirrors the mock: PayPal, card, then the platform wallet.
  static List<PaymentMethodKind> _methods(CheckoutState state) => [
        if (kPayPalEnabled && state.paypalAvailable) PaymentMethodKind.paypal,
        PaymentMethodKind.card,
        if (Platform.isIOS && state.applePayAvailable) PaymentMethodKind.applePay,
        if (Platform.isAndroid && state.googlePayAvailable) PaymentMethodKind.googlePay,
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

class _DonationSummaryCard extends StatelessWidget {
  const _DonationSummaryCard({
    required this.project,
    required this.langCode,
    required this.state,
    required this.avatarUrl,
    required this.onIncrement,
    required this.onDecrement,
    required this.l10n,
  });

  final ImpactProjectModel project;
  final String langCode;
  final CheckoutState state;
  final String? avatarUrl;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final cover = ImpactRemoteDatasource.publicStoryImageUrl(
      project.galleryImages.isNotEmpty ? project.galleryImages.first : project.coverImageUrl,
    );
    final money = ImpactFormat.money(state.amount, project.currency);
    final amountLabel = switch (state.frequency) {
      DonationFrequency.monthly => l10n.donate_per_month(money),
      DonationFrequency.yearly => l10n.donate_per_year(money),
      DonationFrequency.oneTime => money,
    };

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 118,
                height: 118,
                child: cover != null
                    ? CachedNetworkImage(
                        imageUrl: cover,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(color: UIColorsToken.bgSurface),
                        errorWidget: (_, _, _) => Container(color: UIColorsToken.bgSurface),
                      )
                    : Container(color: UIColorsToken.bgSurface),
              ),
            ),
            const UISpace.horz(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title(langCode),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: typo.inter.title.copyWith(
                      color: UIColorsToken.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const UISpace.vert(4),
                  Text(
                    project.subtitle(langCode),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
                  ),
                  const UISpace.vert(12),
                  // Stepper
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: UIColorsToken.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _StepButton(icon: Icons.remove, onTap: state.isBusy ? null : onDecrement),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              amountLabel,
                              style: typo.inter.title.copyWith(
                                color: UIColorsToken.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        _StepButton(icon: Icons.add, onTap: state.isBusy ? null : onIncrement),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Donor avatar peeking on the right (as in the mock).
        if (avatarUrl != null && avatarUrl!.isNotEmpty && !state.isAnonymous)
          Positioned(
            right: -6,
            top: 40,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: UIColorsToken.bgSurface,
                border: Border.all(color: UIColorsToken.black80, width: 3),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(avatarUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return UITap(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          gradient: UIColorsToken.bgPriYellow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: UIColorsToken.black),
      ),
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
                  color: checked ? UIColorsToken.textYellow : UIColorsToken.textParagraph,
                  width: 1.5,
                ),
              ),
              child: checked
                  ? const Icon(Icons.check, size: 16, color: UIColorsToken.textYellow)
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
                      color: checked ? UIColorsToken.textYellow : UIColorsToken.white,
                    ),
                  ),
                  const UISpace.vert(2),
                  Text(
                    subtitle,
                    style: typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
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

    return UITap(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: UIColorsToken.bgSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _MethodLogo(method: method),
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
                  color: selected ? UIColorsToken.textYellow : UIColorsToken.textParagraph,
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

/// White rounded square with the method's mark, like the mock.
class _MethodLogo extends StatelessWidget {
  const _MethodLogo({required this.method});

  final PaymentMethodKind method;

  @override
  Widget build(BuildContext context) {
    final Widget mark = switch (method) {
      PaymentMethodKind.paypal => const Icon(Icons.paypal, color: Color(0xff003087), size: 26),
      PaymentMethodKind.card => const Icon(Icons.credit_card, color: Color(0xff2A5DB0), size: 26),
      PaymentMethodKind.applePay => Image.asset(Assets.images.apple.path, width: 24, height: 24),
      PaymentMethodKind.googlePay => Image.asset(Assets.images.google.path, width: 24, height: 24),
    };
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: UIColorsToken.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: mark,
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
              const Icon(Icons.hourglass_bottom, color: UIColorsToken.textYellow, size: 48)
            else
              const UICircularProgressBar(color: UIColorsToken.textYellow, size: 40),
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
              style: typo.inter.bodyMedium.copyWith(color: UIColorsToken.textParagraph),
            ),
            const UISpace.vert(22),
            if (failed)
              UIButton.primary(label: l10n.common_retry, fullWidth: true, onTap: onRetry)
            else if (timedOut) ...[
              UIButton.primary(label: l10n.checkout_keep_waiting, fullWidth: true, onTap: onKeepWaiting),
              const UISpace.vert(6),
              UIButton.textual(label: l10n.checkout_check_later, fullWidth: true, onTap: onCheckLater),
            ],
          ],
        ),
      ),
    );
  }
}
