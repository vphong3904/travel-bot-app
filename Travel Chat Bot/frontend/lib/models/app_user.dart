// lib/models/app_user.dart
// ─────────────────────────────────────────────────────────────────────────────
// AppUser — model ánh xạ UserResponse từ backend.
//
// Backend trả:
//   { "id": "uuid-string", "username": "...", "email": "...",
//     "full_name": "...", "avatar_url": null, "role": "user",
//     "is_active": true, "created_at": "..." }
//
// ⚠️  id là UUID (String), KHÔNG phải int.
// ─────────────────────────────────────────────────────────────────────────────

class AppUser {
  final String id;          // UUID từ backend
  final String username;    // login name
  final String email;
  final String? fullName;   // full_name (nullable)
  final String? avatarUrl;
  final String role;        // 'user' | 'admin' | 'moderator' | ...
  final bool isActive;
  final DateTime? createdAt;

  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.role,
    this.isActive = true,
    this.createdAt,
  });

  // ── Computed ───────────────────────────────────────────────────────────────

  /// Tên hiển thị: ưu tiên fullName, fallback sang username
  String get displayName => (fullName != null && fullName!.isNotEmpty) ? fullName! : username;

  bool get isAdmin => role == 'admin';
  bool get isModerator => role == 'moderator';
  bool get isStaff => isAdmin || isModerator;

  // ── Serialization ──────────────────────────────────────────────────────────

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        fullName: json['full_name']?.toString(),
        avatarUrl: json['avatar_url']?.toString(),
        role: json['role']?.toString() ?? 'user',
        isActive: json['is_active'] as bool? ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'role': role,
        'is_active': isActive,
        'created_at': createdAt?.toIso8601String(),
      };

  AppUser copyWith({
    String? id,
    String? username,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? role,
    bool? isActive,
    DateTime? createdAt,
  }) =>
      AppUser(
        id: id ?? this.id,
        username: username ?? this.username,
        email: email ?? this.email,
        fullName: fullName ?? this.fullName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        role: role ?? this.role,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
}