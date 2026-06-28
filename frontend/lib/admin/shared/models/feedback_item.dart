// lib/admin/shared/models/feedback_item.dart

class FeedbackItem {
  final String messageId;
  final String sessionId;
  final String contentPreview;
  final String feedbackType;
  final String? category;
  final String? reason;
  final String? intent;
  final bool resolved;
  final String createdAt;

  const FeedbackItem({
    required this.messageId,
    required this.sessionId,
    required this.contentPreview,
    required this.feedbackType,
    this.category,
    this.reason,
    this.intent,
    required this.resolved,
    required this.createdAt,
  });

  factory FeedbackItem.fromJson(Map<String, dynamic> j) =>
      FeedbackItem(
        messageId: j['message_id'] as String,
        sessionId: j['session_id'] as String,
        contentPreview: j['content_preview'] as String? ?? '',
        feedbackType: j['feedback_type'] as String,
        category: j['feedback_category'] as String?,
        reason: j['feedback_reason'] as String?,
        intent: j['intent'] as String?,
        resolved: j['feedback_resolved'] as bool? ?? false,
        createdAt: j['created_at'] as String,
      );
}

class FeedbackStats {
  final List<({String date, int positive, int negative})> daily;

  const FeedbackStats({required this.daily});

  factory FeedbackStats.fromJson(Map<String, dynamic> j) =>
      FeedbackStats(
        daily: ((j['daily'] as List?) ?? [])
            .map((e) => (
                  date: e['date'] as String,
                  positive: e['positive'] as int,
                  negative: e['negative'] as int,
                ))
            .toList(),
      );

  int get totalPositive =>
      daily.fold(0, (s, e) => s + e.positive);
  int get totalNegative =>
      daily.fold(0, (s, e) => s + e.negative);
}
