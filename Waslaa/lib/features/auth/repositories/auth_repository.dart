import 'package:dio/dio.dart';

import 'package:Waslaa/core/api/api_client.dart';
import 'package:Waslaa/features/auth/models/auth_session.dart';
import 'package:Waslaa/features/auth/models/auth_user.dart';
import 'package:Waslaa/features/auth/models/specialization.dart';

class AuthRepository {
  AuthRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<AuthSession> login({
    required String login,
    required String password,
    String deviceName = 'flutter-app',
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {'login': login, 'password': password, 'device_name': deviceName},
    );

    final data =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final userJson = data['user'] as Map<String, dynamic>;

    return AuthSession(token: token, user: AuthUser.fromJson(userJson));
  }

  Future<AuthUser> getCurrentUser() async {
    final response = await _apiClient.get('/auth/me');
    final data =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;
    return AuthUser.fromJson(userJson);
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } on DioException {
      rethrow;
    }
  }

  Future<List<Specialization>> getSpecializations() async {
    final response = await _apiClient.get('/specializations');
    final data =
        (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map((item) => Specialization.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? studentNumber,
    int? specializationId,
  }) async {
    await _apiClient.post(
      '/auth/register',
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'username': username,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (studentNumber != null && studentNumber.isNotEmpty)
          'student_number': studentNumber,
        if (specializationId != null) 'specialization_id': specializationId,
      },
    );
  }

  Future<void> verifyRegistrationOtp({
    required String identifier,
    required String otp,
  }) async {
    await _apiClient.post(
      '/auth/verify-otp',
      data: {'identifier': identifier, 'otp': otp},
    );
  }

  Future<void> forgotPassword({required String identifier}) async {
    await _apiClient.post(
      '/auth/password/forgot',
      data: {'identifier': identifier},
    );
  }

  Future<void> verifyResetOtp({
    required String identifier,
    required String otp,
  }) async {
    await _apiClient.post(
      '/auth/password/verify',
      data: {'identifier': identifier, 'otp': otp},
    );
  }

  Future<void> resetPassword({
    required String identifier,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _apiClient.post(
      '/auth/password/reset',
      data: {
        'identifier': identifier,
        'otp': otp,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }
}
