// ignore_for_file: constant_identifier_names

class ApiSuccessStatusCode {
	/// [200] status code ok
	static const int ok = 200;
	/// [201] server created something
	static const int created 	= 201;
	/// [202] server accepted the request
	static const int accepted	= 202;
}

class ApiErrorStatusCode {
	/// [101] http server switching protocol 
	static const int switchingProtocol = 101;
	/// [204] no content
	static const int noContent = 204;
	/// [400] server can not to parse this request and error should be from client side
	static const int badRequest = 400;
	/// [401] client does not authorized
	static const int unauthorized = 401;
	/// [403] client does not have access righs to the content;
	static const int forbiden = 403;
	/// [404] server can not find the requested resource
	static const int notFound = 404;
	/// [405] indicates that the request method is known by the server but is not supported by the target resource.
	static const int methodNotAllowed = 405;
	/// [408] Request Timeout 
	static const int requestTimeout = 408;
	/// [409] server conflict when send request 
	static const int conflict = 409;
	/// [422] server conflict when send request 
	static const int unprocessable = 422;
	/// [500] server has encountered a situation it does not know how to handle.
	static const int internalServerError = 500;
	/// [501] server does not support the functionality required to fulfill the request.
	static const int notImplemented = 501;
	/// [502] means that the server received an invalid response from an inbound server..
	static const int badGateway = 502;
	/// [503] server is not ready to handle the request.
	static const int serviceUnavailable = 503;
}
