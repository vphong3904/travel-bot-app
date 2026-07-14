// lib/admin/shared/data/chat_management_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_session_item.dart';
import '../providers/dio_provider.dart';

class ChatManagementRepository {
  final Dio _dio;
  ChatManagementRepository(this._dio);

  Future<List<ChatSessionItem>> listSessions({
    String search = '',
    bool? isFlagged,
    String? tag,
    String? userId,
    int page = 1,
    int pageSize = 30,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/admin/chat-sessions',
      queryParameters: {
        if (search.isNotEmpty) 'search': search,
        if (isFlagged != null) 'is_flagged': isFlagged,
        if (tag != null) 'tag': tag,
        if (userId != null) 'user_id': userId,
        'page': page,
        'page_size': pageSize,
      },
    );
    return (res.data!['items'] as List)
        .map((e) => ChatSessionItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<({Map<String, dynamic> session, List<ChatMessageModel> messages})>
      getSessionMessages(String sessionId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/admin/chat-sessions/$sessionId/messages',
    );
    final data = res.data!;
    return (
      session: data['session'] as Map<String, dynamic>,
      messages: (data['messages'] as List)
          .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> updateSession(
    String sessionId, {
    bool? isFlagged,
    List<String>? tags,
  }) async {
    await _dio.patch<void>(
      '/admin/chat-sessions/$sessionId',
      data: {
        if (isFlagged != null) 'is_flagged': isFlagged,
        if (tags != null) 'tags': tags,
      },
    );
  }

  Future<List<Map<String, dynamic>>> listUnansweredQuestions() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/admin/unanswered-questions',
    );
    return (res.data!['items'] as List).cast<Map<String, dynamic>>();
  }

  /// Promote câu hỏi thành KB entry. `draft` (title/category/content) là
  /// nội dung admin đã duyệt từ AI — bỏ trống thì backend copy nguyên câu hỏi.
  /// `answerMessageId` (field answer_message_id) để backend đánh dấu luôn
  /// câu trả lời gốc là ĐÃ XỬ LÝ — nếu không truyền, câu này vẫn nằm trong
  /// danh sách "chưa trả lời" dù đã được promote.
  Future<void> promoteToKb(String questionId,
      {Map<String, dynamic>? draft, String? answerMessageId}) async {
    await _dio.post<void>(
      '/admin/unanswered-questions/$questionId/promote-to-kb',
      data: {
        ...?draft,
        if (answerMessageId != null) 'answer_message_id': answerMessageId,
      },
    );
  }

  /// TP-005: AI (Gemini) soạn draft KB từ câu hỏi chưa trả lời được.
  /// Trả về {question, draft: {title, category, content, confidence}}.
  Future<Map<String, dynamic>> aiSuggestKb(String questionId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/admin/unanswered-questions/$questionId/ai-suggest',
    );
    return res.data!;
  }

  /// Đánh dấu 1 câu trả lời kém là ĐÃ XỬ LÝ (bỏ khỏi danh sách chưa trả lời).
  /// `answerMessageId` = id tin nhắn CÂU TRẢ LỜI của bot (field answer_message_id).
  Future<void> resolveAnswer(String answerMessageId) async {
    await _dio.patch<void>('/admin/feedback/$answerMessageId/resolve');
  }
}

final chatRepositoryProvider = Provider<ChatManagementRepository>((ref) {
  return ChatManagementRepository(ref.watch(apiDioProvider));
});
