abstract class ApiConfig {
  static const int connectTimeout = 5;
  static const int receiveTimeout = 30;

  static const acceptHeaderKey = 'Accept';
  static const contentTypeHeaderKey = 'Content-Type';

  static const applicationJsonContentType = 'application/json';
  static const multipartFormDataContentType = 'multipart/form-data';
  static const emptyContentType = '';
}
