part of 'server_exception.dart';

enum ServerExceptionType {
	unauthorized,
	noContent,
	badRequest,
	forbiden,
	notFound,
  internal,
	decodingJson,
	unprocessable,
  serviceUnavailable,
	noInternet,
	cancel,
	timeOut,
	unknown,
}
