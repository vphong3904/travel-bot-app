// lib/admin/shared/models/user_session.dart

class UserSession {
  final String id;
  final String? ipAddress;
  final String? userAgent;
  final String createdAt;
  final String expiresAt;

  const UserSession({
    required this.id,
    this.ipAddress,
    this.userAgent,
    required this.createdAt,
    required this.expiresAt,
  });

  factory UserSession.fromJson(Map<String, dynamic> j) =>
      UserSession(
        id: j['id'] as String,
        ipAddress: j['ip_address'] as String?,
        userAgent: j['user_agent'] as String?,
        createdAt: j['created_at'] as String,
        expiresAt: j['expires_at'] as String,
      );

  bool get isExpired =>
      DateTime.parse(expiresAt).isBefore(DateTime.now());
}
