import 'admin_api.dart';

class DashboardApi {
  final AdminApiClient client;
  const DashboardApi(this.client);

  Future<Map<String, dynamic>> statsChatbot({int days = 30}) async {
    return await client.get('/admin/stats/chatbot?days=$days') as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> statsUsers({int days = 30}) async {
    return await client.get('/admin/stats/users?days=$days') as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> statsQuestions({int days = 30}) async {
    return await client.get('/admin/stats/questions?days=$days') as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> statsDestinations({int days = 30}) async {
    return await client.get('/admin/stats/destinations?days=$days') as Map<String, dynamic>;
  }
}
