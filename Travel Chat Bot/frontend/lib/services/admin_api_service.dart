// lib/services/admin_api_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// AdminApiService — authenticated API wrapper for admin endpoints.
// All methods require a valid Bearer token.
// ─────────────────────────────────────────────────────────────────────────────

import 'api_service.dart';

class AdminApiService {
  final String? token;

  AdminApiService({this.token});

  ApiClient get _client => ApiClient(token: token);

  // ── Stats ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getStats() async {
    final data = await _client.get('/admin/stats') as Map<String, dynamic>;
    return data;
  }

  // ── Users ──────────────────────────────────────────────────────────────────

  Future<List<dynamic>> getUsers() async {
    final data = await _client.get('/admin/users') as List<dynamic>;
    return data;
  }

  Future<bool> toggleUser(String userId) async {
    try {
      await _client.patch('/admin/users/$userId/toggle');
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Knowledge Base ─────────────────────────────────────────────────────────

  Future<List<dynamic>> getKB({String? category}) async {
    final params = category != null ? {'category': category} : <String, String>{};
    final data = await _client.get('/admin/kb', params) as List<dynamic>;
    return data;
  }

  Future<bool> createKB(Map<String, dynamic> data) async {
    try {
      await _client.post('/admin/kb', data);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateKB(String kbId, Map<String, dynamic> data) async {
    try {
      await _client.patch('/admin/kb/$kbId', data);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteKB(String kbId) async {
    try {
      await _client.delete('/admin/kb/$kbId');
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Chat Logs ──────────────────────────────────────────────────────────────

  Future<List<dynamic>> getChatLogs({String? intent}) async {
    final params = intent != null ? {'intent': intent} : <String, String>{};
    final data = await _client.get('/admin/chat-logs', params) as List<dynamic>;
    return data;
  }
}
