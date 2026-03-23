import 'package:Waslaa/core/api/api_client.dart';
import 'package:Waslaa/features/internships/models/internship.dart';

class InternshipRepository {
  InternshipRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Internship>> getInternships({int page = 1, int perPage = 15}) async {
    final response = await _apiClient.get(
      '/internships',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    final data = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map((item) => Internship.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Internship?> getCurrentInternship() async {
    final response = await _apiClient.get('/internships/current');
    final raw = (response.data as Map<String, dynamic>)['data'];
    if (raw == null) return null;
    return Internship.fromJson(raw as Map<String, dynamic>);
  }

  Future<Internship> getInternship(int id) async {
    final response = await _apiClient.get('/internships/$id');
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return Internship.fromJson(data);
  }

  Future<List<TimelineItem>> getTimeline(int internshipId) async {
    final response = await _apiClient.get('/internships/$internshipId/timeline');
    final data = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map((item) => TimelineItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
