class ChatSessionModel {
  final int id;
  final int userId;
  final String userName;
  final String? title;
  final String? summary;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessageModel> messages;

  ChatSessionModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.title,
    this.summary,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) =>
      ChatSessionModel(
        id: json['id'],
        userId: json['user_id'],
        userName: json['user_name'] ?? 'Khách',
        title: json['title'],
        summary: json['summary'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        messages: (json['messages'] as List<dynamic>? ?? [])
            .map((m) => ChatMessageModel.fromJson(m as Map<String, dynamic>))
            .toList(),
      );

  String get displayTitle {
    if (title != null && title!.isNotEmpty) return title!;
    return 'Cuộc hội thoại #$id';
  }
}

class ChatMessageModel {
  final int id;
  final int? sessionId;
  final String message;
  final String response;
  final String intent;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    this.sessionId,
    required this.message,
    required this.response,
    required this.intent,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: json['id'],
        sessionId: json['session_id'],
        message: json['message'],
        response: json['response'],
        intent: json['intent'] ?? '',
        createdAt: DateTime.parse(json['created_at']),
      );
}