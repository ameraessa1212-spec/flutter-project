import 'package:dio/dio.dart';
import 'package:Waslaa/core/api/api_client.dart';
import 'package:Waslaa/features/profile/models/user_profile.dart';

class ProfileRepository {
  ProfileRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<UserProfile> getProfile() async {
    final response = await _apiClient.get('/profile');
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;
    return UserProfile.fromJson(userJson);
  }

  Future<UserProfile> updateProfile({
    String? firstName,
    String? lastName,
    String? username,
    String? phone,
  }) async {
    final response = await _apiClient.patch(
      '/profile',
      data: {
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (username != null) 'username': username,
        if (phone != null) 'phone': phone,
      },
    );
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;
    return UserProfile.fromJson(userJson);
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await _apiClient.patch(
      '/profile/password',
      data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      },
    );
  }

  Future<UserProfile> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });
    final response = await _apiClient.post('/profile/avatar', data: formData);
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;
    return UserProfile.fromJson(userJson);
  }

  Future<UserProfile> uploadCv(String filePath) async {
    final formData = FormData.fromMap({
      'cv': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });
    final response = await _apiClient.post('/profile/cv', data: formData);
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;
    return UserProfile.fromJson(userJson);
  }
}
