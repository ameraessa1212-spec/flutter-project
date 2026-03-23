import 'package:Waslaa/core/api/api_client.dart';
import 'package:Waslaa/features/opportunities/models/opportunity.dart';

class OpportunityRepository {
  OpportunityRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<OpportunityListPage> getOpportunitiesPage({
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
    return OpportunityListPage.fromResponse(response.data as Map<String, dynamic>);
  }

  Future<List<Opportunity>> getOpportunities({
    String? search,
    int? specializationId,
    String? city,
    bool? isAvailable,
    int page = 1,
    int perPage = 15,
  }) async {
    final result = await getOpportunitiesPage(
      search: search,
      specializationId: specializationId,
      city: city,
      isAvailable: isAvailable,
      page: page,
      perPage: perPage,
    );
    return result.items;
  }

  Future<Opportunity> getOpportunity(int id) async {
    final response = await _apiClient.get('/opportunities/$id');
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return Opportunity.fromJson(data);
  }
}
