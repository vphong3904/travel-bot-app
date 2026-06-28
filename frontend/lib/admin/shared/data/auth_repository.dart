import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/login_response.dart';
import '../providers/dio_provider.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<LoginResponse> login(String email, String password) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return LoginResponse.fromJson(res.data!);
  }

  Future<void> logout() async {
    try {
      await _dio.post<void>('/auth/logout');
    } catch (_) {
      // Logout local dù server có lỗi
    }
  }

  /// Gửi email reset password. Server luôn trả 200 dù email không tồn tại
  /// (tránh email enumeration attack).
  Future<void> forgotPassword(String email) async {
    await _dio.post<void>(
      '/auth/forgot-password',
      data: {'email': email},
    );
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await _dio.post<void>(
      '/auth/reset-password',
      data: {'token': token, 'new_password': newPassword},
    );
  }

  Future<String> refreshAccessToken() async {
    // refresh_token được gửi tự động qua httpOnly cookie
    final res = await _dio.post<Map<String, dynamic>>('/auth/refresh');
    return res.data!['access_token'] as String;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(authDioProvider));
});
