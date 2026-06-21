import 'dart:io';

import 'package:dio/dio.dart';
import 'package:nour/config/app_config.dart';
import 'package:nour/src/core/locale/l10n.dart';

import '../../api_config.dart';
import '../server_api_utils.dart';

class ContentTypeInterceptor extends Interceptor {
	ContentTypeInterceptor({required this.apiUtils});

	final ServerApiUtils apiUtils;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
		// This first condition was added for skip options.headers if we pass them from out
		// for expample from some remoteDatasource method like in [S3RemoteDatasourceImpl.uploadFile()]
		if (options.headers.isNotEmpty) {
		} else if (options.data is FormData) {
      options.headers[ApiConfig.contentTypeHeaderKey] = ApiConfig.multipartFormDataContentType;
    } else if (options.headers[ApiConfig.contentTypeHeaderKey] != ApiConfig.multipartFormDataContentType) {
      options.headers[ApiConfig.contentTypeHeaderKey] = ApiConfig.applicationJsonContentType;
    }

    options.headers[ApiConfig.acceptHeaderKey] = ApiConfig.applicationJsonContentType;
    options.headers['X-App-Version'] = AppConfig.shared.appVersion;
    options.headers['X-Platform'] = Platform.isIOS ? 'ios' : 'android';
    options.headers['X-App-Lang'] = apiUtils.ref.read(l10nProvider).localeName;

    return handler.next(options);
  }
}
