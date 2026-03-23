import 'package:dio/dio.dart';
import 'package:Waslaa/core/api/api_client.dart';
import 'package:Waslaa/features/chat/models/chat_models.dart';

class ChatRepository {
  ChatRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<ChatThread>> getThreads() async {
    final response = await _apiClient.get('/chat/threads');
    final data = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map((item) => ChatThread.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ChatThread> getThread(int threadId) async {
    final response = await _apiClient.get('/chat/threads/$threadId');
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ChatThread.fromJson(data);
  }

  Future<List<ChatMessage>> getMessages(int threadId, {int page = 1, int perPage = 30}) async {
    final response = await _apiClient.get(
      '/chat/threads/$threadId/messages',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    final data = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ChatMessage> sendMessage(int threadId, {required String body}) async {
    final response = await _apiClient.post(
      '/chat/threads/$threadId/messages',
      data: {'body': body, 'message_type': 'text'},
    );
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ChatMessage.fromJson(data);
  }

  Future<ChatMessage> sendAttachment(
    int threadId, {
    required String filePath,
    String? fileName,
    String messageType = 'file',
  }) async {
    final formData = FormData.fromMap({
      'attachment': await MultipartFile.fromFile(filePath, filename: fileName ?? filePath.split('/').last),
      'message_type': messageType,
    });
    final response = await _apiClient.post('/chat/threads/$threadId/attachments', data: formData);
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ChatMessage.fromJson(data);
  }

  Future<void> markRead(int threadId) async {
    await _apiClient.post('/chat/threads/$threadId/read');
  }
}
