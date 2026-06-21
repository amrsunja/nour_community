abstract class ApiUtils {
	Future<T> tryRequestOrThrowServerException<T>(Future<T> Function() tryBody);
}
