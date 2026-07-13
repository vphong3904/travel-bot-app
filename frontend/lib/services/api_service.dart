// lib/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiConfig {
  // Android Emulator → backend chạy trên máy host
  //static const String baseUrl = 'http://10.0.2.2:8000/api';

  // iOS Simulator / Web
   static const String baseUrl = 'http://localhost:8000/api';

  // Thiết bị thật (thay bằng IP LAN của máy backend)
  // static const String baseUrl = 'http://192.168.1.100:8000/api';

  static const Duration timeout = Duration(seconds: 30);

  // SSE/stream timeout dài hơn vì RAG cần thời gian xử lý
  static const Duration streamTimeout = Duration(seconds: 120);

  /// Gốc server (bỏ hậu tố `/api`) — dùng để dựng URL tuyệt đối cho ảnh tĩnh
  /// `/uploads/...` vì StaticFiles được mount ở gốc server, không nằm dưới `/api`.
  static String get mediaOrigin =>
      baseUrl.endsWith('/api') ? baseUrl.substring(0, baseUrl.length - 4) : baseUrl;
}

/// Ghép URL tuyệt đối cho ảnh lưu local (`/uploads/...`). Giữ nguyên nếu đã
/// là URL tuyệt đối (http/https).
String mediaUrl(String path) {
  if (path.startsWith('http')) return path;
  return '${ApiConfig.mediaOrigin}$path';
}

// ─────────────────────────────────────────────────────────────────────────────

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

// ─────────────────────────────────────────────────────────────────────────────

/// Chuyển exception dart thành message tiếng Việt dễ hiểu
String friendlyError(Object e) {
  if (e is ApiException) return e.message;
  if (e is SocketException) {
    return 'Không kết nối được server. Hãy kiểm tra backend đang chạy và địa chỉ IP đúng.';
  }
  if (e is TimeoutException) {
    return 'Server phản hồi quá lâu. Vui lòng thử lại.';
  }
  if (e is FormatException) {
    return 'Dữ liệu server trả về không hợp lệ.';
  }
  final msg = e.toString();
  if (msg.startsWith('Exception: ')) return msg.substring(11);
  return msg;
}

// ─────────────────────────────────────────────────────────────────────────────

/// Callback để lấy token mới nhất từ AppState mỗi khi cần.
/// ✅ FIX: thay vì cache token tại thời điểm init, luôn lấy token live.
typedef TokenProvider = String? Function();

/// Callback để AppState tự refresh token khi gặp 401.
typedef TokenRefresher = Future<bool> Function();

// ─────────────────────────────────────────────────────────────────────────────

class ApiClient {
  /// Token tĩnh — dùng khi không cần auto-refresh (ví dụ auth endpoints)
  final String? token;

  /// ✅ Token provider live — luôn lấy token hiện tại từ AppState
  final TokenProvider? tokenProvider;

  /// ✅ Auto-refresh callback — gọi khi gặp 401 để thử refresh rồi retry
  final TokenRefresher? tokenRefresher;

  const ApiClient({
    this.token,
    this.tokenProvider,
    this.tokenRefresher,
  });

  /// Token hiện tại: ưu tiên tokenProvider (live), fallback sang token tĩnh
  String? get _currentToken => tokenProvider?.call() ?? token;

  Map<String, String> _buildHeaders() {
    final t = _currentToken;
    return {
      'Content-Type': 'application/json',
      if (t != null && t.isNotEmpty) 'Authorization': 'Bearer $t',
    };
  }

  Map<String, String> get authHeaders => _buildHeaders();

