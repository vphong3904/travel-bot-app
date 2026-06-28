enum UserRole {
  superAdmin,
  admin,
  contentManager,
  moderator,
  user;

  static UserRole fromString(String value) => switch (value) {
    'super_admin'     => UserRole.superAdmin,
    'admin'           => UserRole.admin,
    'content_manager' => UserRole.contentManager,
    'moderator'       => UserRole.moderator,
    _                 => UserRole.user,
  };

  String get displayName => switch (this) {
    UserRole.superAdmin     => 'Super Admin',
    UserRole.admin          => 'Admin',
    UserRole.contentManager => 'Content Manager',
    UserRole.moderator      => 'Moderator',
    UserRole.user           => 'User',
  };
}

class AdminUser {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;

  const AdminUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
    id: json['id'] as String,
    email: json['email'] as String,
    fullName: (json['full_name'] as String?) ?? '',
    role: UserRole.fromString((json['role'] as String?) ?? 'user'),
  );

  bool hasRole(List<UserRole> roles) => roles.contains(role);
}
