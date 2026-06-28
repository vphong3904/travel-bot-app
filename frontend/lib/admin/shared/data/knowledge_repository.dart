// lib/admin/shared/data/knowledge_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/knowledge_entry.dart';
import '../providers/dio_provider.dart';

class KnowledgeRepository {
  final Dio _dio;
  KnowledgeRepository(this._dio);

  Future<({List<KnowledgeEntry> items, int total})> list({
    String search = '',
    String category = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/admin/knowledge',
      queryParameters: {
        if (search.isNotEmpty) 'search': search,
        if (category.isNotEmpty) 'category': category,
        'page': page,
        'page_size': pageSize,
      },
    );
    final data = resp.data!;
    return (
      items: (data['items'] as List)
          .map((e) => KnowledgeEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: data['total'] as int,
    );
  }

  Future<KnowledgeEntry> create(Map<String, dynamic> body) async {
    final resp =
        await _dio.post<Map<String, dynamic>>('/admin/knowledge', data: body);
    return KnowledgeEntry.fromJson(resp.data!);
  }

  Future<KnowledgeEntry> update(String id, Map<String, dynamic> body) async {
    final resp = await _dio.patch<Map<String, dynamic>>(
        '/admin/knowledge/$id', data: body);
    return KnowledgeEntry.fromJson(resp.data!);
  }

  Future<void> delete(String id) =>
      _dio.delete<void>('/admin/knowledge/$id');

  Future<String> getJobStatus(String jobId) async {
    final resp = await _dio
        .get<Map<String, dynamic>>('/admin/embedding-jobs/$jobId');
    return resp.data!['status'] as String;
  }
}

final knowledgeRepositoryProvider = Provider<KnowledgeRepository>((ref) {
  return KnowledgeRepository(ref.watch(apiDioProvider));
});
