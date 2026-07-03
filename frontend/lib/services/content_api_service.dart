// lib/services/content_api_service.dart
//
// Mobile đọc content admin đã publish qua API public: GET /content/{type}.
// Trả ContentEntry (id String, data JSONB). KHÔNG auth.

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/content_entry.dart';
import 'api_service.dart';

class ContentApiService {
  /// Danh sách content published theo loại. `citySlug` để lọc theo thành phố.
  static Future<List<ContentEntry>> list(
    String contentType, {
    String? citySlug,
    int page = 1,
    int pageSize = 20,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'page_size': '$pageSize',
      if (citySlug != null && citySlug.isNotEmpty) 'city_slug': citySlug,
    };
    final uri = Uri.parse('${ApiConfig.baseUrl}/content/$contentType')
        .replace(queryParameters: params);
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) return [];
      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final items = decoded['items'] as List? ?? [];
      return items
          .whereType<Map<String, dynamic>>()
          .map(ContentEntry.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Chi tiết 1 content published.
  static Future<ContentEntry?> getById(
      String contentType, String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/content/$contentType/$id');
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) return null;
      return ContentEntry.fromJson(
          jsonDecode(resp.body) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
