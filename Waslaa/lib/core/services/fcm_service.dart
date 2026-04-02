import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:Waslaa/core/api/api_client.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init(ApiClient apiClient) async {
    if (Firebase.apps.isEmpty) {
      debugPrint(
        'Firebase Messaging skipped because Firebase is not initialized.',
      );
      return;
    }

    // Request permissions for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    // Get the token
    String? token = await _firebaseMessaging.getToken();
    debugPrint("FCM Token: $token");

    if (token != null) {
      _sendTokenToServer(apiClient, token);
    }

    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _sendTokenToServer(apiClient, newToken);
    });

    // Handle messages while app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
          'Message also contained a notification: ${message.notification}',
        );
        // Here you can show a local notification if you want
      }
    });

    // Background handlers are registered only on non-web platforms.
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    }
  }

  Future<void> _sendTokenToServer(ApiClient apiClient, String token) async {
    try {
      await apiClient.patch('/profile/fcm-token', data: {'fcm_token': token});
      debugPrint("FCM Token sent to server successfully.");
    } catch (e) {
      debugPrint("Failed to send FCM token to server: $e");
    }
  }
}
