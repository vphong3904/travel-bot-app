// lib/services/sse_client.dart
// ─────────────────────────────────────────────────────────────────────────────
// SseClient — parse Server-Sent Events từ StreamedResponse.
//
// Backend stream format:
//   data: {"type": "chunk", "content": "..."}
//   data: {"type": "done", "message_id": "uuid", "sources": [...]}
//   data: {"type": "error", "detail": "..."}
//
// Mỗi SSE event là một Map<String, dynamic> được yield ra.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SseClient {
  /// Parse SSE stream từ http.StreamedResponse.
  ///
  /// Yield từng event dưới dạng Map<String, dynamic>.
  /// Bỏ qua comment lines (bắt đầu bằng `:`) và empty lines.
  static Stream<Map<String, dynamic>> parse(
      http.StreamedResponse response) async* {
    final lines = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    final buffer = StringBuffer();

    await for (final line in lines) {
      if (line.startsWith(':')) {
        // Comment / keep-alive — bỏ qua
        continue;
      }

      if (line.isEmpty) {
        // Blank line = end of event → process buffer
        final raw = buffer.toString().trim();
        buffer.clear();

        if (raw.isEmpty) continue;

        // Xử lý "data: ..." prefix
        String jsonStr = raw;
        if (raw.startsWith('data:')) {
          jsonStr = raw.substring(5).trim();
        }

        if (jsonStr.isEmpty || jsonStr == '[DONE]') continue;

        try {
          final decoded = jsonDecode(jsonStr);
          if (decoded is Map<String, dynamic>) {
            yield decoded;
          }
        } catch (_) {
          // Payload không phải JSON hợp lệ — wrap lại
          yield {'type': 'chunk', 'content': jsonStr};
        }
      } else {
        // Tiếp tục append vào buffer
        if (buffer.isNotEmpty) buffer.write('\n');
        buffer.write(line);
      }
    }

    // Xử lý nốt nếu stream kết thúc không có blank line cuối
    final remaining = buffer.toString().trim();
    if (remaining.isNotEmpty) {
      String jsonStr = remaining;
      if (remaining.startsWith('data:')) {
        jsonStr = remaining.substring(5).trim();
      }
      if (jsonStr.isNotEmpty && jsonStr != '[DONE]') {
        try {
          final decoded = jsonDecode(jsonStr);
          if (decoded is Map<String, dynamic>) yield decoded;
        } catch (_) {}
      }
    }
  }
}