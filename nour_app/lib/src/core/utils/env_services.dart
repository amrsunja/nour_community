import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class EnvServices {
	static String supabaseUrl = getEnvValue(envKey: 'SUPABASE_URL');
	static String supabaseKey = getEnvValue(envKey: 'SUPABASE_KEY');

	static String prodBaseUrl = getEnvValue(envKey: 'BASE_URL_PROD');
	static String stgBaseUrl = getEnvValue(envKey: 'BASE_URL_STG');

	// OAuth providers
	static String googleWebClientId = getEnvValue(envKey: 'GOOGLE_WEB_CLIENT_ID');
	static String googleIosClientId = getEnvValue(envKey: 'GOOGLE_IOS_CLIENT_ID');
	static String appleServiceId = getEnvValue(envKey: 'APPLE_SERVICE_ID');

	static const String _error = 'error-env-value/';


	static String getEnvValue({required String envKey}) {
		return dotenv.env[envKey] ?? _error;
	}
}
