// lib/services/auth_api_service.dart
//
// AuthApiService — wrap toàn bộ /auth/* endpoints
//
// Endpoints được hỗ trợ:
//   register/send-otp  → Bước 1 đăng ký (gửi OTP)
//   register/confirm   → Bước 2 đăng ký (xác nhận OTP + tạo tài khoản)
//   otp/resend         → Gửi lại OTP
//   login              → Đăng nhập email+password
//   google             → Đăng nhập Google OAuth
//   forgot-password    → Gửi OTP quên mật khẩu
//   reset-password     → Đặt lại mật khẩu qua OTP
//   refresh            → Refresh access token
//   logout             → Đăng xuất
//   me (GET)           → Lấy thông tin user hiện tại
//   me (PATCH)         → Cập nhật profile
//   me/password        → Đổi mật khẩu
// ---------------------------------------------------------------------------

import '../models/app_user.dart';
import 'api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

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
  // ── ĐĂNG KÝ — Bước 1: Gửi OTP ────────────────────────────────────────────

  /// Gửi OTP xác nhận email.
  /// Gọi trước khi tạo tài khoản, OTP hết hạn sau 10 phút.
  static Future<void> registerSendOtp({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    final client = ApiClient();
    await client.post('/auth/register/send-otp', {
      'username': username.trim().toLowerCase(),
      'email': email.trim().toLowerCase(),
      'password': password,
      if (fullName != null && fullName.isNotEmpty) 'full_name': fullName.trim(),
    });
  }

  // ── ĐĂNG KÝ — Bước 2: Xác nhận OTP + tạo tài khoản ──────────────────────

  /// Xác nhận OTP và tạo tài khoản.
  /// Trả về tokens ngay sau khi tạo (không cần login riêng).
  static Future<({AuthTokens tokens, AppUser user})> registerConfirm({
    required String username,
    required String email,
    required String password,
    required String otpCode,
    String? fullName,
  }) async {
    final client = ApiClient();
    final tokenData = await client.post('/auth/register/confirm', {
      'username': username.trim().toLowerCase(),
      'email': email.trim().toLowerCase(),
      'password': password,
      'otp_code': otpCode.trim(),
      if (fullName != null && fullName.isNotEmpty) 'full_name': fullName.trim(),
    }) as Map<String, dynamic>;

    final tokens = AuthTokens.fromJson(tokenData);

    // Lấy thông tin user
    final userClient = ApiClient(token: tokens.accessToken);
    final userData = await userClient.get('/auth/me') as Map<String, dynamic>;
    final user = AppUser.fromJson(userData);

    return (tokens: tokens, user: user);
  }

  // ── GỬI LẠI OTP ───────────────────────────────────────────────────────────

  /// Gửi lại OTP. purpose: 'register' | 'reset_password'
  static Future<void> resendOtp({
    required String email,
    required String purpose,
  }) async {
    final client = ApiClient();
    await client.post('/auth/otp/resend', {
      'email': email.trim().toLowerCase(),
      'purpose': purpose,
    });
  }

  // ── ĐĂNG NHẬP EMAIL + PASSWORD ─────────────────────────────────────────────

  /// Đăng nhập → trả về (tokens, user).
  /// Email case-insensitive. Password case-sensitive.
  static Future<({AuthTokens tokens, AppUser user})> login(
    String email,
    String password,
  ) async {
    final client = ApiClient();

    final tokenData = await client.post('/auth/login', {
      'email': email.trim().toLowerCase(),
      'password': password, // KHÔNG lowercase — case-sensitive
    }) as Map<String, dynamic>;

    final tokens = AuthTokens.fromJson(tokenData);

    final userClient = ApiClient(token: tokens.accessToken);
    final userData = await userClient.get('/auth/me') as Map<String, dynamic>;
    final user = AppUser.fromJson(userData);

    return (tokens: tokens, user: user);
  }

  // ── ĐĂNG NHẬP GOOGLE OAUTH ────────────────────────────────────────────────

  /// Đăng nhập / đăng ký bằng Google.
  /// Frontend lấy id_token từ google_sign_in package rồi gửi lên.
  /// Không cần OTP — Google đã verify email.
  static Future<({AuthTokens tokens, AppUser user})> loginWithGoogle(
    String idToken,
  ) async {
    final client = ApiClient();

    final tokenData = await client.post('/auth/google', {
      'id_token': idToken,
    }) as Map<String, dynamic>;

    final tokens = AuthTokens.fromJson(tokenData);

    final userClient = ApiClient(token: tokens.accessToken);
    final userData = await userClient.get('/auth/me') as Map<String, dynamic>;
    final user = AppUser.fromJson(userData);

    return (tokens: tokens, user: user);
  }

  // ── QUÊN MẬT KHẨU ─────────────────────────────────────────────────────────

  /// Gửi OTP reset mật khẩu qua email.
  /// Backend luôn trả 202 (không lộ email có tồn tại hay không).
  static Future<void> forgotPassword(String email) async {
    final client = ApiClient();
    await client.post('/auth/forgot-password', {
      'email': email.trim().toLowerCase(),
    });
  }

  // ── ĐẶT LẠI MẬT KHẨU ─────────────────────────────────────────────────────

  /// Đặt lại mật khẩu sau khi nhập OTP.
  /// Mật khẩu mới phải đủ mạnh (validate cả ở backend).
  static Future<void> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    final client = ApiClient();
    await client.post('/auth/reset-password', {
      'email': email.trim().toLowerCase(),
      'otp_code': otpCode.trim(),
      'new_password': newPassword,
    });
  }

  // ── REFRESH TOKEN ──────────────────────────────────────────────────────────

  static Future<AuthTokens> refresh(String refreshToken) async {
    final client = ApiClient();
    final data = await client.post('/auth/refresh', {
      'refresh_token': refreshToken,
    }) as Map<String, dynamic>;
    return AuthTokens.fromJson(data);
  }

  // ── LOGOUT ─────────────────────────────────────────────────────────────────

  static Future<void> logout(String refreshToken) async {
    final client = ApiClient();
    try {
      await client.post('/auth/logout', {'refresh_token': refreshToken});
    } catch (_) {
      // Bỏ qua lỗi logout — local session đã xóa là đủ
    }
  }

  // ── GET CURRENT USER ───────────────────────────────────────────────────────

  static Future<AppUser> me(String accessToken) async {
    final client = ApiClient(token: accessToken);
    final data = await client.get('/auth/me') as Map<String, dynamic>;
    return AppUser.fromJson(data);
  }

  // ── UPDATE PROFILE ─────────────────────────────────────────────────────────

  static Future<AppUser> updateProfile(
    String accessToken, {
    String? fullName,
    String? avatarUrl,
  }) async {
    final client = ApiClient(token: accessToken);
    final body = <String, dynamic>{};
    if (fullName != null) body['full_name'] = fullName.trim();
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;

    final data = await client.patch('/auth/me', body) as Map<String, dynamic>;
    return AppUser.fromJson(data);
  }

  // ── ĐỔI MẬT KHẨU (đã đăng nhập) ─────────────────────────────────────────

  static Future<void> changePassword(
    String accessToken, {
    required String oldPassword,
    required String newPassword,
  }) async {
    final client = ApiClient(token: accessToken);
    await client.patch('/auth/me/password', {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers validation phía client (mirror backend rules)
// ─────────────────────────────────────────────────────────────────────────────

class AuthValidators {
  /// Kiểm tra email hợp lệ (cú pháp đơn giản)
  static String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
    final clean = v.trim().toLowerCase();
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(clean)) {
      return 'Email không đúng định dạng';
    }
    return null;
  }

  /// Kiểm tra username: [a-z0-9_-], 3-50 ký tự
  static String? validateUsername(String? v) {
    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập username';
    final clean = v.trim().toLowerCase();
    if (clean.length < 3) return 'Username phải có ít nhất 3 ký tự';
    if (clean.length > 50) return 'Username không được quá 50 ký tự';
    if (!RegExp(r'^[a-z0-9_\-]+$').hasMatch(clean)) {
      return 'Username chỉ dùng chữ thường, số, dấu _ hoặc -';
    }
    if (clean.startsWith('_') || clean.startsWith('-') ||
        clean.endsWith('_') || clean.endsWith('-')) {
      return 'Username không được bắt đầu/kết thúc bằng _ hoặc -';
    }
    return null;
  }

  /// Kiểm tra độ mạnh mật khẩu (mirror backend)
  /// Phải có: HOA + thường + số + ký tự đặc biệt, 8-128 ký tự
  static String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (v.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
    if (v.length > 128) return 'Mật khẩu không được quá 128 ký tự';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Mật khẩu phải có ít nhất 1 chữ HOA (A-Z)';
    if (!RegExp(r'[a-z]').hasMatch(v)) return 'Mật khẩu phải có ít nhất 1 chữ thường (a-z)';
    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Mật khẩu phải có ít nhất 1 chữ số (0-9)';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]')
        .hasMatch(v)) {
      return 'Mật khẩu phải có ít nhất 1 ký tự đặc biệt';
    }
    return null;
  }

  /// Kiểm tra OTP 6 chữ số
  static String? validateOtp(String? v) {
    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập mã OTP';
    if (!RegExp(r'^\d{6}$').hasMatch(v.trim())) {
      return 'Mã OTP phải gồm đúng 6 chữ số';
    }
    return null;
  }

  /// Trả về màu/icon gợi ý độ mạnh mật khẩu (0-4)
  static int passwordStrengthScore(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    return score; // 0=rất yếu, 1=yếu, 2=trung bình, 3=mạnh, 4=rất mạnh
  }
}
