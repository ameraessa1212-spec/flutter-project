import 'package:dio/dio.dart';
import 'package:Waslaa/core/api/api_client.dart';
import 'package:Waslaa/features/reports/models/report.dart';

class ReportRepository {
  ReportRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Report>> getReports(int internshipId) async {
    final response = await _apiClient.get('/internships/$internshipId/reports');
    final data =
        (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map((item) => Report.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Report> submitReport({
    required int internshipId,
    required String title,
    required String reportType,
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    MultipartFile? file;
    if (fileBytes != null && fileName != null) {
      file = MultipartFile.fromBytes(fileBytes, filename: fileName);
    } else if (filePath != null) {
      file = await MultipartFile.fromFile(
        filePath,
        filename: fileName ?? filePath.split('/').last,
      );
    }

    final formData = FormData.fromMap({
      'title': title,
      'report_type': reportType,
      if (file != null) 'file': file,
    });

    final response = await _apiClient.post(
      '/internships/$internshipId/reports',
      data: formData,
    );
    final data =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return Report.fromJson(data);
  }

  Future<Report> getReport(int reportId) async {
    final response = await _apiClient.get('/reports/$reportId');
    final data =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return Report.fromJson(data);
  }

  Future<void> deleteReport(int reportId) async {
    await _apiClient.delete('/reports/$reportId');
  }
}
