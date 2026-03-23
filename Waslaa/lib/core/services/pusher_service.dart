import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:Waslaa/core/session/session_storage.dart';

class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  bool _isInitialized = false;

  Future<void> initPusher() async {
    if (_isInitialized) return;

    try {
      final token = await SessionStorage().readAccessToken();

      await pusher.init(
        apiKey: "pnbqosojiv97hmrgutf5", // REVERB_APP_KEY from backend
        cluster:
            "mt1", // not used for reverb but required by pusher format sometimes
        onConnectionStateChange: onConnectionStateChange,
        onError: onError,
        onSubscriptionSucceeded: onSubscriptionSucceeded,
        onEvent: onEvent,
        onSubscriptionError: onSubscriptionError,
        onDecryptionFailure: onDecryptionFailure,
        onMemberAdded: onMemberAdded,
        onMemberRemoved: onMemberRemoved,
        authEndpoint:
            "http://10.0.2.2:8000/api/broadcasting/auth", // Adjust for real API
        authParams: {
          'headers': {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        },
        useTLS: false, // Set to true in production
      );
      await pusher.connect();
      _isInitialized = true;
    } catch (e) {
      debugPrint("Pusher Init Error: $e");
    }
  }

  Future<void> subscribeToChat(
    int threadId,
    Function(dynamic) onMessageReceived,
  ) async {
    await pusher.subscribe(
      channelName: "private-chat.$threadId",
      onEvent: (event) {
        if (event.eventName == 'message.sent') {
          final data = jsonDecode(event.data.toString());
          onMessageReceived(data['message']);
        }
      },
    );
  }

  Future<void> unsubscribeFromChat(int threadId) async {
    await pusher.unsubscribe(channelName: "private-chat.$threadId");
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    debugPrint("Connection: $currentState");
  }

  void onError(String message, int? code, dynamic e) {
    debugPrint("onError: $message code: $code exception: $e");
  }

  void onEvent(PusherEvent event) {
    debugPrint("onEvent: $event");
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    debugPrint("onSubscriptionSucceeded: $channelName data: $data");
  }

  void onSubscriptionError(String message, dynamic e) {
    debugPrint("onSubscriptionError: $message Exception: $e");
  }

  void onDecryptionFailure(String event, String reason) {
    debugPrint("onDecryptionFailure: $event reason: $reason");
  }

  void onMemberAdded(String channelName, PusherMember member) {
    debugPrint("onMemberAdded: $channelName user: $member");
  }

  void onMemberRemoved(String channelName, PusherMember member) {
    debugPrint("onMemberRemoved: $channelName user: $member");
  }
}
