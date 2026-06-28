// lib/admin/shared/models/user_model.dart

class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String role;
  final bool isActive;
  final String authProvider;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    required this.role,
    required this.isActive,
    required this.authProvider,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['full_name'] as String?,
        role: json['role'] as String,
        isActive: json['is_active'] as bool,
        authProvider: json['auth_provider'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
}

class ChatSessionSummary {
  final String id;
  final String? title;
  final int totalMessages;
  final DateTime updatedAt;

  const ChatSessionSummary({
    required this.id,
    this.title,
    required this.totalMessages,
    required this.updatedAt,
  });

  factory ChatSessionSummary.fromJson(Map<String, dynamic> json) =>
      ChatSessionSummary(
        id: json['id'] as String,
        title: json['title'] as String?,
        totalMessages: json['total_messages'] as int,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
}

class UserDetail extends UserModel {
  final int totalChatSessions;
  final int totalMessages;
  final List<ChatSessionSummary> recentSessions;

  const UserDetail({
    required super.id,
    required super.email,
    super.fullName,
    required super.role,
    required super.isActive,
    required super.authProvider,
    required super.createdAt,
    required super.updatedAt,
    required this.totalChatSessions,
    required this.totalMessages,
    required this.recentSessions,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) => UserDetail(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['full_name'] as String?,
        role: json['role'] as String,
        isActive: json['is_active'] as bool,
        authProvider: json['auth_provider'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        totalChatSessions: json['total_chat_sessions'] as int,
        totalMessages: json['total_messages'] as int,
        recentSessions: (json['recent_sessions'] as List)
            .map((e) =>
                ChatSessionSummary.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
