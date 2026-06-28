import 'admin_api.dart';

class KnowledgeApi {
  final AdminApiClient client;
  const KnowledgeApi(this.client);

  Future<List<dynamic>> list({bool isActive = true, int skip = 0, int limit = 50}) async {
    return await client.get('/admin/knowledge?is_active=$isActive&skip=$skip&limit=$limit')
        as List<dynamic>;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    return await client.post('/admin/knowledge', body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> body) async {
    return await client.patch('/admin/knowledge/$id', body) as Map<String, dynamic>;
  }

  Future<void> delete(String id) async {
    await client.delete('/admin/knowledge/$id');
  }
}
