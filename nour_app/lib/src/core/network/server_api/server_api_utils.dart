import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/features/auth/data/datasrouces/auth_local_datasource.dart';

import '../../errors/exceptions/server/server_exception.dart';
import '../api_status_code.dart';
import '../api_utils.dart';

class ServerApiUtils implements ApiUtils {
	ServerApiUtils({
		required this.authLocalDatasource,
		required this.ref,
		//required this.router,
		required this.cancelToken
	});

	final AuthLocalDatasource authLocalDatasource;
	final Ref ref;
	//final AppRouter router;
	final CancelToken cancelToken;

  Future<String?> getBearerTokenRequestHeader() async {
		final token = await authLocalDatasource.getAccessToken();
		return token == null ? null : 'Bearer $token';
  }

  @override
  Future<T> tryRequestOrThrowServerException<T>(Future<T> Function() request) async {
		try {
			return await request();
		} on DioException catch(error) {
				final unknownException = _getServerException(ServerExceptionType.unknown, error);

				switch (error.type) {
					case DioExceptionType.badResponse:
						throw _getDioBadResponseException(error);
					case DioExceptionType.cancel:
						throw ServerException(
							type: ServerExceptionType.cancel,
							message: error.message,
							code: ApiErrorStatusCode.switchingProtocol,
						);
					case DioExceptionType.connectionTimeout:
					case DioExceptionType.sendTimeout:
					case DioExceptionType.receiveTimeout:
						throw ServerException(
							type: ServerExceptionType.timeOut,
							message: error.message,
							code: ApiErrorStatusCode.requestTimeout,
						);
      		case DioExceptionType.connectionError: 
						if (error is SocketException) {
							throw ServerException(
								type: ServerExceptionType.noInternet,
								message: error.message,
								code: ApiErrorStatusCode.switchingProtocol,
							);
						} else {
							throw unknownException;
						}
					default:
							throw unknownException;
				}
		} catch (e) {
			throw ServerException(
				type: ServerExceptionType.unknown,
				message: e.toString()
			);
		}
  }

	ServerException _getDioBadResponseException(DioException error) {
		switch (error.response?.statusCode) {
			case ApiErrorStatusCode.unauthorized:
				throw _getServerException(ServerExceptionType.unauthorized, error);
			case ApiErrorStatusCode.noContent:
				throw _getServerException(ServerExceptionType.noContent, error);
			case ApiErrorStatusCode.badRequest:
				throw _getServerException(ServerExceptionType.badRequest, error);
			case ApiErrorStatusCode.forbiden:
				throw _getServerException(ServerExceptionType.forbiden, error);
			case ApiErrorStatusCode.notFound:
				throw _getServerException(ServerExceptionType.notFound, error);
			case ApiErrorStatusCode.internalServerError:
				throw _getServerException(ServerExceptionType.internal, error);
			case ApiErrorStatusCode.unprocessable:
				throw _getServerException(ServerExceptionType.unprocessable, error);
			case ApiErrorStatusCode.serviceUnavailable:
				throw _getServerException(ServerExceptionType.serviceUnavailable, error);
			default:
				throw _getServerException(ServerExceptionType.unknown, error);
		}
	}

	ServerException _getServerException(ServerExceptionType type, DioException error) {
		return ServerException(
			type: type,
			apiError: error.response?.data == null ? null : ApiErrorModel.fromJson((error.response!.data)),
			message: error.message,
			code: error.response?.statusCode,
		);
	}
}
