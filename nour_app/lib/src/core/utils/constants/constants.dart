const String kAppName = 'Nour';

const String website = 'https://nour-community.com';
//const String kCopyrightInfoUrl = 'https://';

// Support
const String kSupportEmail = 'contact@nour-community.com';
const String kSupportSubject = 'Nour — Help & Support';
const String kSupportUrl = 'mailto:$kSupportEmail';

// Legal / info (opened in an in-app web view)
const String kTermsOfUseUrl = '$website/terms-of-use';
const String kPrivacyPolicyUrl = '$website/privacy-policy';
const String kAboutSawmUrl = '$website/about';

const double kPageHorzPadding = 16;



// ── Payments (Stripe) ────────────────────────────────────────────────────────
/// Apple Pay merchant id registered in the Apple Developer portal + Stripe.
const String kStripeMerchantIdentifier = 'merchant.com.nourcommunity.nour';
/// URL scheme Stripe returns to after redirect flows (PayPal, 3DS).
const String kStripeUrlScheme = 'nour';
/// Merchant country (ISO 3166-1 alpha-2) for Apple Pay / Google Pay.
const String kStripeMerchantCountryCode = 'FR';
/// PayPal via Stripe requires it to be enabled on the (EU) Stripe account.
/// Flip to false to hide the PayPal row in the checkout picker.
const bool kPayPalEnabled = true;
