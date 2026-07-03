// lib/admin/shared/data/chatbot_test_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dio_provider.dart';

class ChatbotTestRepository {
  final Dio _dio;
  ChatbotTestRepository(this._dio);

  /// Hỏi chatbot (non-streaming). history = [{role, content}, ...].
  Future<Map<String, dynamic>> ask(
    String content,
    List<Map<String, String>> history,
  ) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/admin/chatbot/test',
      data: {'content': content, 'history': history},
    );
    return resp.data ?? {};
  }
}

final chatbotTestRepositoryProvider =
    Provider<ChatbotTestRepository>((ref) {
  return ChatbotTestRepository(ref.watch(apiDioProvider));
});
