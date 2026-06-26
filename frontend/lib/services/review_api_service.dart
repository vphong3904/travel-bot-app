// lib/services/review_api_service.dart
import '../models/review.dart';
import 'api_service.dart';

class ReviewApiService {
  final ApiClient _client;
  ReviewApiService({required String token}) : _client = ApiClient(token: token);

  Future<List<Review>> listReviews(String destinationId, {int limit = 20}) async {
    final data = await _client.get(
      '/travel/destinations/$destinationId/reviews',
      {'limit': '$limit'},
    ) as List<dynamic>;
    return data
        .map((e) => Review.fromJson(e is Map ? Map<String, dynamic>.from(e) : {}))
        .toList();
  }

  Future<Review?> getMyReview(String destinationId) async {
    try {
      final data = await _client.get('/travel/destinations/$destinationId/reviews/me') as Map<String, dynamic>;
      return Review.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<Review> createReview(String destinationId, {required int rating, String? content}) async {
    final data = await _client.post(
      '/travel/destinations/$destinationId/reviews',
      {'rating': rating, if (content != null && content.isNotEmpty) 'content': content},
    ) as Map<String, dynamic>;
    return Review.fromJson(data);
  }

  Future<void> deleteReview(String destinationId, String reviewId) async {
    await _client.delete('/travel/destinations/$destinationId/reviews/$reviewId');
  }
}
