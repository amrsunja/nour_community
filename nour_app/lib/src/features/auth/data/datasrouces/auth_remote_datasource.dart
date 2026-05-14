import 'package:hooks_riverpod/hooks_riverpod.dart';

final authRemoteDataProvider = Provider(
  (ref) => AuthRemoteDatasource(),
);

class AuthRemoteDatasource {}
