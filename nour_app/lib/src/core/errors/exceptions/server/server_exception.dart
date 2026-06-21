import '../../../utils/typedefs.dart';

part 'server_exception_type.dart';
part 'api_error_key.dart';

class ServerException implements Exception {
	final ServerExceptionType type;
	/// Free-form message (e.g. a server-provided string). Prefer [messageKey]
	/// for app-defined errors so they can be localized.
	final String? message;
	/// Localizable, language-agnostic error identifier resolved in the UI layer.
	final ApiErrorKey? messageKey;
	final ApiErrorModel? apiError;
	final int? code;

	ServerException({
		required this.type,
		this.message,
		this.messageKey,
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
