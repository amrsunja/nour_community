import 'package:dio_smart_retry/dio_smart_retry.dart';

import '../../../../../config/app_config.dart';

class RetryConnectionInterceptor extends RetryInterceptor {
  RetryConnectionInterceptor({
		required super.dio,
	}) : super(
		logPrint: print,
		retries: AppConfig.shared.httpRequestReries,
		retryDelays: const [
			Duration(seconds: 1),
			Duration(seconds: 3),
			Duration(seconds: 6),
			Duration(seconds: 10),
		]
	);
}
