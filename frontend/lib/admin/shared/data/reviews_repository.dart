// lib/admin/shared/data/reviews_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review_item.dart';
import '../providers/dio_provider.dart';

class ReviewsRepository {
  final Dio _dio;
  ReviewsRepository(this._dio);

  Future<({List<ReviewItem> items, int total})> listReviews({
    String search = '',
    int? rating,
    int page = 1,
    int pageSize = 20,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/admin/reviews',
      queryParameters: {
        if (search.isNotEmpty) 'search': search,
        if (rating != null) 'rating': rating,
        'skip': (page - 1) * pageSize,
        'limit': pageSize,
      },
    );
    final data = res.data!;
    return (
      items: (data['items'] as List)
          .map((e) => ReviewItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: data['total'] as int,
    );
  }

  /// Xoá review bất kỳ (moderation) — chỉ admin/super_admin (backend chặn qua RBAC).
  Future<void> deleteReview(String reviewId) async {
    await _dio.delete<void>('/admin/reviews/$reviewId');
  }
}

final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  return ReviewsRepository(ref.watch(apiDioProvider));
});
