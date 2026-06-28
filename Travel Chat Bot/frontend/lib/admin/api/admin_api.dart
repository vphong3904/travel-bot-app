import 'dart:convert';
import 'package:http/http.dart' as http;

const String kApiBase = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);

class AdminApiClient {
  final String? Function() getToken;

  const AdminApiClient({required this.getToken});

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (getToken() != null) 'Authorization': 'Bearer ${getToken()}',
  };

  Future<dynamic> get(String path) async {
    final res = await http.get(Uri.parse('$kApiBase$path'), headers: _headers);
    _checkStatus(res);
    return jsonDecode(res.body);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$kApiBase$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    _checkStatus(res);
    return jsonDecode(res.body);
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final res = await http.patch(
      Uri.parse('$kApiBase$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    _checkStatus(res);
    return jsonDecode(res.body);
  }

  Future<void> delete(String path) async {
    final res = await http.delete(Uri.parse('$kApiBase$path'), headers: _headers);
    _checkStatus(res);
  }

  void _checkStatus(http.Response res) {
    if (res.statusCode >= 400) {
      throw Exception('API error ${res.statusCode}: ${res.body}');
    }
  }
}
