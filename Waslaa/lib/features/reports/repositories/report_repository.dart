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
    required String filePath,
    String? fileName,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'report_type': reportType,
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName ?? filePath.split('/').last,
      ),
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

  // ── Examiner-specific methods ──────────────────────────────────────────────

  /// Returns all student reports visible to the currently logged-in examiner.
  Future<List<Report>> getExaminerReports({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    final response = await _apiClient.get(
      '/examiner/reports',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    final data =
        (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map((item) => Report.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Approves or rejects a report as an examiner.
  ///
  /// [status] must be `'approved'` or `'rejected'`.
  Future<Report> evaluateReport({
    required int reportId,
    required String status,
    String? reviewNotes,
  }) async {
    final response = await _apiClient.post(
      '/reports/$reportId/evaluate',
      data: {
        'status': status,
        if (reviewNotes != null && reviewNotes.isNotEmpty)
          'review_notes': reviewNotes,
      },
    );
    final data =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return Report.fromJson(data);
  }
}
