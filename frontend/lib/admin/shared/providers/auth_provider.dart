// lib/features/auth/providers/auth_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../models/auth_user.dart';

class AuthState {
  final AuthUser? user;
  final String? accessToken;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.accessToken,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null && accessToken != null;

  AuthState copyWith({
    AuthUser? user,
    String? accessToken,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) =>
      AuthState(
        user: clearUser ? null : user ?? this.user,
        accessToken: clearUser ? null : accessToken ?? this.accessToken,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _repo.login(email, password);
      // Token lưu trong memory state — KHÔNG localStorage (tuân theo task spec)
      state = AuthState(
        user: res.user,
        accessToken: res.accessToken,
        isLoading: false,
      );
    } on DioException catch (e) {
      final detail = (e.response?.data as Map<String, dynamic>?)?['detail'];
      state = state.copyWith(
        isLoading: false,
        error: detail?.toString() ?? 'Đăng nhập thất bại. Vui lòng thử lại.',
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Không thể kết nối. Kiểm tra mạng và thử lại.',
      );
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Dùng khi refresh token thành công ở background
  void updateAccessToken(String token) {
    state = state.copyWith(accessToken: token);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
