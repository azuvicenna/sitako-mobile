import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  AppConstants._();

  /// Compile-time environment variable to override API base URL.
  /// Example: `flutter build apk --release --dart-define=API_BASE_URL=http://192.168.64.2:8080/api`
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get defaultBaseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080/api';
      }
    } catch (_) {}
    return 'http://localhost:8080/api';
  }

  static const String keyAuthToken = 'sitako_auth_token';
  static const String keyUserData = 'sitako_user_data';
  static const String keyThemeMode = 'sitako_theme_mode';

  static const Duration requestTimeout = Duration(seconds: 15);
  static const int defaultPageSize = 10;

  static const String appName = 'SITAKO';
  static const String appDescription = 'Sistem Informasi Perpustakaan Sekolah';
}
