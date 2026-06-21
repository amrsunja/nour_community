import 'package:dio/dio.dart';

import 'dowload_file_request_params.dart';
import 'request_params.dart';

abstract class ApiServices {
	Future<Response<T>> getData<T>({
		required String path,
		RequestParams? params,
	});

	Future<Response<T>> postData<T>({
		required String path,
		RequestParams? params,
	});

	Future<Response<T>> patchData<T>({
		required String path,
		RequestParams? params,
	});

	Future<Response<T>> putData<T>({
		required String path,
		RequestParams? params,
	});

	Future<Response<T>> deleteData<T>({
		required String path,
		RequestParams? params,
	});

	Future<Response<dynamic>> downloadFile({
		required DownloadFileRequestParams params
	});
}
