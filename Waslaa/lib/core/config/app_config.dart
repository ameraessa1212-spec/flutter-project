import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  static const String _debugApiBaseUrl = 'http://127.0.0.1:8000/api/mobile/v1';

  static String get apiBaseUrl {
    final configuredValue = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );

    if (configuredValue.isNotEmpty) {
      return configuredValue;
    }

    if (kReleaseMode) {
      throw StateError(
        'API_BASE_URL is required for release builds. '
        'Pass it with --dart-define=API_BASE_URL=https://api.example.com/api/mobile/v1.',
      );
    }

    return _debugApiBaseUrl;
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}