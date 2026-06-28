// lib/admin/shared/data/feedback_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feedback_item.dart';
import '../providers/dio_provider.dart';

class FeedbackRepository {
  final Dio _dio;
  FeedbackRepository(this._dio);

  Future<({List<FeedbackItem> items, int total})> list({
    String type = '',
    String category = '',
    String intent = '',
    int page = 1,
  }) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/admin/feedback',
      queryParameters: {
        if (type.isNotEmpty) 'type': type,
        if (category.isNotEmpty) 'category': category,
        if (intent.isNotEmpty) 'intent': intent,
        'page': page,
        'page_size': 20,
      },
    );
    final data = resp.data ?? {};
    return (
      items: (data['items'] as List<dynamic>? ?? [])
          .map((e) =>
              FeedbackItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: data['total'] as int? ?? 0,
    );
  }

  Future<void> resolve(String messageId) async {
    await _dio.patch<void>('/admin/feedback/$messageId/resolve');
  }

  Future<FeedbackStats> fetchStats() async {
    final resp = await _dio
        .get<Map<String, dynamic>>('/admin/stats/feedback');
    return FeedbackStats.fromJson(resp.data ?? {});
  }
}

final feedbackRepositoryProvider =
    Provider<FeedbackRepository>((ref) {
  return FeedbackRepository(ref.watch(apiDioProvider));
});
