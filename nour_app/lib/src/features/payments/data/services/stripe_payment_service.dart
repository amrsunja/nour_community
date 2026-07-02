import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

/// Outcome of presenting the native Stripe PaymentSheet. Note: [completed] only
/// means the UI step finished — it is NOT proof of payment. The webhook remains
/// the single authority that flips a transaction to `succeeded`.
enum PaymentSheetResult { completed, cancelled, failed }

final stripePaymentServiceProvider = Provider<StripePaymentService>(
  (ref) => StripePaymentServiceImpl(),
);

/// Thin seam over `flutter_stripe`'s PaymentSheet so the payment repository /
/// presenter never import the SDK directly (keeps them testable and lets the
/// native integration be swapped or mocked).
abstract class StripePaymentService {
  Future<PaymentSheetResult> presentPaymentSheet({
    required String clientSecret,
  });
}

class StripePaymentServiceImpl implements StripePaymentService {
  @override
  Future<PaymentSheetResult> presentPaymentSheet({
    required String clientSecret,
  }) async {
    try {
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: kAppName,
          // Apple Pay / Google Pay can be configured here once merchant ids are
          // registered (see docs/new_payment_system_logic.md §11.1).
        ),
      );

      await stripe.Stripe.instance.presentPaymentSheet();
      return PaymentSheetResult.completed;
    } on stripe.StripeException catch (e) {
      if (e.error.code == stripe.FailureCode.Canceled) {
        return PaymentSheetResult.cancelled;
      }
      talker.error('[stripe] presentPaymentSheet', e);
      return PaymentSheetResult.failed;
    } catch (e) {
      talker.error('[stripe] presentPaymentSheet', e);
      return PaymentSheetResult.failed;
    }
  }
}
