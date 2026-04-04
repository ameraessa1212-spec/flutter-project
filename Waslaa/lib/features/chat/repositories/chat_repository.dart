import 'package:dio/dio.dart';
import 'package:Waslaa/core/api/api_client.dart';
import 'package:Waslaa/features/chat/models/chat_models.dart';

class ChatRepository {
  ChatRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<ChatThread>> getThreads() async {
    final response = await _apiClient.get('/chat/threads');
    final data =
        (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map((item) => ChatThread.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ChatThread> getThread(int threadId) async {
    final response = await _apiClient.get('/chat/threads/$threadId');
    final data =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ChatThread.fromJson(data);
  }

  Future<List<ChatMessage>> getMessages(
    int threadId, {
    int page = 1,
    int perPage = 30,
  }) async {
    final response = await _apiClient.get(
      '/chat/threads/$threadId/messages',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    final data =
        (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ChatMessage> sendMessage(int threadId, {required String body}) async {
    final response = await _apiClient.post(
      '/chat/threads/$threadId/messages',
      data: {'body': body, 'message_type': 'text'},
    );
    final data =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ChatMessage.fromJson(data);
  }

  Future<ChatMessage> sendAttachment(
    int threadId, {
    required String filePath,
    String? fileName,
    String messageType = 'file',
  }) async {
    final formData = FormData.fromMap({
      'attachment': await MultipartFile.fromFile(
        filePath,
        filename: fileName ?? filePath.split('/').last,
      ),
      'message_type': messageType,
    });
    final response = await _apiClient.post(
      '/chat/threads/$threadId/attachments',
      data: formData,
    );
    final data =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ChatMessage.fromJson(data);
  }

  Future<void> markRead(int threadId) async {
    await _apiClient.post('/chat/threads/$threadId/read');
  }

  // --- Chatify Bridge Methods ---

  Future<List<Map<String, dynamic>>> getChatifyContacts() async {
    final response = await _apiClient.get('/chat/contacts');
    final data =
        (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  Future<List<ChatMessage>> getChatifyMessages(int receiverId) async {
    final response = await _apiClient.get(
      '/chat/messages',
      queryParameters: {'receiver_id': receiverId},
    );
    final data =
        (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data.map<ChatMessage>((item) {
      return ChatMessage(
        id: item['id'],
        body: item['body'] as String?,
        senderId: (item['from_id'] as num).toInt(),
        fromId: (item['from_id'] as num).toInt(),
        toId: (item['to_id'] as num).toInt(),
        messageType: 'text',
        createdAt: item['created_at'] as String?,
        sentAt: item['created_at'] as String?,
      );
    }).toList();
  }

  Future<ChatMessage> sendChatifyMessage(int receiverId, String body, {required int senderId}) async {
    final response = await _apiClient.post(
      '/chat/messages',
      data: {'receiver_id': receiverId, 'message': body},
    );
    final data =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ChatMessage(
      id: data['id'],
      body: data['body'] as String? ?? body,
      senderId: (data['from_id'] as num?)?.toInt() ?? senderId,
      fromId: (data['from_id'] as num?)?.toInt() ?? senderId,
      toId: (data['to_id'] as num?)?.toInt() ?? receiverId,
      messageType: 'text',
      createdAt: data['created_at'] as String? ?? DateTime.now().toIso8601String(),
      sentAt: data['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
