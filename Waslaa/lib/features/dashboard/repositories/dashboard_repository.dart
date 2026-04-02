import 'package:Waslaa/core/api/api_client.dart';
import 'package:Waslaa/features/dashboard/models/home_dashboard.dart';

class DashboardRepository {
  DashboardRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<HomeDashboard> getHomeDashboard() async {
    final response = await _apiClient.get('/dashboard/home');
    final data =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return HomeDashboard.fromJson(data);
  }
}
