// lib/services/destination_service.dart
//
// FIX:
//   - Backend trả List trực tiếp (không phải {items: [...]})
//   - Thêm token header cho các call cần auth (trackView)
//   - fetchCategories: không cần auth
//   - fetchDestinations: không cần auth, params đúng theo backend
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/destination.dart';
import 'api_service.dart';

class DestinationRepository {
  // ── List destinations ───────────────────────────────────────────────────────
  static Future<List<Destination>> fetchDestinations({
    String? search,
    String? category,
    String? region,
    int? budgetMax,
    int? budgetMin,
    int? month,
    String sortBy = 'name',
    int limit = 20,
    int skip = 0,
  }) async {
    final params = <String, String>{
      'sort_by': sortBy,
      'limit': '$limit',
      'skip': '$skip',
    };
    if (search != null && search.isNotEmpty) params['q'] = search;
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (region != null && region.isNotEmpty) params['region'] = region;
    // Backend dùng budget_max / budget_min (không phải budgetMax/budgetMin)
    if (budgetMax != null) params['budget_max'] = '$budgetMax';
    if (budgetMin != null) params['budget_min'] = '$budgetMin';
    if (month != null) params['month'] = '$month';

    final uri = Uri.parse('${ApiConfig.baseUrl}/travel/destinations')
        .replace(queryParameters: params);

    try {
      final res = await http.get(uri).timeout(ApiConfig.timeout);
      if (res.statusCode != 200) return [];

      // Backend trả thẳng List, không bọc trong {items: []}
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      if (decoded is! List) return [];

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Destination.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  // Shortcut: top 4 theo lượt xem cho banner Hot
  static Future<List<Destination>> fetchHot({int limit = 4}) =>
      fetchDestinations(sortBy: 'popular', limit: limit);

  // ── Destination detail ──────────────────────────────────────────────────────
  static Future<Destination?> fetchDestination(String id) async {
    try {
      final res = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/travel/destinations/$id'))
          .timeout(ApiConfig.timeout);
      if (res.statusCode != 200) return null;
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      if (decoded is! Map) return null;
      return Destination.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  // ── Categories ─────────────────────────────────────────────────────────────
  // GET /travel/categories → không cần auth, trả List trực tiếp
  static Future<List<Category>> fetchCategories() async {
    try {
      final res = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/travel/categories'))
          .timeout(ApiConfig.timeout);
      if (res.statusCode != 200) return [];
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      if (decoded is! List) return [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Category.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Track view ──────────────────────────────────────────────────────────────
  // POST /travel/destinations/:id/view — cần auth, non-critical
  static Future<void> trackView(String destinationId, String token) async {
    try {
      await http
          .post(
            Uri.parse(
                '${ApiConfig.baseUrl}/travel/destinations/$destinationId/view'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // non-critical
    }
  }
}