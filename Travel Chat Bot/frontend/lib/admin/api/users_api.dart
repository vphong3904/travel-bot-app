import 'admin_api.dart';

class UsersApi {
  final AdminApiClient client;
  const UsersApi(this.client);

  Future<List<dynamic>> list({int skip = 0, int limit = 50}) async {
    return await client.get('/admin/users?skip=$skip&limit=$limit') as List<dynamic>;
  }

  Future<Map<String, dynamic>> updateRole(String userId, String role) async {
    return await client.patch('/admin/users/$userId/role', {'role': role})
        as Map<String, dynamic>;
  }
}
