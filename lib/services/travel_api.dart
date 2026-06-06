import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: ApiClient.jsonHeaders(withAuth: false),
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['detail'] ?? 'Đăng nhập thất bại');
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register'),
      headers: ApiClient.jsonHeaders(withAuth: false),
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
      headers: ApiClient.jsonHeaders(),
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
    final res = await http.get(uri, headers: ApiClient.jsonHeaders());
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<Map<String, dynamic>?> getDestination(int id) async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/destinations/$id'), headers: ApiClient.jsonHeaders());
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
    final res = await http.get(uri, headers: ApiClient.jsonHeaders());
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {'hotels': [], 'tours': [], 'tickets': []};
  }
}

class AdminService {
  static Future<Map<String, dynamic>> getStats() async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/admin/stats'), headers: ApiClient.jsonHeaders());
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {};
  }

  static Future<List<dynamic>> getUsers() async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/admin/users'), headers: ApiClient.jsonHeaders());
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<List<dynamic>> getChatLogs({String? intent, String? search}) async {
    final params = <String, String>{};
    if (intent != null) params['intent'] = intent;
    if (search != null && search.isNotEmpty) params['search'] = search;
    final uri = Uri.parse('${ApiConfig.baseUrl}/admin/chat-logs').replace(queryParameters: params);
    final res = await http.get(uri, headers: ApiClient.jsonHeaders());
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<List<dynamic>> getKB({String? category, String? search}) async {
    final params = <String, String>{};
    if (category != null) params['category'] = category;
    if (search != null && search.isNotEmpty) params['search'] = search;
    final uri = Uri.parse('${ApiConfig.baseUrl}/admin/kb').replace(queryParameters: params);
    final res = await http.get(uri, headers: ApiClient.jsonHeaders());
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<bool> createKB(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/admin/kb'),
      headers: ApiClient.jsonHeaders(),
      body: jsonEncode(data),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  static Future<bool> updateKB(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/admin/kb/$id'),
      headers: ApiClient.jsonHeaders(),
      body: jsonEncode(data),
    );
    return res.statusCode == 200;
  }

  static Future<bool> deleteKB(int id) async {
    final res = await http.delete(Uri.parse('${ApiConfig.baseUrl}/admin/kb/$id'), headers: ApiClient.jsonHeaders());
    return res.statusCode == 200 || res.statusCode == 204;
  }

  static Future<bool> toggleUser(int id) async {
    final res = await http.patch(Uri.parse('${ApiConfig.baseUrl}/admin/users/$id/toggle'), headers: ApiClient.jsonHeaders());
    return res.statusCode == 200;
  }
}
