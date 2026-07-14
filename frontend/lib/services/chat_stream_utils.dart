// lib/services/chat_stream_utils.dart
// Tách từ chatbot_screen.dart để dùng chung — AiPlannerScreen cũng cần gửi
// câu thoại qua chat pipeline thật (POST .../messages/stream) thay vì tự
// soạn JSON gọi /trips/ai/plan riêng, nên cần parse cùng 1 format SSE.
import 'dart:convert';

import '../models/chat_message.dart';

/// Parse nội dung 1 "chunk" SSE — content có thể là JSON (answer/sources/
/// itinerary) hoặc text thô.
Map<String, dynamic> parseChatChunkContent(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return {'text': ''};

  if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
    try {
      final decoded = jsonDecode(trimmed) as Map<String, dynamic>;
      final hasKnownKeys = decoded.containsKey('answer') ||
          decoded.containsKey('sources') ||
          decoded.containsKey('itinerary');
      if (!hasKnownKeys) return {'text': raw};

      final text = (decoded['answer'] ??
              decoded['content'] ??
              decoded['text'] ??
              decoded['response'] ??
              '')
          .toString();
      final rawSources = decoded['sources'] as List<dynamic>?;
      final sources = rawSources?.map((e) => SourceRef.fromDynamic(e)).toList();
      final itinerary = decoded['itinerary'] as Map<String, dynamic>?;
      return {
        'text': text,
        if (sources != null && sources.isNotEmpty) 'sources': sources,
        if (itinerary != null) 'itinerary': itinerary,
      };
    } catch (_) {}
  }

  return {'text': raw};
}

/// Kết quả sau khi gửi 1 tin nhắn và đợi chat trả lời XONG (không cần hiển
/// thị từng chữ như màn chat — chỉ cần kết quả cuối).
class ChatStreamResult {
  final String text;
  final Map<String, dynamic>? itinerary;

  ChatStreamResult({required this.text, this.itinerary});
}

/// Đọc hết 1 stream SSE (từ `ChatSessionApiService.sendMessageStream`) và
/// trả về text + itinerary cuối cùng.
Future<ChatStreamResult> collectChatStream(
  Stream<Map<String, dynamic>> events,
) async {
  String fullContent = '';
  Map<String, dynamic>? itinerary;

  await for (final event in events) {
    switch (event['type']) {
      case 'chunk':
        final raw = event['content'] as String? ?? '';
        final parsed = parseChatChunkContent(raw);
        fullContent += parsed['text'] as String? ?? '';
        if (parsed['itinerary'] != null) {
          itinerary = parsed['itinerary'] as Map<String, dynamic>;
        }
        break;
      case 'done':
        if (event['itinerary'] != null) {
          itinerary = Map<String, dynamic>.from(event['itinerary'] as Map);
        }
        break;
      case 'error':
        throw Exception(event['detail']?.toString() ?? 'Lỗi không xác định từ AI');
    }
  }

  return ChatStreamResult(text: fullContent, itinerary: itinerary);
}
