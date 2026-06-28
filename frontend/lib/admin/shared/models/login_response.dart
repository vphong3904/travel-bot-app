// lib/features/auth/models/login_response.dart
import 'auth_user.dart';

class LoginResponse {
  final String accessToken;
  final String tokenType;
  final AuthUser user;

  const LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    accessToken: json['access_token'] as String,
    tokenType: json['token_type'] as String? ?? 'bearer',
    user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
  );
}
