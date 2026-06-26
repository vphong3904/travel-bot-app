// lib/models/review.dart

class Review {
  final String id;
  final String userId;
  final String destinationId;
  final int rating;
  final String? content;
  final DateTime? createdAt;
  final String? username;
  final String? avatarUrl;

  const Review({
    required this.id,
    required this.userId,
    required this.destinationId,
    required this.rating,
    this.content,
    this.createdAt,
    this.username,
    this.avatarUrl,
  });

  factory Review.fromJson(Map<String, dynamic> j) => Review(
        id: j['id']?.toString() ?? '',
        userId: j['user_id']?.toString() ?? '',
        destinationId: j['destination_id']?.toString() ?? '',
        rating: j['rating'] is int ? j['rating'] as int : int.tryParse('${j['rating']}') ?? 0,
        content: j['content']?.toString(),
        createdAt: j['created_at'] != null ? DateTime.tryParse(j['created_at'].toString()) : null,
        username: j['username']?.toString(),
        avatarUrl: j['avatar_url']?.toString(),
      );
}
