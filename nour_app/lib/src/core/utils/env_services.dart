import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class EnvServices {
	static String supabaseUrl = getEnvValue(envKey: 'SUPABASE_URL');
	static String supabaseKey = getEnvValue(envKey: 'SUPABASE_KEY');

	static String prodBaseUrl = getEnvValue(envKey: 'BASE_URL_PROD');
	static String stgBaseUrl = getEnvValue(envKey: 'BASE_URL_STG');

	static const String _error = 'error-env-value/';


	static String getEnvValue({required String envKey}) {
		return dotenv.env[envKey] ?? _error;
	}
}
