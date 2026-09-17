import '../models/dashboard_data.dart';
import '../utils/api_client.dart';

class DashboardService {
  final ApiClient _apiClient;

  DashboardService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  Future<DashboardData> getDashboardData() async {
    return fetchDashboardData();
  }

  Future<DashboardData> fetchDashboardData() async {
    final response = await _apiClient.get('/member/dashboard');

    if (response is Map<String, dynamic>) {
      final data = (response['data'] is Map<String, dynamic>)
          ? response['data'] as Map<String, dynamic>
          : response;

      return DashboardData.fromJson(data);
    }

    return const DashboardData();
  }
}
