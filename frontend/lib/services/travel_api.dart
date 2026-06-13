import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'sse_client.dart';
import 'token_storage.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final token = data['access_token'] as String?;
      if (token != null) await TokenStorage.saveToken(token);
      return data;
    }
    throw Exception(jsonDecode(res.body)['detail'] ?? 'Đăng nhập thất bại');
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final token = data['access_token'] as String?;
      if (token != null) await TokenStorage.saveToken(token);
      return data;
    }
    throw Exception(jsonDecode(res.body)['detail'] ?? 'Đăng ký thất bại');
  }

  /// Lấy thông tin user hiện tại từ token đã lưu (null nếu chưa đăng nhập / token hết hạn).
  static Future<Map<String, dynamic>?> me() async {
    final headers = await TokenStorage.authHeader();
    if (headers.isEmpty) return null;
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/auth/me'),
      headers: headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    if (res.statusCode == 401) await TokenStorage.clearToken();
    return null;
  }

  static Future<void> logout() => TokenStorage.clearToken();
}

class ChatService {
  /// Gửi tin nhắn (JSON, không streaming). Tự động kèm Bearer token nếu đã
  /// đăng nhập; nếu chưa đăng nhập, backend sẽ xử lý như Guest (user_id = 0).
  static Future<Map<String, dynamic>> sendMessage({
    required String message,
    int userId = 0,
    String userName = 'Khách',
    int? sessionId,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      ...await TokenStorage.authHeader(),
    };
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/chat/json'),
      headers: headers,
      body: jsonEncode({
        'message': message,
        'user_id': userId,
        'user_name': userName,
        'session_id': sessionId,
      }),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    if (res.statusCode == 401) throw Exception('Vui lòng đăng nhập lại');
    throw Exception('Không thể gửi tin nhắn');
  }

  /// Gửi tin nhắn dạng streaming (SSE). Server sẽ gửi event "session" đầu
  /// tiên chứa session_id — client nên lưu lại để gửi cho các tin nhắn sau
  /// (giữ ngữ cảnh cuộc hội thoại).
  static Stream<Map<String, dynamic>> sendMessageStream({
    required String message,
    int userId = 0,
    String userName = 'Khách',
    int? sessionId,
  }) async* {
    final request = http.Request('POST', Uri.parse('${ApiConfig.baseUrl}/chat'));
    request.headers['Content-Type'] = 'application/json';
    request.headers.addAll(await TokenStorage.authHeader());
    request.body = jsonEncode({
      'message': message,
      'user_id': userId,
      'user_name': userName,
      'session_id': sessionId,
    });

    final response = await request.send();
    if (response.statusCode != 200) {
      final errorBody = await response.stream.bytesToString();
      throw Exception('Không thể gửi tin nhắn: ${response.statusCode} ${errorBody}');
    }

    yield* SseClient.parse(response);
  }

  static Map<String, dynamic>? _parseSseData(String rawData) {
    try {
      final decoded = jsonDecode(rawData);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'type': 'response', 'text': rawData};
    } catch (_) {
      return {'type': 'response', 'text': rawData};
    }
  }

  /// Danh sách session chat của user hiện tại (yêu cầu đăng nhập).
  static Future<List<dynamic>> getSessions() async {
    final headers = await TokenStorage.authHeader();
    if (headers.isEmpty) return [];
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/chat/sessions'),
      headers: headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  /// Chi tiết 1 session (gồm toàn bộ message) — yêu cầu đăng nhập + đúng chủ sở hữu.
  static Future<Map<String, dynamic>?> getSessionDetail(int sessionId) async {
    final headers = await TokenStorage.authHeader();
    if (headers.isEmpty) return null;
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/chat/sessions/$sessionId'),
      headers: headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }

  static Future<bool> deleteSession(int sessionId) async {
    final headers = await TokenStorage.authHeader();
    if (headers.isEmpty) return false;
    final res = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/chat/sessions/$sessionId'),
      headers: headers,
    );
    return res.statusCode == 200;
  }
}

class DestinationService {
  static Future<List<dynamic>> getDestinations({String? search, String? tag}) async {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (tag != null && tag.isNotEmpty) params['tag'] = tag;
    final uri = Uri.parse('${ApiConfig.baseUrl}/destinations').replace(queryParameters: params);
    final res = await http.get(uri);
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<Map<String, dynamic>?> getDestination(int id) async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/destinations/$id'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }
}

class ServicesApi {
  static Future<Map<String, dynamic>> search({String q = '', String? type, String? destination}) async {
    final params = <String, String>{'q': q};
    if (type != null) params['type'] = type;
    if (destination != null) params['destination'] = destination;
    final uri = Uri.parse('${ApiConfig.baseUrl}/services/search').replace(queryParameters: params);
    final res = await http.get(uri);
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {'hotels': [], 'tours': [], 'tickets': []};
  }
}

/// Toàn bộ API trong AdminService yêu cầu user đăng nhập với role = "admin".
/// Backend trả 401 (chưa đăng nhập / token sai) hoặc 403 (không phải admin).
class AdminService {
  static Future<Map<String, dynamic>> getStats() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/admin/stats'),
      headers: await TokenStorage.authHeader(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {};
  }

  static Future<List<dynamic>> getUsers() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/admin/users'),
      headers: await TokenStorage.authHeader(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<List<dynamic>> getChatLogs({String? intent}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/admin/chat-logs').replace(
      queryParameters: intent != null ? {'intent': intent} : {},
    );
    final res = await http.get(uri, headers: await TokenStorage.authHeader());
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<List<dynamic>> getKB({String? category}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/admin/kb').replace(
      queryParameters: category != null ? {'category': category} : {},
    );
    final res = await http.get(uri, headers: await TokenStorage.authHeader());
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<bool> createKB(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/admin/kb'),
      headers: {
        'Content-Type': 'application/json',
        ...await TokenStorage.authHeader(),
      },
      body: jsonEncode(data),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  static Future<bool> updateKB(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/admin/kb/$id'),
      headers: {
        'Content-Type': 'application/json',
        ...await TokenStorage.authHeader(),
      },
      body: jsonEncode(data),
    );
    return res.statusCode == 200;
  }

  static Future<bool> deleteKB(int id) async {
    final res = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/admin/kb/$id'),
      headers: await TokenStorage.authHeader(),
    );
    return res.statusCode == 200;
  }

  static Future<bool> toggleUser(int id) async {
    final res = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/admin/users/$id/toggle'),
      headers: await TokenStorage.authHeader(),
    );
    return res.statusCode == 200;
  }
}
