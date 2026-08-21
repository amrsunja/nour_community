import 'dart:io' show Platform;

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/config/app_config.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/core/utils/env_services.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import '../models/tx_enums.dart';

/// Outcome of a client-side confirmation step. Note: [completed] only means the
/// UI step finished — it is NOT proof of payment. The webhook remains the
/// single authority that flips a transaction to `succeeded`.
enum PaymentSheetResult { completed, cancelled, failed }

final stripePaymentServiceProvider = Provider<StripePaymentService>(
  (ref) => StripePaymentServiceImpl(),
);

/// Everything the app needs to confirm a PaymentIntent for the method the donor
/// picked. Every method runs on the same server pipeline; only the client
/// confirmation call differs:
///
/// * card       → Stripe PaymentSheet (PI restricted to `['card']` server-side)
/// * apple_pay  → `confirmPlatformPayPaymentIntent` (native Apple Pay sheet)
/// * google_pay → `confirmPlatformPayPaymentIntent` (native Google Pay sheet)
/// * paypal     → `confirmPayment(PaymentMethodParams.payPal)` (browser redirect,
///                returns through `Stripe.urlScheme`)
///
/// The presenter / repository never import the SDK directly (testable seam).
abstract class StripePaymentService {
  /// Whether the SDK was initialised with a publishable key.
  bool get isConfigured;

  /// Platform + device support for the wallet buttons (drives the picker).
  Future<bool> isApplePaySupported();
  Future<bool> isGooglePaySupported();

  Future<PaymentSheetResult> confirm({
    required PaymentMethodKind method,
    required String clientSecret,
    required double amount,
    required String currency,
    required String label,
    String? customerId,
    String? customerEphemeralKeySecret,
  });
}

class StripePaymentServiceImpl implements StripePaymentService {
  /// Mirrors the guard in `main.dart`: the SDK is only initialised when a real
  /// publishable key is present in `.env`.
  @override
  bool get isConfigured => EnvServices.stripePublishableKey.startsWith('pk_');

  @override
  Future<bool> isApplePaySupported() async {
    if (!Platform.isIOS || !isConfigured) return false;
    try {
      return await stripe.Stripe.instance.isPlatformPaySupported();
    } catch (e) {
      talker.warning('[stripe] isApplePaySupported: $e');
      return false;
    }
  }

  @override
  Future<bool> isGooglePaySupported() async {
    if (!Platform.isAndroid || !isConfigured) return false;
    try {
      return await stripe.Stripe.instance.isPlatformPaySupported(
        googlePay: stripe.IsGooglePaySupportedParams(
          testEnv: !AppConfig.shared.isProd,
        ),
      );
    } catch (e) {
      talker.warning('[stripe] isGooglePaySupported: $e');
      return false;
    }
  }

  @override
  Future<PaymentSheetResult> confirm({
    required PaymentMethodKind method,
    required String clientSecret,
    required double amount,
    required String currency,
    required String label,
    String? customerId,
    String? customerEphemeralKeySecret,
  }) async {
    try {
      switch (method) {
        case PaymentMethodKind.card:
          await _presentCardSheet(
            clientSecret: clientSecret,
            customerId: customerId,
            customerEphemeralKeySecret: customerEphemeralKeySecret,
          );
        case PaymentMethodKind.applePay:
          await stripe.Stripe.instance.confirmPlatformPayPaymentIntent(
            clientSecret: clientSecret,
            confirmParams: stripe.PlatformPayConfirmParams.applePay(
              applePay: stripe.ApplePayParams(
                merchantCountryCode: kStripeMerchantCountryCode,
                currencyCode: currency,
                cartItems: [
                  stripe.ApplePayCartSummaryItem.immediate(
                    label: label,
                    amount: amount.toStringAsFixed(2),
                  ),
                ],
              ),
            ),
          );
        case PaymentMethodKind.googlePay:
          await stripe.Stripe.instance.confirmPlatformPayPaymentIntent(
            clientSecret: clientSecret,
            confirmParams: stripe.PlatformPayConfirmParams.googlePay(
              googlePay: stripe.GooglePayParams(
                merchantCountryCode: kStripeMerchantCountryCode,
                currencyCode: currency,
                testEnv: !AppConfig.shared.isProd,
                merchantName: kAppName,
              ),
            ),
          );
        case PaymentMethodKind.paypal:
          // Opens the PayPal approval page in a browser; Stripe returns to
          // `Stripe.urlScheme` and the SDK resolves the future. If the OS kills
          // the app in between, the presenter's resume/poll path recovers.
          await stripe.Stripe.instance.confirmPayment(
            paymentIntentClientSecret: clientSecret,
            data: const stripe.PaymentMethodParams.payPal(
              paymentMethodData: stripe.PaymentMethodData(),
            ),
          );
      }
      return PaymentSheetResult.completed;
    } on stripe.StripeException catch (e) {
      if (e.error.code == stripe.FailureCode.Canceled) {
        return PaymentSheetResult.cancelled;
      }
      talker.error('[stripe] confirm ${method.value}', e);
      return PaymentSheetResult.failed;
    } catch (e) {
      talker.error('[stripe] confirm ${method.value}', e);
      return PaymentSheetResult.failed;
    }
  }

  Future<void> _presentCardSheet({
    required String clientSecret,
    String? customerId,
    String? customerEphemeralKeySecret,
  }) async {
    await stripe.Stripe.instance.initPaymentSheet(
      paymentSheetParameters: stripe.SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: kAppName,
        // Customer context is only sent for recurring donations so the saved
        // card can be reused; one-time payments stay guest checkouts.
        customerId: customerId,
        customerEphemeralKeySecret: customerEphemeralKeySecret,
        returnURL: '$kStripeUrlScheme://stripe-redirect',
        style: ThemeMode.dark,
        appearance: _appearance,
      ),
    );
    await stripe.Stripe.instance.presentPaymentSheet();
  }

  /// Dark PaymentSheet skin aligned with the app tokens (gold CTA on black).
  static final _appearance = stripe.PaymentSheetAppearance(
    colors: stripe.PaymentSheetAppearanceColors(
      background: UIColorsToken.bgPrimary,
      componentBackground: UIColorsToken.bgSurface,
      componentBorder: UIColorsToken.bgSurface,
      componentDivider: UIColorsToken.bgSurface,
      primary: UIColorsToken.textYellow,
      primaryText: UIColorsToken.white,
      secondaryText: UIColorsToken.textParagraph,
      componentText: UIColorsToken.white,
      placeholderText: UIColorsToken.textParagraph,
      icon: UIColorsToken.textParagraph,
      error: UIColorsToken.red,
    ),
    shapes: const stripe.PaymentSheetShape(borderRadius: 12, borderWidth: 0.5),
    primaryButton: stripe.PaymentSheetPrimaryButtonAppearance(
      shapes: const stripe.PaymentSheetPrimaryButtonShape(blurRadius: 0, borderWidth: 0),
      colors: stripe.PaymentSheetPrimaryButtonTheme(
        light: stripe.PaymentSheetPrimaryButtonThemeColors(
          background: UIColorsToken.yellow,
          text: UIColorsToken.black,
        ),
        dark: stripe.PaymentSheetPrimaryButtonThemeColors(
          background: UIColorsToken.yellow,
          text: UIColorsToken.black,
        ),
      ),
    ),
  );
}
