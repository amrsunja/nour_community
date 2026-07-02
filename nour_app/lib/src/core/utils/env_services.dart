import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class EnvServices {
	static String supabaseUrl = getEnvValue(envKey: 'SUPABASE_URL');
	static String supabaseKey = getEnvValue(envKey: 'SUPABASE_KEY');

	// Stripe (client SDK / PaymentSheet). Publishable key only — the secret key
	// lives in Supabase Edge Function secrets, never in the app.
	static String stripePublishableKey = getEnvValue(envKey: 'STRIPE_PUBLISHABLE_KEY');

	static String prodBaseUrl = getEnvValue(envKey: 'BASE_URL_PROD');
	static String stgBaseUrl = getEnvValue(envKey: 'BASE_URL_STG');

	// OAuth providers
	static String googleWebClientId = getEnvValue(envKey: 'GOOGLE_WEB_CLIENT_ID');
	static String googleAndroidClientId = getEnvValue(envKey: 'GOOGLE_ANDROID_CLIENT_ID');
	static String googleIosClientId = getEnvValue(envKey: 'GOOGLE_IOS_CLIENT_ID');

	static const String _error = 'error-env-value/';


	static String getEnvValue({required String envKey}) {
		return dotenv.env[envKey] ?? _error;
	}
}
