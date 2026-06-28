// lib/admin/shared/models/chat_session_item.dart

class ChatSessionItem {
  final String id;
  final String? title;
  final List<String> tags;
  final bool isFlagged;
  final int totalMessages;
  final DateTime updatedAt;

  const ChatSessionItem({
    required this.id,
    this.title,
    required this.tags,
    required this.isFlagged,
    required this.totalMessages,
    required this.updatedAt,
  });

  factory ChatSessionItem.fromJson(Map<String, dynamic> json) =>
      ChatSessionItem(
        id: json['id'] as String,
        title: json['title'] as String?,
        tags: (json['tags'] as List?)?.cast<String>() ?? [],
        isFlagged: json['is_flagged'] as bool? ?? false,
        totalMessages: json['total_messages'] as int? ?? 0,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
}

class ChatMessageModel {
  final String id;
  final String role; // "user" | "assistant"
  final String content;
  final String? intent;
  final double? confidenceScore;
  final String? cacheHit;
  final int? latencyMs;
  final List<Map<String, dynamic>>? sources;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.role,
    required this.content,
    this.intent,
    this.confidenceScore,
    this.cacheHit,
    this.latencyMs,
    this.sources,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: json['id'] as String,
        role: json['role'] as String,
        content: json['content'] as String,
        intent: json['intent'] as String?,
        confidenceScore:
            (json['confidence_score'] as num?)?.toDouble(),
        cacheHit: json['cache_hit'] as String?,
        latencyMs: json['latency_ms'] as int?,
        sources: (json['sources'] as List?)
            ?.cast<Map<String, dynamic>>(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
