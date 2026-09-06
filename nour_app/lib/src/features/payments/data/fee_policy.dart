import 'models/tx_enums.dart';

/// Client-side mirror of the server fee policy — DISPLAY ONLY.
///
/// The amount actually charged always comes from the edge function response
/// (`fee` / `amountCharged`); this class exists so the Checkout page can show
/// "+0.40€" instantly while the user toggles options and moves the stepper.
///
/// Keep in sync with `backend/supabase/functions/_shared/stripe.ts`.
class FeePolicy {
  const FeePolicy._();

  static const double minAmount = 1;
  static const double maxAmount = 10000;

  static double estimate(double amount, PaymentMethodKind method) {
    if (amount <= 0) return 0;
    final (pct, fixed) = switch (method) {
      PaymentMethodKind.paypal => (0.029, 0.35),
      _ => (0.015, 0.25),
    };
    return _round2(amount * pct + fixed);
  }

  static double _round2(double v) => (v * 100).roundToDouble() / 100;
}
