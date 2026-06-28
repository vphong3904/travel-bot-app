// lib/models/chat_session_model.dart
// ─────────────────────────────────────────────────────────────────────────────
// Ánh xạ ChatSessionOut + ChatMessageOut từ backend.
//
// ⚠️  id, session_id, user_id đều là UUID (String), KHÔNG phải int.
// Backend KHÔNG trả user_name trong session — chỉ có user_id.
// ─────────────────────────────────────────────────────────────────────────────

class ChatSessionModel {
  final String id;       // UUID
  final String userId;   // UUID
  final String? title;
  final String modelName;
  final int totalMessages;
  final int totalTokens;
  final bool pinned;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Messages chỉ có khi load detail — list session không trả
  final List<ChatMessageModel> messages;

  const ChatSessionModel({
    required this.id,
    required this.userId,
    this.title,
    this.modelName = 'gemini-1.5-flash',
    this.totalMessages = 0,
    this.totalTokens = 0,
    this.pinned = false,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
    this.messages = const [],
  });

  /// Tên hiển thị trong danh sách lịch sử
  String get displayTitle =>
      (title != null && title!.isNotEmpty) ? title! : 'Cuộc hội thoại mới';

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) =>
      ChatSessionModel(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        title: json['title']?.toString(),
        modelName: json['model_name']?.toString() ?? 'gemini-1.5-flash',
        totalMessages: json['total_messages'] as int? ?? 0,
        totalTokens: json['total_tokens'] as int? ?? 0,
        pinned: json['pinned'] as bool? ?? false,
        isDeleted: json['is_deleted'] as bool? ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString())
            : null,
        messages: (json['messages'] as List<dynamic>? ?? [])
            .map((m) => ChatMessageModel.fromJson(m as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'model_name': modelName,
        'total_messages': totalMessages,
        'total_tokens': totalTokens,
        'pinned': pinned,
        'is_deleted': isDeleted,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  ChatSessionModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? modelName,
    int? totalMessages,
    int? totalTokens,
    bool? pinned,
    DateTime? updatedAt,
    List<ChatMessageModel>? messages,
  }) =>
      ChatSessionModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        modelName: modelName ?? this.modelName,
        totalMessages: totalMessages ?? this.totalMessages,
        totalTokens: totalTokens ?? this.totalTokens,
        pinned: pinned ?? this.pinned,
        isDeleted: isDeleted,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        messages: messages ?? this.messages,
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class ChatMessageModel {
  final String id;         // UUID
  final String sessionId;  // UUID
  final String role;       // 'user' | 'assistant'
  final String content;
  final List<dynamic> sources;
  final String? intent;
  final int promptTokens;
  final int completionTokens;
  final int? latencyMs;
  final int? feedback;     // -1, 0, 1
  final DateTime? createdAt;

  const ChatMessageModel({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    this.sources = const [],
    this.intent,
    this.promptTokens = 0,
    this.completionTokens = 0,
    this.latencyMs,
    this.feedback,
    this.createdAt,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: json['id']?.toString() ?? '',
        sessionId: json['session_id']?.toString() ?? '',
        role: json['role']?.toString() ?? 'user',
        content: json['content']?.toString() ?? '',
        sources: json['sources'] as List<dynamic>? ?? [],
        intent: json['intent']?.toString(),
        promptTokens: json['prompt_tokens'] as int? ?? 0,
        completionTokens: json['completion_tokens'] as int? ?? 0,
        latencyMs: json['latency_ms'] as int?,
        feedback: json['feedback'] as int?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
      );
}