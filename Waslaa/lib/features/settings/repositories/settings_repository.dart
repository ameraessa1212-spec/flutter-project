import 'package:Waslaa/core/api/api_client.dart';
import 'package:Waslaa/features/profile/models/user_profile.dart';

class SettingsRepository {
  SettingsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<UserSettings> getSettings() async {
    final response = await _apiClient.get('/settings');
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return UserSettings.fromJson(data);
  }

  Future<UserSettings> updateSettings({
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? chatNotificationsEnabled,
    String? language,
    String? theme,
  }) async {
    final response = await _apiClient.patch(
      '/settings',
      data: {
        if (pushNotificationsEnabled != null) 'push_notifications_enabled': pushNotificationsEnabled,
        if (emailNotificationsEnabled != null) 'email_notifications_enabled': emailNotificationsEnabled,
        if (chatNotificationsEnabled != null) 'chat_notifications_enabled': chatNotificationsEnabled,
        if (language != null) 'language': language,
        if (theme != null) 'theme': theme,
      },
    );
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return UserSettings.fromJson(data);
  }
}
