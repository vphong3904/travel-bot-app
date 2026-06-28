// lib/services/sse_client.dart
// ─────────────────────────────────────────────────────────────────────────────
// SseClient — parse Server-Sent Events từ StreamedResponse.
//
// Backend stream format (chuẩn):
//   event: message
//   data: {"type": "chunk", "content": "..."}
//
//   event: message
//   data: {"type": "done", "message_id": "uuid", "sources": [...]}
//
// LƯU Ý: một số proxy/dev-server có thể làm mất dòng trống ("\n\n") ngăn
// cách giữa các event, hoặc network chunk có thể cắt giữa 1 dòng JSON.
// Vì vậy parser KHÔNG dựa vào dòng trống hay LineSplitter — nó quét trực
// tiếp trên buffer ký tự, tìm "data:" rồi tự đếm dấu { } cân bằng (có để ý
// tới string/escape) để cắt ra đúng 1 JSON object, bất kể object đó có dính
// liền với event kế tiếp hay bị chia làm nhiều chunk mạng.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:http/http.dart' as http;

class SseClient {
  /// Parse SSE stream từ http.StreamedResponse.
  ///
  /// Yield từng event dưới dạng Map<String, dynamic>.
  static Stream<Map<String, dynamic>> parse(
      http.StreamedResponse response) async* {
    final decoder = response.stream.transform(utf8.decoder);

    String buffer = '';

    await for (final part in decoder) {
      buffer += part;

      while (true) {
        final dataIdx = buffer.indexOf('data:');
        if (dataIdx == -1) {
          // Không có "data:" nào trong buffer hiện tại → giữ lại chờ thêm
          // (nhưng nếu buffer quá dài và toàn rác, cắt bớt để tránh phình vô hạn)
          if (buffer.length > 1 << 16) buffer = '';
          break;
        }

        final braceStart = buffer.indexOf('{', dataIdx);
        if (braceStart == -1) {
          // Có "data:" nhưng chưa thấy "{" → có thể là "data: [DONE]" hoặc
          // chưa nhận đủ byte. Nếu không phải [DONE], chờ thêm dữ liệu.
          final after = buffer.substring(dataIdx + 5).trimLeft();
          if (after.startsWith('[DONE]')) {
            buffer = buffer.substring(dataIdx + 5 + after.indexOf('[DONE]') + 6);
            continue;
          }
          break;
        }

        final closeIdx = _findMatchingBrace(buffer, braceStart);
        if (closeIdx == null) {
          // JSON chưa đầy đủ (bị cắt giữa chunk mạng) → chờ thêm dữ liệu
          break;
        }

        final jsonStr = buffer.substring(braceStart, closeIdx + 1);
        buffer = buffer.substring(closeIdx + 1);

        try {
          final decoded = jsonDecode(jsonStr);
          if (decoded is Map<String, dynamic>) {
            yield decoded;
          }
        } catch (_) {
          // JSON lỗi thật (không phải do cắt thiếu) → bỏ qua, không dump raw text
        }
      }
    }
  }

  /// Tìm vị trí dấu '}' khớp với dấu '{' tại [start], có tính tới
  /// chuỗi string (bỏ qua { } nằm trong "...") và ký tự escape \" .
  /// Trả về null nếu chưa đủ dữ liệu để tìm thấy dấu đóng tương ứng.
  static int? _findMatchingBrace(String s, int start) {
    int depth = 0;
    bool inString = false;
    bool escape = false;

    for (int i = start; i < s.length; i++) {
      final ch = s[i];

      if (inString) {
        if (escape) {
          escape = false;
        } else if (ch == '\\') {
          escape = true;
        } else if (ch == '"') {
          inString = false;
        }
        continue;
      }

      if (ch == '"') {
        inString = true;
      } else if (ch == '{') {
        depth++;
      } else if (ch == '}') {
        depth--;
        if (depth == 0) return i;
      }
    }
    return null; // chưa đủ dữ liệu
  }
}