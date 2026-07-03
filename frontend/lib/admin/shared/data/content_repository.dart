// lib/admin/shared/data/content_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_item.dart';
import '../providers/dio_provider.dart';

/// 1 city trong dropdown filter (từ GET /admin/cities).
class CityOption {
  final String slug;
  final String name;
  final String? province;
  const CityOption({required this.slug, required this.name, this.province});

  factory CityOption.fromJson(Map<String, dynamic> j) => CityOption(
        slug: j['slug'] as String,
        name: (j['name'] ?? j['slug']) as String,
        province: j['province'] as String?,
      );
}

class ContentRepository {
  final Dio _dio;
  ContentRepository(this._dio);

  Future<({List<ContentItem> items, int total})> list({
    required String contentType,
    String citySlug = '',
    String status = '',
    String search = '',
    String sort = 'newest',
    String dateFrom = '',
    String dateTo = '',
    String field = '',
    String value = '',
    int page = 1,
  }) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/admin/content/$contentType',
      queryParameters: {
        if (citySlug.isNotEmpty) 'city_slug': citySlug,
        if (status.isNotEmpty) 'status': status,
        if (search.isNotEmpty) 'search': search,
        'sort': sort,
        if (dateFrom.isNotEmpty) 'date_from': dateFrom,
        if (dateTo.isNotEmpty) 'date_to': dateTo,
        if (field.isNotEmpty && value.isNotEmpty) 'field': field,
        if (field.isNotEmpty && value.isNotEmpty) 'value': value,
        'page': page,
        'page_size': 20,
      },
    );
    final d = resp.data ?? {};
    final items = (d['items'] as List<dynamic>? ?? [])
        .map((e) => ContentItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return (items: items, total: d['total'] as int? ?? 0);
  }

  Future<void> create({
    required String contentType,
    required String citySlug,
    required Map<String, dynamic> data,
  }) async {
    await _dio.post<void>(
      '/admin/content/$contentType',
      queryParameters: {if (citySlug.isNotEmpty) 'city_slug': citySlug},
      data: data,
    );
  }

  Future<void> update({
    required String contentType,
    required String itemId,
    required Map<String, dynamic> data,
  }) async {
    await _dio.patch<void>(
      '/admin/content/$contentType/$itemId',
      data: data,
    );
  }

  Future<void> delete(
    String contentType,
    String citySlug,
    String itemId,
  ) async {
    await _dio.delete<void>('/admin/content/$contentType/$itemId');
  }

  Future<void> publish(
    String contentType,
    String citySlug,
    String itemId,
  ) async {
    await _dio.patch<void>('/admin/content/$contentType/$itemId/publish');
  }

  /// Danh sách city cho dropdown (tên đẹp, value = slug).
  Future<List<CityOption>> fetchCities() async {
    final resp = await _dio.get<List<dynamic>>('/admin/cities');
    return (resp.data ?? [])
        .map((e) => CityOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository(ref.watch(apiDioProvider));
});
