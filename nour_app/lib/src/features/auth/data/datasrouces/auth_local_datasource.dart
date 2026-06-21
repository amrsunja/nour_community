import 'package:hooks_riverpod/hooks_riverpod.dart';

final authLocalDataProvider = Provider(
  (ref) => AuthLocalDatasource(),
);

class AuthLocalDatasource {
  Future<String?> getAccessToken() async {
    throw UnimplementedError();
  }

  Future<String?> getRefreshToken() async {
    throw UnimplementedError();
  }
}
