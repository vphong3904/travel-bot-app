// Test cho lib/models/chat_message.dart — ChatMessage.fromJson() và
// SourceRef.fromDynamic().
//
// Đây là phần CHECKLIST_TONG_THE.md mục 4 nói "Test frontend (widget test
// Flutter) — ⬜ Chưa kiểm tra — cần xác minh có test/ folder ở frontend
// không" — trước file này, project KHÔNG có thư mục test/ nào ở frontend.
//
// Chọn ChatMessage/SourceRef làm test đầu tiên (thay vì widget test toàn
// màn hình chat) vì đây là pure Dart parsing logic — không cần dựng
// Provider/http/MaterialApp giả, nên an toàn để chạy được ngay mà không
// phụ thuộc cấu hình runtime phức tạp của riêng app.
//
// Bản thân comment trong chat_message.dart đã ghi lại 1 bug thật đã xảy ra
// (sources bị stringify thô lên UI) — test này khoá lại đúng hành vi sửa
// đó để không bị regress nếu code đổi sau này.
//
// Chạy: cd frontend && flutter test test/chat_message_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/chat_message.dart';

void main() {
  group('SourceRef.fromDynamic', () {
    test('parses a well-formed map from backend', () {
      final ref = SourceRef.fromDynamic({
        'id': 'qdrant_12',
        'score': 0.82,
        'text': 'Đà Lạt có khí hậu mát mẻ quanh năm.',
        'title': 'Đà Lạt - Khí hậu',
        'category': 'weather',
        'source': 'qdrant',
      });

      expect(ref.id, 'qdrant_12');
      expect(ref.score, 0.82);
      expect(ref.title, 'Đà Lạt - Khí hậu');
      expect(ref.source, 'qdrant');
    });

    test('missing optional fields fall back to safe defaults, not crash', () {
      final ref = SourceRef.fromDynamic({'id': 'pg_0'});
      expect(ref.id, 'pg_0');
      expect(ref.score, 0);
      expect(ref.text, '');
      expect(ref.title, '');
    });

    test('score as int (not double) from JSON is still parsed correctly', () {
      // JSON numbers không phân biệt int/double rõ ràng khi decode trong
      // Dart — score nguyên (vd 1, không phải 1.0) phải vẫn convert được
      // sang double, không được throw lỗi cast.
      final ref = SourceRef.fromDynamic({'id': 'x', 'score': 1});
      expect(ref.score, 1.0);
    });

    test(
      'plain string fallback (backend gửi sai format) does not crash, '
      'goes into title not raw object dump',
      () {
        final ref = SourceRef.fromDynamic('Đà Lạt');
        expect(ref.id, '');
        expect(ref.title, 'Đà Lạt');
      },
    );

    test(
      'displayLabel never exposes raw Map.toString() debug output '
      '— regression test cho bug đã ghi trong comment gốc',
      () {
        final ref = SourceRef.fromDynamic({
          'id': 'pg_0',
          'score': 0.12,
          'text':
              'Một đoạn văn bản rất dài mô tả chi tiết về điểm đến này, '
              'vượt quá bốn mươi ký tự để test việc cắt chuỗi.',
          'title': '',
        });
        // Không có title -> rơi về text, phải bị cắt và có dấu "…", và
        // chắc chắn KHÔNG chứa cú pháp kiểu "{id: ..., score: ...}" của
        // Map.toString() thô.
        expect(ref.displayLabel, isNot(contains('{id:')));
        expect(ref.displayLabel, isNot(contains('score:')));
        expect(ref.displayLabel.endsWith('…'), isTrue);
      },
    );

    test('displayLabel prefers title over text when both present', () {
      final ref = SourceRef.fromDynamic({
        'title': 'Tiêu đề ngắn',
        'text': 'Một đoạn text dài khác không nên được dùng ở đây',
      });
      expect(ref.displayLabel, 'Tiêu đề ngắn');
    });
  });

  group('ChatMessage.fromJson', () {
    test('parses a typical assistant message with sources', () {
      final msg = ChatMessage.fromJson({
        'sender': 'ai',
        'text': 'Đà Lạt mát mẻ quanh năm.',
        'intent': 'ask_weather',
        'confidence': 0.87,
        'sources': [
          {'id': 's1', 'title': 'Nguồn 1', 'score': 0.7},
          {'id': 's2', 'title': 'Nguồn 2', 'score': 0.5},
        ],
      });

      expect(msg.sender, 'ai');
      expect(msg.text, 'Đà Lạt mát mẻ quanh năm.');
      expect(msg.intent, 'ask_weather');
      expect(msg.confidence, 0.87);
      expect(msg.sources.length, 2);
      expect(msg.sources[0].title, 'Nguồn 1');
    });

    test('accepts "content" key as fallback for "text"', () {
      // Backend route /chat/sessions/{id}/messages trả về field "content"
      // (xem ChatMessageOut ở backend/app/db/schemas/chat.py), không phải
      // "text" — fromJson phải chấp nhận cả 2 để không bị mất nội dung khi
      // map thẳng response backend vào model frontend.
      final msg = ChatMessage.fromJson({
        'sender': 'ai',
        'content': 'Nội dung từ field content',
      });
      expect(msg.text, 'Nội dung từ field content');
    });

    test('missing sender defaults to "ai", never crashes', () {
      final msg = ChatMessage.fromJson({'text': 'Xin chào'});
      expect(msg.sender, 'ai');
    });

    test('missing sources key results in empty list, not null/crash', () {
      final msg = ChatMessage.fromJson({'sender': 'ai', 'text': 'abc'});
      expect(msg.sources, isEmpty);
    });

    test('empty json object does not throw', () {
      expect(() => ChatMessage.fromJson({}), returnsNormally);
      final msg = ChatMessage.fromJson({});
      expect(msg.text, '');
      expect(msg.sender, 'ai');
    });
  });

  group('ChatMessage factories', () {
    test('ChatMessage.typing() produces an empty, isTyping=true bubble', () {
      final msg = ChatMessage.typing();
      expect(msg.isTyping, isTrue);
      expect(msg.text, '');
      expect(msg.sender, 'ai');
    });

    test('ChatMessage.error() carries the message and intent="error"', () {
      final msg = ChatMessage.error('Đã có lỗi xảy ra, vui lòng thử lại.');
      expect(msg.text, 'Đã có lỗi xảy ra, vui lòng thử lại.');
      expect(msg.intent, 'error');
      expect(msg.sender, 'ai');
    });
  });

  group('ChatMessage.copyWith', () {
    test('copyWith only overrides text, preserves other fields', () {
      const original = ChatMessage(
        sender: 'ai',
        text: 'gốc',
        intent: 'ask_weather',
        confidence: 0.9,
      );
      final updated = original.copyWith(text: 'đã cập nhật');

      expect(updated.text, 'đã cập nhật');
      expect(updated.sender, 'ai');
      expect(updated.intent, 'ask_weather');
      expect(updated.confidence, 0.9);
    });

    test('copyWith with no args returns equivalent values', () {
      const original = ChatMessage(sender: 'user', text: 'không đổi');
      final copy = original.copyWith();
      expect(copy.text, original.text);
      expect(copy.sender, original.sender);
    });
  });
}
