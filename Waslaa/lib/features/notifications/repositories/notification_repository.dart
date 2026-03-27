import 'package:Waslaa/core/api/api_client.dart';
import 'package:Waslaa/features/notifications/models/notification_model.dart';

class NotificationRepository {
  NotificationRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<AppNotification>> getNotifications({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get(
      '/notifications',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    final data =
        (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _apiClient.get('/notifications/unread-count');
    final data =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return (data['unread_count'] ?? 0) as int;
  }

  Future<void> markRead(int notificationId) async {
    await _apiClient.patch('/notifications/$notificationId/read');
  }

  Future<void> markAllRead() async {
    await _apiClient.patch('/notifications/read-all');
  }
}
