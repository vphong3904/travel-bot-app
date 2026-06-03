import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

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
    int userId = 0,
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

  static Future<void> createKB(Map<String, dynamic> data) async {
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/admin/kb'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  static Future<void> updateKB(int id, Map<String, dynamic> data) async {
    await http.put(
      Uri.parse('${ApiConfig.baseUrl}/admin/kb/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  static Future<void> deleteKB(int id) async {
    await http.delete(Uri.parse('${ApiConfig.baseUrl}/admin/kb/$id'));
  }

  static Future<void> toggleUser(int id) async {
    await http.patch(Uri.parse('${ApiConfig.baseUrl}/admin/users/$id/toggle'));
  }
}
