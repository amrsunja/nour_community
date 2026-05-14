import 'package:dio/dio.dart';
import 'package:nour/src/core/network/dowload_file_request_params.dart';

import '../api_services.dart';
import '../api_utils.dart';
import '../request_params.dart';

/// Server Api service to use to GET, POST, PATCH, PUT & DELETE requests
/// It also catch all server or request errors
class ServerApiServicesImpl implements ApiServices {
	ServerApiServicesImpl({
		required this.dio,
		required this.apiUtils,
		required this.cancelToken,
	});

	final Dio dio;
	final ApiUtils apiUtils;
	final CancelToken cancelToken;

  @override
  Future<Response<T>> getData<T>({
		required String path,
		RequestParams? params,
	}) async {
		return apiUtils.tryRequestOrThrowServerException(() async {
			return await dio.get(
				path,
				queryParameters: params?.queryParams,
				options: params?.options,
				cancelToken: params?.cancelToken,
			);
		});
  }

  @override
  Future<Response<T>> postData<T>({
		required String path,
		RequestParams? params,
	}) async {
		return apiUtils.tryRequestOrThrowServerException(() async {
			return await dio.post(
				path,
				data: params?.data,
				queryParameters: params?.queryParams,
				options: params?.options,
				cancelToken: params?.cancelToken,
			);
		});
  }

  @override
  Future<Response<T>> patchData<T>({
		required String path,
		RequestParams? params,
	}) async {
		return apiUtils.tryRequestOrThrowServerException(() async {
			return await dio.patch(
				path,
				data: params?.data,
				queryParameters: params?.queryParams,
				options: params?.options,
				cancelToken: params?.cancelToken,
			);
		});
  }

  @override
  Future<Response<T>> putData<T>({
		required String path,
		RequestParams? params,
	}) async {
		return apiUtils.tryRequestOrThrowServerException(() async {
			return await dio.put(
				path,
				data: params?.data,
				queryParameters: params?.queryParams,
				options: params?.options,
				cancelToken: params?.cancelToken,
			);
		});
  }

  @override
  Future<Response<T>> deleteData<T>({
		required String path,
		RequestParams? params,
	}) async {
		return apiUtils.tryRequestOrThrowServerException(() async {
			return await dio.delete(
				path,
				data: params?.data,
				queryParameters: params?.queryParams,
				options: params?.options,
				cancelToken: params?.cancelToken,
			);
		});
  }

  @override
  Future<Response<dynamic>> downloadFile({required DownloadFileRequestParams params}) {
		return apiUtils.tryRequestOrThrowServerException(() async {
			return await dio.download(
				params.url, 
				params.savePath,
				onReceiveProgress: params.onReceiveProgress,
				queryParameters: params.queryParams,
				cancelToken: params.cancelToken,
				data: params.data,
				options: params.options
			);
		});
  }
}
