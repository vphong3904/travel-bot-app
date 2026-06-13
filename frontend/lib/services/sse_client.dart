import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class SseClient {
  static Stream<Map<String, dynamic>> parse(http.StreamedResponse response) async* {
    final lines = response.stream.transform(utf8.decoder).transform(const LineSplitter());
    final buffer = StringBuffer();

    await for (final rawLine in lines) {
      final line = rawLine.trimRight();
      if (line.isEmpty) {
        if (buffer.isNotEmpty) {
          final payload = buffer.toString();
          buffer.clear();
          final event = _parseSsePayload(payload);
          if (event != null) {
            yield event;
          }
        }
        continue;
      }

      if (line.startsWith('data:')) {
        if (buffer.isNotEmpty) buffer.writeln();
        buffer.write(line.substring(5).trim());
      }
    }

    if (buffer.isNotEmpty) {
      final payload = buffer.toString();
      final event = _parseSsePayload(payload);
      if (event != null) {
        yield event;
      }
    }
  }

  static Map<String, dynamic>? _parseSsePayload(String payload) {
    try {
      final data = jsonDecode(payload);
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {'type': 'response', 'text': payload};
    } catch (_) {
      return {'type': 'response', 'text': payload};
    }
  }
}
