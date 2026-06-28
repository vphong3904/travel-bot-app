import 'admin_api.dart';

class AuditLogApi {
  final AdminApiClient client;
  const AuditLogApi(this.client);

  Future<Map<String, dynamic>> list({
    int page = 1,
    int pageSize = 20,
    String? action,
    String? actorId,
    String? resourceType,
  }) async {
    final params = {
      'page': page,
      'page_size': pageSize,
      if (action != null) 'action': action,
      if (actorId != null) 'actor_id': actorId,
      if (resourceType != null) 'resource_type': resourceType,
    }.entries.map((e) => '${e.key}=${e.value}').join('&');
    return await client.get('/admin/audit-logs?$params') as Map<String, dynamic>;
  }
}
