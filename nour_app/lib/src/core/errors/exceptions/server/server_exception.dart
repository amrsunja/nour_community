import '../../../utils/typedefs.dart';

part 'server_exception_type.dart';

class ServerException implements Exception {
	final ServerExceptionType type;
	final String? message;
	final ApiErrorModel? apiError;
	final int? code;

	ServerException({
		required this.type,
		this.message,
		this.apiError,
    this.code,
	});
}

class ApiErrorModel {
  const ApiErrorModel({
		required this.message,
	});

	final String message;

	factory ApiErrorModel.fromJson(Json json) {
		/*
		JSON RESPONSE: {
      "detail": "Description de l'erreur"
		}
		*/

	  return ApiErrorModel(
			message: json['detail']
		);
	}
}
