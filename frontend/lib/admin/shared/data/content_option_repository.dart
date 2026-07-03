// lib/admin/shared/data/content_option_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_option.dart';
import '../providers/dio_provider.dart';

class ContentOptionRepository {
  final Dio _dio;
  ContentOptionRepository(this._dio);

  Future<List<ContentOption>> list({String? contentType, String? field}) async {
    final resp = await _dio.get<List<dynamic>>(
      '/admin/content-options',
      queryParameters: {
        if (contentType != null) 'content_type': contentType,
        if (field != null) 'field': field,
      },
    );
    return (resp.data ?? [])
        .map((e) => ContentOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> create({
    required String contentType,
    required String field,
    required String code,
    required String label,
    int sortOrder = 0,
  }) async {
    await _dio.post<void>('/admin/content-options', data: {
      'content_type': contentType,
      'field': field,
      'code': code,
      'label': label,
      'sort_order': sortOrder,
    });
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _dio.patch<void>('/admin/content-options/$id', data: data);
  }

  Future<void> delete(String id) async {
    await _dio.delete<void>('/admin/content-options/$id');
  }
}

final contentOptionRepositoryProvider =
    Provider<ContentOptionRepository>((ref) {
  return ContentOptionRepository(ref.watch(apiDioProvider));
});

/// Options theo 1 content_type (form + bảng dùng, tự lọc field/is_active).
final contentOptionsProvider = FutureProvider.autoDispose
    .family<List<ContentOption>, String>((ref, contentType) {
  return ref
      .watch(contentOptionRepositoryProvider)
      .list(contentType: contentType);
});

/// Toàn bộ options (màn quản lý).
final allContentOptionsProvider =
    FutureProvider.autoDispose<List<ContentOption>>((ref) {
  return ref.watch(contentOptionRepositoryProvider).list();
});
