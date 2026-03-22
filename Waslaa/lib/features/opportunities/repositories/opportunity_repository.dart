import 'package:Waslaa/core/api/api_client.dart';
import 'package:Waslaa/features/opportunities/models/opportunity.dart';

class OpportunityRepository {
  OpportunityRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Opportunity>> getOpportunities({
    String? search,
    int? specializationId,
    String? city,
    bool? isAvailable,
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await _apiClient.get(
      '/opportunities',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (search != null && search.isNotEmpty) 'search': search,
        if (specializationId != null) 'specialization_id': specializationId,
        if (city != null && city.isNotEmpty) 'city': city,
        if (isAvailable != null) 'is_available': isAvailable ? '1' : '0',
      },
    );
    final data = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map((item) => Opportunity.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Opportunity> getOpportunity(int id) async {
    final response = await _apiClient.get('/opportunities/$id');
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return Opportunity.fromJson(data);
  }
}
