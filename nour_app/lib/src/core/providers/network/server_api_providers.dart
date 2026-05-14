import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/features/auth/data/datasrouces/auth_local_datasource.dart';

import '../../network/api_config.dart';
import '../../network/server_api/interceptors/authorization_token_interceptor.dart';
import '../../network/server_api/interceptors/content_type_interceptor.dart';
import '../../network/server_api/interceptors/retry_connection_interceptor.dart';
import '../../network/server_api/server_api_cofig.dart';
import '../../network/server_api/server_api_services.dart';
import '../../network/server_api/server_api_utils.dart';


final serverApiCancelTokenProvider = Provider((ref) => CancelToken());

final serverApiUtilsProvider = Provider((ref) => ServerApiUtils(
	cancelToken: ref.read(serverApiCancelTokenProvider),
	authLocalDatasource: ref.read(authLocalDataProvider),
	ref: ref
));

final serverApiServicesProvider = Provider(
	(ref) => ServerApiServicesImpl(
		dio: ref.read(serverDioProvider),
		apiUtils: ref.read(serverApiUtilsProvider),
		cancelToken: ref.read(serverApiCancelTokenProvider)
	)
);


/// Provider only used for DIO configuration. This shouldn't be directly used
/// when sending requests, consider using [serverApiServicesProvider] for the purpose.
/// It is strongly advised to create a provider for each service, in order to
/// set custom interceptor and increase code readability.
final serverDioProvider = Provider<Dio>((ref) {
	final dio = Dio()
		..options = BaseOptions(
			baseUrl: ServerApiConfig.baseUrl,
			connectTimeout: const Duration(seconds: ApiConfig.connectTimeout),
			receiveTimeout: const Duration(seconds: ApiConfig.receiveTimeout),
		)
		..interceptors.addAll([
			ContentTypeInterceptor(
				apiUtils: ref.read(serverApiUtilsProvider),
			),
			AuthorizationInterceptor(
				apiUtils: ref.read(serverApiUtilsProvider),
			),

			//Enable http request logs
			//if (AppConfig.shared.httpLogs)
      // implement the logger
		]);

	dio.interceptors.add(RetryConnectionInterceptor(dio: dio));

	return dio;
});
