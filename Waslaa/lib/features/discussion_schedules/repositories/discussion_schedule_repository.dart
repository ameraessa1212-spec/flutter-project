import 'package:Waslaa/core/api/api_client.dart';
import 'package:Waslaa/features/discussion_schedules/models/discussion_schedule.dart';

class DiscussionScheduleRepository {
  DiscussionScheduleRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<DiscussionSchedule>> getSchedules({
    int page = 1,
    int perPage = 15,
    int? specializationId,
  }) async {
    final params = <String, dynamic>{'page': page, 'per_page': perPage};
    if (specializationId != null) params['specialization_id'] = specializationId;
    final response = await _apiClient.get(
      '/discussion-schedules',
      queryParameters: params,
    );
    final data =
        (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map(
          (item) => DiscussionSchedule.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<DiscussionSchedule> getSchedule(int id) async {
    final response = await _apiClient.get('/discussion-schedules/$id');
    final data =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return DiscussionSchedule.fromJson(data);
  }
}
