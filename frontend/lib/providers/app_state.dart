// lib/providers/app_state.dart
// ─────────────────────────────────────────────────────────────────────────────
// AppState — quản lý session người dùng (access token + refresh token + user).
//
// Storage: SharedPreferences (nên migrate sang flutter_secure_storage sau)
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';
import '../services/api_service.dart';
import '../services/auth_api_service.dart';

class AppState extends ChangeNotifier {
  AppUser? _user;
  String? _accessToken;
  String? _refreshToken;

  // [P4] Cài đặt người dùng (persist qua SharedPreferences)
  bool _notifications = true;

  AppUser? get user => _user;
  String? get token => _accessToken;      // dùng trong ApiClient
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isLoggedIn => _user != null && _accessToken != null;

  // [P4] getters cài đặt
  bool get notifications => _notifications;

  // [P4] setters cài đặt — lưu ngay + notify
  Future<void> setNotifications(bool v) async {
    _notifications = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', v);
    notifyListeners();
  }

  /// ApiClient đã inject token, dùng cho mọi service call
  ApiClient get apiClient => ApiClient(
    tokenProvider: () => _accessToken,
    tokenRefresher: refreshAccessToken,
  );

  // ── Load session từ storage ────────────────────────────────────────────────

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    // [P4] đọc cài đặt đã lưu
    _notifications = prefs.getBool('notifications') ?? true;

    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
    final userJson = prefs.getString('user');
    if (userJson != null) {
      try {
        _user = AppUser.fromJson(jsonDecode(userJson));
      } catch (_) {
        // JSON cũ không hợp lệ → xóa
        await _clearPrefs(prefs);
      }
    }

    // Nếu có token nhưng chưa có user (ví dụ app restart) → thử load lại
    if (_accessToken != null && _user == null) {
      try {
        _user = await AuthApiService.me(_accessToken!);
        await prefs.setString('user', jsonEncode(_user!.toJson()));
      } catch (_) {
        // Token hết hạn → xóa
        await _clearPrefs(prefs);
      }
    }

    notifyListeners();
  }

  // ── Lưu session sau login ──────────────────────────────────────────────────

  Future<void> setSession({
    required String accessToken,
    required String refreshToken,
    required AppUser user,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _user = user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    await prefs.setString('user', jsonEncode(user.toJson()));

    notifyListeners();
  }

  // ── Cập nhật user info (sau updateProfile) ────────────────────────────────

  Future<void> updateUser(AppUser updatedUser) async {
    _user = updatedUser;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(updatedUser.toJson()));
    notifyListeners();
  }

  // ── Refresh access token ───────────────────────────────────────────────────

  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;
    try {
      final tokens = await AuthApiService.refresh(_refreshToken!);
      _accessToken = tokens.accessToken;
      _refreshToken = tokens.refreshToken;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', tokens.accessToken);
      await prefs.setString('refresh_token', tokens.refreshToken);

      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    // Revoke refresh token trên server (best effort)
    if (_refreshToken != null) {
      await AuthApiService.logout(_refreshToken!);
    }

    _user = null;
    _accessToken = null;
    _refreshToken = null;

    final prefs = await SharedPreferences.getInstance();
    await _clearPrefs(prefs);
    notifyListeners();
  }

  Future<void> _clearPrefs(SharedPreferences prefs) async {
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user');
    // Xóa key cũ (backward compat)
    await prefs.remove('token');
  }
}