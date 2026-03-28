import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:Waslaa/core/session/session_storage.dart';
import 'package:Waslaa/core/config/app_config.dart';

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
      final apiBase = AppConfig.apiBaseUrl;
      final authEndpoint = apiBase.replaceAll(
        '/mobile/v1',
        '/broadcasting/auth',
      );
      final authHeaders = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      if (kIsWeb) {
        await pusher.init(
          apiKey: "pnbqosojiv97hmrgutf5", // REVERB_APP_KEY
          cluster: "mt1",
          onConnectionStateChange: onConnectionStateChange,
          onError: onError,
          onSubscriptionSucceeded: onSubscriptionSucceeded,
          onEvent: onEvent,
          onSubscriptionError: onSubscriptionError,
          onDecryptionFailure: onDecryptionFailure,
          onMemberAdded: onMemberAdded,
          onMemberRemoved: onMemberRemoved,
          authEndpoint: authEndpoint,
          onAuthorizer: (channelName, socketId, options) async {
            final response = await Dio().post(
              authEndpoint,
              data: {
                'socket_id': socketId,
                'channel_name': channelName,
              },
              options: Options(headers: authHeaders),
            );

            final data = response.data as Map<String, dynamic>;
            return {
              'auth': data['auth'],
              'channel_data': data['channel_data'],
              'shared_secret': data['shared_secret'],
            };
          },
          useTLS: false,
        );
      } else {
        await pusher.init(
          apiKey: "pnbqosojiv97hmrgutf5", // REVERB_APP_KEY
          cluster: "mt1",
          onConnectionStateChange: onConnectionStateChange,
          onError: onError,
          onSubscriptionSucceeded: onSubscriptionSucceeded,
          onEvent: onEvent,
          onSubscriptionError: onSubscriptionError,
          onDecryptionFailure: onDecryptionFailure,
          onMemberAdded: onMemberAdded,
          onMemberRemoved: onMemberRemoved,
          authEndpoint: authEndpoint,
          authParams: {
            'headers': authHeaders,
          },
          useTLS: false,
        );
      }
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
