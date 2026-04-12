import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  const AppConfig._();

  static const String _debugApiBaseUrl =
      'http://localhost:8000/api/mobile/v1';

  static String? _customApiBaseUrl;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _customApiBaseUrl = prefs.getString('custom_api_base_url');
  }

  static Future<void> setCustomApiBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    if (url.isEmpty) {
      await prefs.remove('custom_api_base_url');
      _customApiBaseUrl = null;
    } else {
      await prefs.setString('custom_api_base_url', url);
      _customApiBaseUrl = url;
    }
  }

  static String get apiBaseUrl {
    if (_customApiBaseUrl != null && _customApiBaseUrl!.isNotEmpty) {
      return _customApiBaseUrl!;
    }

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

class FirebaseConfig {
  const FirebaseConfig._();

  static const String _apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyD1gce2DJoEVrjeo5pxKtKi_TZxVEo5Aws',
  );
  static const String _appId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:478962666331:web:1f79b20fbd2ec24149a87e',
  );
  static const String _messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '478962666331',
  );
  static const String _projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'laraval-appfor-waslaa',
  );
  static const String _authDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: 'laraval-appfor-waslaa.firebaseapp.com',
  );
  static const String _storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'laraval-appfor-waslaa.firebasestorage.app',
  );
  static const String _measurementId = String.fromEnvironment(
    'FIREBASE_MEASUREMENT_ID',
    defaultValue: 'G-0SRC7TVVE2',
  );
  static const String _databaseUrl = String.fromEnvironment(
    'FIREBASE_DATABASE_URL',
    defaultValue: 'https://laraval-appfor-waslaa.firebaseio.com',
  );
  static const String _iosBundleId = String.fromEnvironment(
    'FIREBASE_IOS_BUNDLE_ID',
  );
  static const String _androidClientId = String.fromEnvironment(
    'FIREBASE_ANDROID_CLIENT_ID',
  );
  static const String _iosClientId = String.fromEnvironment(
    'FIREBASE_IOS_CLIENT_ID',
  );
  static const String _appGroupId = String.fromEnvironment(
    'FIREBASE_APP_GROUP_ID',
  );

  static bool get isConfigured =>
      _apiKey.isNotEmpty &&
      _appId.isNotEmpty &&
      _messagingSenderId.isNotEmpty &&
      _projectId.isNotEmpty;

  static FirebaseOptions get currentPlatform {
    if (!isConfigured) {
      throw StateError(
        'Firebase is not configured. Pass FIREBASE_API_KEY, FIREBASE_APP_ID, '
        'FIREBASE_MESSAGING_SENDER_ID, and FIREBASE_PROJECT_ID with --dart-define.',
      );
    }

    return FirebaseOptions(
      apiKey: _apiKey,
      appId: _appId,
      messagingSenderId: _messagingSenderId,
      projectId: _projectId,
      authDomain: _optionalValue(_authDomain),
      storageBucket: _optionalValue(_storageBucket),
      measurementId: _optionalValue(_measurementId),
      databaseURL: _optionalValue(_databaseUrl),
      iosBundleId: _optionalValue(_iosBundleId),
      androidClientId: _optionalValue(_androidClientId),
      iosClientId: _optionalValue(_iosClientId),
      appGroupId: _optionalValue(_appGroupId),
    );
  }

  static Future<bool> initialize() async {
    if (Firebase.apps.isNotEmpty) {
      return true;
    }

    if (isConfigured) {
      await Firebase.initializeApp(options: currentPlatform);
      return true;
    }

    if (!kIsWeb) {
      try {
        await Firebase.initializeApp();
        return true;
      } catch (error) {
        debugPrint('Firebase initialization skipped: $error');
      }
    }

    return false;
  }

  static String? _optionalValue(String value) {
    if (value.isEmpty) {
      return null;
    }

    return value;
  }
}
