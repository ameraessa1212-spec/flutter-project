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

  Future<List<ChatMessage>> getChatifyMessages(int receiverId) async {
    final response = await _apiClient.get(
      '/chat/messages',
      queryParameters: {'receiver_id': receiverId},
    );
    final data =
        (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data.map<ChatMessage>((item) {
      // Map Chatify fields to ChatMessage model
      return ChatMessage(
        id: item['id'],
        body: item['body'],
        senderId: (item['from_id'] as num).toInt(),
        fromId: (item['from_id'] as num).toInt(),
        toId: (item['to_id'] as num).toInt(),
        messageType: item['attachment'] != null ? 'file' : 'text',
        createdAt: item['created_at'],
        sentAt: item['created_at'],
        attachments:
            item['attachment'] != null
                ? [
                  ChatAttachment(
                    id: item['id'],
                    fileUrl:
                        '/storage/attachments/${item['attachment']['new_name']}',
                    fileName: item['attachment']['old_name'],
                  ),
                ]
                : [],
      );
    }).toList();
  }

  Future<ChatMessage> sendChatifyMessage(int receiverId, String body) async {
    final response = await _apiClient.post(
      '/chat/messages',
      data: {'receiver_id': receiverId, 'message': body},
    );
    final data =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    // The response has minimal data, we manually construct the message for UI
    return ChatMessage(
      id: data['id'],
      body: body,
      senderId: 0, // Will be set by UI caller or refresh
      messageType: 'text',
      createdAt: DateTime.now().toIso8601String(),
    );
  }
}
