// lib/services/auth_api_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// AuthApiService — wrap toàn bộ các call tới /auth/*
//
// ⚠️  Flow login:
//   1. POST /auth/login → nhận {access_token, refresh_token}
//   2. GET  /auth/me   → nhận UserResponse (cần để lấy user info)
//
// Backend login KHÔNG trả user object trong response — phải gọi /me riêng.
// ─────────────────────────────────────────────────────────────────────────────

import '../models/app_user.dart';
import 'api_service.dart';

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'bearer',
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
        tokenType: json['token_type'] as String? ?? 'bearer',
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class AuthApiService {
  // ── Login ──────────────────────────────────────────────────────────────────

  /// Đăng nhập → trả về (tokens, user).
  /// Tự động gọi /auth/me sau khi lấy được token.
  static Future<({AuthTokens tokens, AppUser user})> login(
    String email,
    String password,
  ) async {
    final client = ApiClient(); // không cần token lúc login

    // 1. Lấy token
    final tokenData = await client.post('/auth/login', {
      'email': email.trim(),
      'password': password,
    }) as Map<String, dynamic>;

    final tokens = AuthTokens.fromJson(tokenData);

    // 2. Lấy user info bằng access token
    final userClient = ApiClient(token: tokens.accessToken);
    final userData = await userClient.get('/auth/me') as Map<String, dynamic>;
    final user = AppUser.fromJson(userData);

    return (tokens: tokens, user: user);
  }

  // ── Register ───────────────────────────────────────────────────────────────

  /// Đăng ký → trả về UserResponse (backend trả 201 + user, không có token).
  /// Sau khi đăng ký xong nên gọi login() để lấy token.
  static Future<AppUser> register({
    required String username,   // dùng làm login name
    required String email,
    required String password,
    String? fullName,
  }) async {
    final client = ApiClient();
    final data = await client.post('/auth/register', {
      'username': username.trim(),
      'email': email.trim(),
      'password': password,
      if (fullName != null && fullName.isNotEmpty) 'full_name': fullName.trim(),
    }) as Map<String, dynamic>;

    return AppUser.fromJson(data);
  }

  // ── Refresh token ──────────────────────────────────────────────────────────

  static Future<AuthTokens> refresh(String refreshToken) async {
    final client = ApiClient();
    final data = await client.post('/auth/refresh', {
      'refresh_token': refreshToken,
    }) as Map<String, dynamic>;
    return AuthTokens.fromJson(data);
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  static Future<void> logout(String refreshToken) async {
    final client = ApiClient();
    try {
      await client.post('/auth/logout', {'refresh_token': refreshToken});
    } catch (_) {
      // Bỏ qua lỗi logout — local session đã xóa là đủ
    }
  }

  // ── Get current user ───────────────────────────────────────────────────────

  static Future<AppUser> me(String accessToken) async {
    final client = ApiClient(token: accessToken);
    final data = await client.get('/auth/me') as Map<String, dynamic>;
    return AppUser.fromJson(data);
  }

  // ── Update profile ─────────────────────────────────────────────────────────

  static Future<AppUser> updateProfile(
    String accessToken, {
    String? fullName,
    String? avatarUrl,
  }) async {
    final client = ApiClient(token: accessToken);
    final body = <String, dynamic>{};
    if (fullName != null) body['full_name'] = fullName;
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;

    final data = await client.patch('/auth/me', body) as Map<String, dynamic>;
    return AppUser.fromJson(data);
  }
}