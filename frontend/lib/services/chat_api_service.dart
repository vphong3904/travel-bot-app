// lib/services/chat_api_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// ChatSessionApiService — wrap toàn bộ các call tới /chat/sessions/* và
// /chat/messages/* (RAG thật, không phải WebSocket).
//
// Backend không hỗ trợ WebSocket — toàn bộ chat đi qua REST + SSE stream:
//   POST   /chat/sessions                       → tạo session mới
//   GET    /chat/sessions                       → danh sách session
//   GET    /chat/sessions/:id                   → chi tiết session
//   PATCH  /chat/sessions/:id                   → đổi title / pin
//   DEL    /chat/sessions/:id                   → xoá (soft delete)
//   GET    /chat/sessions/:id/messages           → lịch sử hội thoại
//   POST   /chat/sessions/:id/messages           → gửi tin nhắn (chờ đủ câu trả lời)
//   POST   /chat/sessions/:id/messages/stream     → gửi tin nhắn, nhận SSE stream
//   PATCH  /chat/messages/:id/feedback            → 👍 / 👎
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';

import '../models/chat_session_model.dart';
import 'api_service.dart';
import 'sse_client.dart';

class ChatSessionApiService {
  final String? token;

  ChatSessionApiService({this.token});

  ApiClient get _client => ApiClient(token: token);

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
  ///   {"type": "chunk", "content": "..."}
  ///   {"type": "done", "message_id": "...", "sources": [...]}
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
      String detail = 'Không thể gửi tin nhắn (${response.statusCode})';
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
}