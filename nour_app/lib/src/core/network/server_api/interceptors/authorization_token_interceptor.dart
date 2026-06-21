import 'dart:developer';
import 'package:dio/dio.dart';

import '../server_api_utils.dart';


/// This interceptor send the request with [Authorization] header with [Baerer Token]
/// if user was logined otherwise the [Authorization] header will not be send.
class AuthorizationInterceptor extends QueuedInterceptor {
	AuthorizationInterceptor({required this.apiUtils});

	final ServerApiUtils apiUtils;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
		final token = await apiUtils.getBearerTokenRequestHeader();


		if (token != null) {
			options.headers['Authorization'] = token;
			log('REQUEST-TOKEN: $token');
		}

    return handler.next(options);
  }
}
