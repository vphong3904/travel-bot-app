// lib/services/api_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// ApiClient — HTTP client trung tâm, inject Bearer token vào mọi request.
//
// Cách dùng:
//   final client = ApiClient(token: appState.token);
//   final data = await client.get('/auth/me');
//   final body = await client.post('/chat/sessions', {'title': 'Hỏi Đà Lạt'});
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiConfig {
  // ── Đổi URL theo môi trường ─────────────────────────────────────────────
  // Android Emulator → backend chạy trên máy host
  // static const String baseUrl = 'http://10.0.2.2:8000/api';

  // iOS Simulator / Web
  static const String baseUrl = 'http://localhost:8000/api';

  // Thiết bị thật (thay bằng IP LAN của máy backend)
  // static const String baseUrl = 'http://192.168.1.100:8000/api';

  static const Duration timeout = Duration(seconds: 30);
}

// ─────────────────────────────────────────────────────────────────────────────

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// ─────────────────────────────────────────────────────────────────────────────

class ApiClient {
  final String? token;

  const ApiClient({this.token});

  // ── Headers ────────────────────────────────────────────────────────────────

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null && token!.isNotEmpty)
          'Authorization': 'Bearer $token',
      };

  /// Dùng khi cần truyền headers ra ngoài (e.g. cho SSE request)
  Map<String, String> get authHeaders => _headers;

  // ── HTTP Methods ───────────────────────────────────────────────────────────

  Uri _uri(String path, [Map<String, String>? queryParams]) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    return queryParams != null && queryParams.isNotEmpty
        ? uri.replace(queryParameters: queryParams)
        : uri;
  }

  dynamic _parse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty || res.statusCode == 204) return null;
      return jsonDecode(res.body);
    }
    String detail = 'Lỗi không xác định';
    try {
      final body = jsonDecode(res.body);
      detail = body['detail']?.toString() ?? detail;
    } catch (_) {}
    throw ApiException(res.statusCode, detail);
  }

  Future<dynamic> get(String path, [Map<String, String>? queryParams]) async {
    final res = await http
        .get(_uri(path, queryParams), headers: _headers)
        .timeout(ApiConfig.timeout);
    return _parse(res);
  }

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    print(_uri(path)); // thêm dòng này
    final res = await http
        .post(_uri(path), headers: _headers, body: body != null ? jsonEncode(body) : null)
        .timeout(ApiConfig.timeout);
    return _parse(res);
  }

  Future<dynamic> patch(String path, [Map<String, dynamic>? body]) async {
    final res = await http
        .patch(_uri(path), headers: _headers, body: body != null ? jsonEncode(body) : null)
        .timeout(ApiConfig.timeout);
    return _parse(res);
  }

  Future<dynamic> put(String path, [Map<String, dynamic>? body]) async {
    final res = await http
        .put(_uri(path), headers: _headers, body: body != null ? jsonEncode(body) : null)
        .timeout(ApiConfig.timeout);
    return _parse(res);
  }

  Future<dynamic> delete(String path) async {
    final res = await http
        .delete(_uri(path), headers: _headers)
        .timeout(ApiConfig.timeout);
    return _parse(res);
  }

  /// Dùng cho SSE stream — trả về http.StreamedResponse để parse SSE
  Future<http.StreamedResponse> postStream(
      String path, Map<String, dynamic> body) async {
    final request = http.Request('POST', _uri(path));
    request.headers.addAll(_headers);
    request.body = jsonEncode(body);
    return request.send();
  }
}