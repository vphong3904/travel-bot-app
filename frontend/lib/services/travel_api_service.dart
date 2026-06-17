import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'sse_client.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['detail'] ?? 'Đăng nhập thất bại');
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['detail'] ?? 'Đăng ký thất bại');
  }
}

class ChatService {
  static Future<Map<String, dynamic>> sendMessage({
    required String message,
    String userId = '',
    String userName = 'Khách',
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message, 'user_id': userId, 'user_name': userName}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Không thể gửi tin nhắn');
  }

  static Stream<Map<String, dynamic>> sendMessageStream({
    required String message,
    String userId = '',
    String userName = 'Khách',
  }) async* {
    final request = http.Request('POST', Uri.parse('${ApiConfig.baseUrl}/chat'));
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({'message': message, 'user_id': userId, 'user_name': userName});

    final response = await request.send();
    if (response.statusCode != 200) {
      final errorBody = await response.stream.bytesToString();
      throw Exception('Không thể gửi tin nhắn: ${response.statusCode} ${errorBody}');
    }

    yield* SseClient.parse(response);
  }

  static Future<List<dynamic>> getUserHistory(String userId) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/chat/history/$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return [];
  }

}

class DestinationService {
  static Future<List<dynamic>> getDestinations({String? search, String? category}) async {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (category != null && category.isNotEmpty) params['category'] = category;
    final uri = Uri.parse('${ApiConfig.baseUrl}/travel/destinations').replace(queryParameters: params);
    final res = await http.get(uri);
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<Map<String, dynamic>?> getDestination(String id) async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/travel/destinations/$id'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }
}

class ServicesApi {
  static Future<Map<String, dynamic>> search({String q = '', String? type, String? destination}) async {
    final params = <String, String>{'q': q};
    if (type != null && type.isNotEmpty) params['type'] = type;
    if (destination != null && destination.isNotEmpty) params['destination'] = destination;
    final uri = Uri.parse('${ApiConfig.baseUrl}/search').replace(queryParameters: params);
    final res = await http.get(uri);
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {'destinations': [], 'hotels': [], 'tours': []};
  }
}

class AdminService {
  static Future<Map<String, dynamic>> getStats() async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/admin/stats'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {};
  }

  static Future<List<dynamic>> getUsers() async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/admin/users'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<List<dynamic>> getChatLogs({String? intent}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/admin/chat-logs').replace(
      queryParameters: intent != null ? {'intent': intent} : {},
    );
    final res = await http.get(uri);
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<List<dynamic>> getKB({String? category}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/admin/kb').replace(
      queryParameters: category != null ? {'category': category} : {},
    );
    final res = await http.get(uri);
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<bool> createKB(Map<String, dynamic> data) async {
  final res = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/admin/kb'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );
  return res.statusCode == 200 || res.statusCode == 201;
}

static Future<bool> updateKB(int id, Map<String, dynamic> data) async {
  final res = await http.put(
    Uri.parse('${ApiConfig.baseUrl}/admin/kb/$id'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );
  return res.statusCode == 200;
}

static Future<bool> deleteKB(int id) async {
  final res = await http.delete(Uri.parse('${ApiConfig.baseUrl}/admin/kb/$id'));
  return res.statusCode == 200;
}

static Future<bool> toggleUser(int id) async {
  final res = await http.patch(Uri.parse('${ApiConfig.baseUrl}/admin/users/$id/toggle'));
  return res.statusCode == 200;
}
}
