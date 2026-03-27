import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:Waslaa/features/profile/repositories/profile_repository.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final ProfileRepository? _profileRepository;

  PushNotificationService({ProfileRepository? profileRepository})
      : _profileRepository = profileRepository;

  Future<void> initialize() async {
    if (kIsWeb) return;

    // Request permissions for iOS
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    }

    // Handle incoming messages while the app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message while in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification?.title}');
      }
    });

    // Handle app opening from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      // TODO: Navigate to specific screen based on message data
    });

    // Get the token and upload it if repository is provided
    String? token = await getToken();
    if (token != null && _profileRepository != null) {
      await uploadToken(token);
    }

    // Listen to token refreshes
    _fcm.onTokenRefresh.listen((newToken) async {
      if (_profileRepository != null) {
        await uploadToken(newToken);
      }
    });
  }

  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> uploadToken(String token) async {
    if (_profileRepository == null) return;
    try {
      await _profileRepository!.updateFcmToken(token);
      debugPrint('FCM Token uploaded successfully: $token');
    } catch (e) {
      debugPrint('Error uploading FCM token: $e');
    }
  }
}
