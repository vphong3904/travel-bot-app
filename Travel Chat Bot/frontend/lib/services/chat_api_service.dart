// lib/services/chat_api_service.dart
import 'dart:convert';

import '../models/chat_session_model.dart';
import 'api_service.dart';
import 'sse_client.dart';

/// ✅ FIX: Nhận TokenProvider + TokenRefresher thay vì token tĩnh.
/// Mọi request sẽ luôn dùng token hiện tại từ AppState,
/// và tự động retry sau khi refresh nếu gặp 401.
class ChatSessionApiService {
  final TokenProvider tokenProvider;
  final TokenRefresher? tokenRefresher;

  const ChatSessionApiService({
    required this.tokenProvider,
    this.tokenRefresher,
  });

  ApiClient get _client => ApiClient(
        tokenProvider: tokenProvider,
        tokenRefresher: tokenRefresher,
      );

  // ── Sessions ──────────────────────────────────────────────────────────────

  Future<List<ChatSessionModel>> listSessions({
    bool pinnedOnly = false,
    int skip = 0,
    int limit = 30,
  }) async {
    final params = <String, String>{
      'skip': '$skip',
      'limit': '$limit',
      if (pinnedOnly) 'pinned_only': 'true',
    };
    final data = await _client.get('/chat/sessions', params) as List<dynamic>;
    return data
        .map((e) => ChatSessionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChatSessionModel> createSession({String? title, String? modelName}) async {
    final body = <String, dynamic>{
      if (title != null && title.isNotEmpty) 'title': title,
      if (modelName != null && modelName.isNotEmpty) 'model_name': modelName,
    };
    final data = await _client.post('/chat/sessions', body) as Map<String, dynamic>;
    return ChatSessionModel.fromJson(data);
  }

  Future<ChatSessionModel> getSession(String sessionId) async {
    final data = await _client.get('/chat/sessions/$sessionId') as Map<String, dynamic>;
    return ChatSessionModel.fromJson(data);
  }

  Future<ChatSessionModel> updateSession(
    String sessionId, {
    String? title,
    bool? pinned,
  }) async {
    final body = <String, dynamic>{
      if (title != null) 'title': title,
      if (pinned != null) 'pinned': pinned,
    };
    final data =
        await _client.patch('/chat/sessions/$sessionId', body) as Map<String, dynamic>;
    return ChatSessionModel.fromJson(data);
  }

  Future<void> deleteSession(String sessionId) async {
    await _client.delete('/chat/sessions/$sessionId');
  }

  // ── Messages ──────────────────────────────────────────────────────────────

  Future<List<ChatMessageModel>> listMessages(
    String sessionId, {
    int skip = 0,
    int limit = 50,
  }) async {
    final params = <String, String>{'skip': '$skip', 'limit': '$limit'};
    final data = await _client
        .get('/chat/sessions/$sessionId/messages', params) as List<dynamic>;
    return data
        .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Gửi tin nhắn, chờ AI trả lời đầy đủ (không stream).
  Future<ChatMessageModel> sendMessage(String sessionId, String content) async {
    final data = await _client.post(
      '/chat/sessions/$sessionId/messages',
      {'content': content},
    ) as Map<String, dynamic>;
    return ChatMessageModel.fromJson(data);
  }

  /// Gửi tin nhắn, nhận phản hồi dạng SSE stream.
  ///
  /// Yield các event dạng:
  ///   {"type": "start"}
  ///   {"type": "chunk", "content": "..."}
  ///   {"type": "done", "message_id": "uuid", "sources": [...], "tokens_per_second": 97.3}
  ///   {"type": "error", "detail": "..."}
  Stream<Map<String, dynamic>> sendMessageStream(
    String sessionId,
    String content,
  ) async* {
    final response = await _client.postStream(
      '/chat/sessions/$sessionId/messages/stream',
      {'content': content},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = await response.stream.bytesToString();
      String detail = _statusMessage(response.statusCode);
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map && decoded['detail'] != null) {
          detail = decoded['detail'].toString();
        }
      } catch (_) {}
      throw ApiException(response.statusCode, detail);
    }

    yield* SseClient.parse(response);
  }

  Future<ChatMessageModel> updateFeedback(String messageId, int feedback) async {
    final data = await _client.patch(
      '/chat/messages/$messageId/feedback',
      {'feedback': feedback},
    ) as Map<String, dynamic>;
    return ChatMessageModel.fromJson(data);
  }

  String _statusMessage(int code) {
    switch (code) {
      case 401: return 'Phiên đăng nhập hết hạn, vui lòng đăng nhập lại.';
      case 403: return 'Bạn không có quyền thực hiện thao tác này.';
      case 404: return 'Không tìm thấy session chat. Vui lòng tạo mới.';
      case 429: return 'Bạn đã dùng hết lượt hỏi miễn phí hôm nay. Nâng cấp để tiếp tục!';
      case 500: return 'Lỗi server nội bộ. Vui lòng thử lại sau.';
      default:  return 'Lỗi gửi tin nhắn (HTTP $code).';
    }
  }
}
