import 'package:dio/dio.dart';
import 'package:Waslaa/core/api/api_client.dart';
import 'package:Waslaa/features/applications/models/application.dart';

class ApplicationRepository {
  ApplicationRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Application>> getApplications({
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await _apiClient.get(
      '/applications',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    final data =
        (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map((item) => Application.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Application> apply({
    required int opportunityId,
    String? notes,
    String? cvFilePath,
    List<int>? cvFileBytes,
    String? cvFileName,
  }) async {
    MultipartFile? cvFile;
    if (cvFileBytes != null && cvFileName != null) {
      cvFile = MultipartFile.fromBytes(cvFileBytes, filename: cvFileName);
    } else if (cvFilePath != null) {
      cvFile = await MultipartFile.fromFile(cvFilePath);
    }

    final formData = FormData.fromMap({
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (cvFile != null) 'cv': cvFile,
    });

    final response = await _apiClient.post(
      '/opportunities/$opportunityId/applications',
      data: formData,
    );
    final data =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return Application.fromJson(data);
  }

  Future<void> withdraw(int applicationId) async {
    await _apiClient.delete('/applications/$applicationId');
  }
}
