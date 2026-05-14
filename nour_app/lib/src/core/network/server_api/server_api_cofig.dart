import '../../../../config/app_config.dart';

abstract class ServerApiConfig {
  static final baseUrl = '${AppConfig.shared.baseUrl}/api/v1';
  static final assetsBaseUrl = AppConfig.shared.baseUrl;
}
