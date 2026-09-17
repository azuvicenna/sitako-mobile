import '../models/fine_payment.dart';
import '../utils/api_client.dart';

class FineService {
  final ApiClient _apiClient;

  FineService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  Future<List<FinePaymentItem>> getMemberFines({
    int page = 1,
    int limit = 30,
    String? search,
  }) async {
    return fetchMemberFines(
      page: page,
      limit: limit,
      search: search,
    );
  }

  Future<List<FinePaymentItem>> fetchMemberFines({
    int page = 1,
    int limit = 30,
    String? search,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final queryString = Uri(queryParameters: queryParams).query;
    dynamic response;
    try {
      response = await _apiClient.get('/member/fine-payment?$queryString');
    } catch (_) {
      try {
        response = await _apiClient.get('/member/fine-payments?$queryString');
      } catch (_) {
        try {
          response = await _apiClient.get('/member/fines?$queryString');
        } catch (_) {
          return [];
        }
      }
    }


    if (response is Map<String, dynamic>) {
      final list = (response['data'] is List)
          ? response['data'] as List<dynamic>
          : [];

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => FinePaymentItem.fromJson(item))
          .toList();
    }

    return [];
  }
}
