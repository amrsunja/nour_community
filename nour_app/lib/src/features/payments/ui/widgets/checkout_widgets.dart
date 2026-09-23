import 'package:flutter/material.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

import '../../data/models/tx_enums.dart';

/// Building blocks shared by the impact checkout and the mosque checkout
/// (P3). Extracted verbatim from `checkout_page.dart`.

class CheckoutSectionTitle extends StatelessWidget {
  const CheckoutSectionTitle(this.text, {super.key});

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

class CheckoutStepButton extends StatelessWidget {
  const CheckoutStepButton({super.key, required this.icon, required this.onTap});

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

class CheckoutOptionTile extends StatelessWidget {
  const CheckoutOptionTile({
    super.key,
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

class CheckoutMethodTile extends StatelessWidget {
  const CheckoutMethodTile({
    super.key,
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
            CheckoutMethodLogo(method: method),
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
class CheckoutMethodLogo extends StatelessWidget {
  const CheckoutMethodLogo({super.key, required this.method});

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

class CheckoutStatusOverlay extends StatelessWidget {
  const CheckoutStatusOverlay({
    super.key,
    required this.failed,
    required this.timedOut,
    required this.l10n,
    required this.onKeepWaiting,
    required this.onCheckLater,
    required this.onRetry,
  });

  final bool failed;
  final bool timedOut;
  final AppLocale l10n;
  final VoidCallback onKeepWaiting;
  final VoidCallback onCheckLater;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;

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
