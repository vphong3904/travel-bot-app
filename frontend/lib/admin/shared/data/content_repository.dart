// lib/admin/shared/data/content_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_item.dart';
import '../providers/dio_provider.dart';

class ContentRepository {
  final Dio _dio;
  ContentRepository(this._dio);

  Future<({List<ContentItem> items, int total})> list({
    required String contentType,
    required String citySlug,
    String status = '',
    int page = 1,
  }) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/admin/content/$contentType',
      queryParameters: {
        'city_slug': citySlug,
        if (status.isNotEmpty) 'status': status,
        'page': page,
        'page_size': 20,
      },
    );
    final d = resp.data ?? {};
    final items = (d['items'] as List<dynamic>? ?? [])
        .map((e) =>
            ContentItem.fromJson(e as Map<String, dynamic>))
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
      queryParameters: {'city_slug': citySlug},
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
    await _dio.patch<void>(
        '/admin/content/$contentType/$itemId/publish');
  }

  Future<List<String>> fetchValidSlugs() async {
    final resp = await _dio
        .get<List<dynamic>>('/admin/city-mappings/valid-slugs');
    return (resp.data ?? []).cast<String>();
  }
}

final contentRepositoryProvider =
    Provider<ContentRepository>((ref) {
  return ContentRepository(ref.watch(apiDioProvider));
});
