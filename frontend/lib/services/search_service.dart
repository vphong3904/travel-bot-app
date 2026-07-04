// lib/services/search_service.dart
// Tra cứu tổng hợp: điểm đến, khách sạn, tour, nhà hàng, món ăn, mua sắm.
// Gọi GET /travel/search (public, tìm không dấu ở backend).
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class SearchItem {
  final String type;          // destination|hotel|tour|restaurant|food|shopping
  final String id;
  final String name;
  final String subtitle;      // tên tỉnh / điểm đến
  final String imageUrl;
  final double rating;
  final String? price;        // chuỗi hiển thị sẵn (vd "500.000đ/đêm")
  final String? tag;          // nhãn phụ (loại/hạng sao/tên địa phương...)
  final String destinationId; // để mở màn chi tiết điểm đến

  const SearchItem({
    required this.type,
    required this.id,
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    required this.rating,
    required this.destinationId,
    this.price,
    this.tag,
  });

  factory SearchItem.fromJson(Map<String, dynamic> j) => SearchItem(
        type: j['type']?.toString() ?? '',
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        subtitle: j['subtitle']?.toString() ?? '',
        imageUrl: j['image_url']?.toString() ?? '',
        rating: j['rating'] == null ? 0.0 : double.tryParse('${j['rating']}') ?? 0.0,
        price: j['price']?.toString(),
        tag: j['tag']?.toString(),
        destinationId: j['destination_id']?.toString() ?? '',
      );
}

class SearchResult {
  final String query;
  final int total;
  final Map<String, int> counts;
  final List<SearchItem> results;

  const SearchResult({
    required this.query,
    required this.total,
    required this.counts,
    required this.results,
  });

  static const empty = SearchResult(query: '', total: 0, counts: {}, results: []);
}

class SearchRepository {
  static Future<SearchResult> searchAll(
    String q, {
    String? types,
    int limitPerType = 12,
  }) async {
    final params = <String, String>{
      'q': q,
      'limit_per_type': '$limitPerType',
    };
    if (types != null && types.isNotEmpty) params['types'] = types;

    final uri = Uri.parse('${ApiConfig.baseUrl}/travel/search')
        .replace(queryParameters: params);
    try {
      final res = await http.get(uri).timeout(ApiConfig.timeout);
      if (res.statusCode != 200) return SearchResult.empty;
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      if (decoded is! Map) return SearchResult.empty;

      final rawResults = decoded['results'];
      final items = <SearchItem>[];
      if (rawResults is List) {
        for (final e in rawResults) {
          if (e is Map) items.add(SearchItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
      final counts = <String, int>{};
      final rawCounts = decoded['counts'];
      if (rawCounts is Map) {
        rawCounts.forEach((k, v) => counts['$k'] = int.tryParse('$v') ?? 0);
      }
      return SearchResult(
        query: decoded['query']?.toString() ?? q,
        total: int.tryParse('${decoded['total']}') ?? items.length,
        counts: counts,
        results: items,
      );
    } catch (_) {
      return SearchResult.empty;
    }
  }

  // Chi tiết 1 entity (hotel/tour/restaurant/food/shopping) theo id.
  // Trả map thô để màn EntityDetailScreen render linh hoạt theo loại.
  static Future<Map<String, dynamic>?> fetchItemDetail(String type, String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/travel/items/$type/$id');
    try {
      final res = await http.get(uri).timeout(ApiConfig.timeout);
      if (res.statusCode != 200) return null;
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      if (decoded is! Map) return null;
      return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return null;
    }
  }
}
