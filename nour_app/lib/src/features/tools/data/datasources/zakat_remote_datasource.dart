import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import '../models/zakat_api_result.dart';

/// EsakoAPI — free, key-less Shariah Zakat engine (https://esakoapi.org).
///
/// Uses a dedicated [Dio] (no app auth/content interceptors) and accepts every
/// status code so the below-Nisab `325` body can be parsed instead of thrown.
final zakatRemoteDataProvider = Provider(
  (ref) => ZakatRemoteDatasource(
    Dio(
      BaseOptions(
        baseUrl: 'https://esakoapi.org/api',
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 12),
        responseType: ResponseType.json,
        validateStatus: (_) => true,
      ),
    ),
  ),
);

class ZakatRemoteDatasource {
  ZakatRemoteDatasource(this._dio);

  final Dio _dio;

  /// Calls `/money/{amount}` — the authoritative money-Zakat calculation.
  ///
  /// [amount] is the user's **net** zakatable wealth. It is rounded to a whole
  /// unit (the API path expects a plain number; fractional currency is
  /// negligible for Zakat) and clamped to be non-negative.
  Future<ZakatApiResult> calculateMoneyZakat(double amount) async {
    final safe = amount.isFinite && amount > 0 ? amount.round() : 0;

    final res = await _dio.get<dynamic>('/money/$safe');
    final data = res.data;
    if (data is Map) {
      return ZakatApiResult.fromJson(Map<String, dynamic>.from(data));
    }

    talker.error('Unexpected EsakoAPI response: ${res.statusCode} -> $data');
    throw const FormatException('Unexpected zakat API response');
  }
}
