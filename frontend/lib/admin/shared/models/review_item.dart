// lib/admin/shared/models/review_item.dart

class ReviewItem {
  final String id;
  final String userId;
  final String username;
  final String userEmail;
  final String? userFullName;
  final String destinationId;
  final String destinationName;
  final int rating;
  final String? content;
  final String? createdAt;

  const ReviewItem({
    required this.id,
    required this.userId,
    required this.username,
    required this.userEmail,
    this.userFullName,
    required this.destinationId,
    required this.destinationName,
    required this.rating,
    this.content,
    this.createdAt,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> j) => ReviewItem(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        username: j['username'] as String? ?? '',
        userEmail: j['user_email'] as String? ?? '',
        userFullName: j['user_full_name'] as String?,
        destinationId: j['destination_id'] as String,
        destinationName: j['destination_name'] as String? ?? '',
        rating: j['rating'] as int? ?? 0,
        content: j['content'] as String?,
        createdAt: j['created_at'] as String?,
      );
}
