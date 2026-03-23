import 'package:Waslaa/core/api/api_client.dart';

class ContentData {
  const ContentData({required this.title, required this.body});
  final String title;
  final String body;

  factory ContentData.fromJson(Map<String, dynamic> json) {
    return ContentData(
      title: (json['title'] ?? '') as String,
      body: (json['body'] ?? json['content'] ?? json['text'] ?? '') as String,
    );
  }
}

class ContentRepository {
  ContentRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ContentData> getAboutApp() async {
    final response = await _apiClient.get('/content/about-app');
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ContentData.fromJson(data);
  }

  Future<ContentData> getAboutUs() async {
    final response = await _apiClient.get('/content/about-us');
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ContentData.fromJson(data);
  }

  Future<ContentData> getTerms() async {
    final response = await _apiClient.get('/content/terms');
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ContentData.fromJson(data);
  }

  Future<ContentData> getPrivacy() async {
    final response = await _apiClient.get('/content/privacy');
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ContentData.fromJson(data);
  }
}
