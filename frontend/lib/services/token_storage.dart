import 'package:shared_preferences/shared_preferences.dart';

/// Lưu trữ JWT access token trên thiết bị (SharedPreferences).
class TokenStorage {
  static const _key = 'access_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Header sẵn sàng dùng cho mọi request cần xác thực.
  /// Trả về {} nếu chưa đăng nhập (Guest) -> backend coi như request ẩn danh.
  static Future<Map<String, String>> authHeader() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return {};
    return {'Authorization': 'Bearer $token'};
  }
}
