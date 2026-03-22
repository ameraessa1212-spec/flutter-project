import 'package:Waslaa/core/api/api_client.dart';

class ContentRepository {
  ContentRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<String> getAboutApp() async {
    final response = await _apiClient.get('/content/about-app');
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return (data['content'] ?? data['text'] ?? '') as String;
  }

  Future<String> getAboutUs() async {
    final response = await _apiClient.get('/content/about-us');
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return (data['content'] ?? data['text'] ?? '') as String;
  }

  Future<String> getTerms() async {
    final response = await _apiClient.get('/content/terms');
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return (data['content'] ?? data['text'] ?? '') as String;
  }

  Future<String> getPrivacy() async {
    final response = await _apiClient.get('/content/privacy');
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return (data['content'] ?? data['text'] ?? '') as String;
  }
}
