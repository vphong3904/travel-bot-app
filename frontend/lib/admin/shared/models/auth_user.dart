// lib/features/auth/models/auth_user.dart

/// Các role trong hệ thống admin PDTrip
/// Thứ tự quyền: super_admin > admin > content_manager > moderator > user
enum AdminRole {
  superAdmin,
  admin,
  contentManager,
  moderator,
  user;

  static AdminRole fromString(String value) {
    return switch (value) {
      'super_admin' => AdminRole.superAdmin,
      'admin' => AdminRole.admin,
      'content_manager' => AdminRole.contentManager,
      'moderator' => AdminRole.moderator,
      _ => AdminRole.user,
    };
  }

  String get displayName => switch (this) {
    AdminRole.superAdmin => 'Super Admin',
    AdminRole.admin => 'Admin',
    AdminRole.contentManager => 'Content Manager',
    AdminRole.moderator => 'Moderator',
    AdminRole.user => 'User',
  };
}

class AuthUser {
  final String id;
  final String email;
  final String fullName;
  final AdminRole role;

  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String,
    email: json['email'] as String,
    fullName: json['full_name'] as String? ?? '',
    role: AdminRole.fromString(json['role'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'role': role.name,
  };
}