  Uri _uri(String path, [Map<String, String>? queryParams]) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    return queryParams != null && queryParams.isNotEmpty
        ? uri.replace(queryParameters: queryParams)
        : uri;
  }

  /// ✅ Parse response với auto-retry sau khi refresh token (nếu 401)
  Future<dynamic> _parseWithRetry(
    Future<http.Response> Function(Map<String, String> headers) call,
  ) async {
    final res = await call(_buildHeaders());

    // Nếu 401 và có refresher → thử refresh rồi retry 1 lần
    if (res.statusCode == 401 && tokenRefresher != null) {
      final refreshed = await tokenRefresher!();
      if (refreshed) {
        // Token mới đã được lưu vào AppState → tokenProvider sẽ trả về token mới
        final retryRes = await call(_buildHeaders());
        return _parse(retryRes);
      }

      // Nếu refresh thất bại logout luôn → throw 401 để AppState logout
      throw const ApiException(
        401,
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      );
    }

    return _parse(res);
  }

  dynamic _parse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty || res.statusCode == 204) return null;
      return jsonDecode(utf8.decode(res.bodyBytes));
    }

    String detail = _statusMessage(res.statusCode);
    try {
      final body = jsonDecode(utf8.decode(res.bodyBytes));
      if (body is Map && body['detail'] != null) {
        detail = body['detail'].toString();
      }
    } catch (_) {}

    throw ApiException(res.statusCode, detail);
  }

  String _statusMessage(int code) {
    switch (code) {
      case 400: return 'Yêu cầu không hợp lệ.';
      case 401: return 'Phiên đăng nhập hết hạn, vui lòng đăng nhập lại.';
      case 403: return 'Bạn không có quyền thực hiện thao tác này.';
      case 404: return 'Không tìm thấy dữ liệu yêu cầu.';
      case 422: return 'Dữ liệu gửi lên không đúng định dạng.';
      case 429: return 'Bạn đã dùng hết lượt hỏi miễn phí hôm nay. Nâng cấp để tiếp tục!';
      case 500: return 'Lỗi server nội bộ. Vui lòng thử lại sau.';
      case 503: return 'Server đang bảo trì. Vui lòng thử lại sau.';
      default:  return 'Lỗi không xác định (HTTP $code).';
    }
  }

  Future<dynamic> get(String path, [Map<String, String>? queryParams]) async {
    try {
      return await _parseWithRetry(
        (headers) => http
            .get(_uri(path, queryParams), headers: headers)
            .timeout(ApiConfig.timeout),
      );
    } on SocketException {
      throw const ApiException(0, 'Không kết nối được server. Kiểm tra backend và mạng.');
    } on TimeoutException {
      throw const ApiException(0, 'Yêu cầu hết thời gian chờ. Vui lòng thử lại.');
    }
  }

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    try {
      return await _parseWithRetry(
        (headers) => http
            .post(_uri(path), headers: headers, body: body != null ? jsonEncode(body) : null)
            .timeout(ApiConfig.timeout),
      );
    } on SocketException {
      throw const ApiException(0, 'Không kết nối được server. Kiểm tra backend và mạng.');
    } on TimeoutException {
      throw const ApiException(0, 'Yêu cầu hết thời gian chờ. Vui lòng thử lại.');
    }
  }

  Future<dynamic> patch(String path, [Map<String, dynamic>? body]) async {
    try {
      return await _parseWithRetry(
        (headers) => http
            .patch(_uri(path), headers: headers, body: body != null ? jsonEncode(body) : null)
            .timeout(ApiConfig.timeout),
      );
    } on SocketException {
      throw const ApiException(0, 'Không kết nối được server. Kiểm tra backend và mạng.');
    } on TimeoutException {
      throw const ApiException(0, 'Yêu cầu hết thời gian chờ. Vui lòng thử lại.');
    }
  }

  Future<dynamic> put(String path, [Map<String, dynamic>? body]) async {
    try {
      return await _parseWithRetry(
        (headers) => http
            .put(_uri(path), headers: headers, body: body != null ? jsonEncode(body) : null)
            .timeout(ApiConfig.timeout),
      );
    } on SocketException {
      throw const ApiException(0, 'Không kết nối được server. Kiểm tra backend và mạng.');
    } on TimeoutException {
      throw const ApiException(0, 'Yêu cầu hết thời gian chờ. Vui lòng thử lại.');
    }
  }

  /// Upload file dạng multipart/form-data (vd: avatar). Truyền `bytes` khi
  /// chạy trên web (không có File path), hoặc `filePath` trên mobile/desktop.
  Future<dynamic> postMultipart(
    String path, {
    required String fieldName,
    String? filePath,
    List<int>? bytes,
    String? filename,
  }) async {
    try {
      final request = http.MultipartRequest('POST', _uri(path));
      final t = _currentToken;
      if (t != null && t.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $t';
      }
      if (filePath != null) {
        request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
      } else if (bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          fieldName, bytes, filename: filename ?? 'upload',
        ));
      } else {
        throw ArgumentError('Cần truyền filePath hoặc bytes');
      }

      final streamed = await request.send().timeout(ApiConfig.timeout);
      final res = await http.Response.fromStream(streamed);
      return _parse(res);
    } on SocketException {
      throw const ApiException(0, 'Không kết nối được server. Kiểm tra backend và mạng.');
    } on TimeoutException {
      throw const ApiException(0, 'Yêu cầu hết thời gian chờ. Vui lòng thử lại.');
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      return await _parseWithRetry(
        (headers) => http
            .delete(_uri(path), headers: headers)
            .timeout(ApiConfig.timeout),
      );
    } on SocketException {
      throw const ApiException(0, 'Không kết nối được server. Kiểm tra backend và mạng.');
    } on TimeoutException {
      throw const ApiException(0, 'Yêu cầu hết thời gian chờ. Vui lòng thử lại.');
    }
  }

  /// Dùng cho SSE stream — KHÔNG timeout ở đây, timeout được handle ở stream level.
  /// ✅ FIX: nếu 401 → thử refresh token rồi retry stream request
  Future<http.StreamedResponse> postStream(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _sendStream(path, body, _buildHeaders());

      // Nếu 401 → refresh và retry
      if (response.statusCode == 401 && tokenRefresher != null) {
        final refreshed = await tokenRefresher!();
        if (refreshed) {
          return await _sendStream(path, body, _buildHeaders());
        }
      }

      return response;
    } on SocketException {
      throw const ApiException(0, 'Không kết nối được server. Kiểm tra backend đang chạy.');
    }
  }

  Future<http.StreamedResponse> _sendStream(
    String path,
    Map<String, dynamic> body,
    Map<String, String> headers,
  ) async {
    final request = http.Request('POST', _uri(path));
    request.headers.addAll(headers);
    request.body = jsonEncode(body);
    final client = http.Client();
    return await client.send(request).timeout(
      ApiConfig.streamTimeout,
      onTimeout: () {
        client.close();
        throw TimeoutException('SSE stream timeout', ApiConfig.streamTimeout);
      },
    );
  }
}
