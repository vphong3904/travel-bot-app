/// Một nguồn tham khảo (chunk) được RAG trả về — id, score, text, title,
/// category, source ("qdrant" | "postgres_fts").
///
/// ✅ FIX: trước đây backend trả `sources` là List<Map>, nhưng frontend ép
/// về List<String> bằng `.toString()`. Với Dart, `Map.toString()` in ra
/// dạng debug thô "{id: pg_0, score: 0.12, text: ..., title: ..., ...}",
/// nên cả nội dung đó bị hiển thị thẳng lên UI dưới dạng "chip nguồn".
/// Sửa triệt để bằng cách parse đúng cấu trúc thay vì stringify cả object.
class SourceRef {
  final String id;
  final double score;
  final String text;
  final String title;
  final String category;
  final String source;

  const SourceRef({
    required this.id,
    this.score = 0,
    this.text = '',
    this.title = '',
    this.category = '',
    this.source = '',
  });

  /// Parse 1 phần tử của mảng `sources`. Chấp nhận cả trường hợp backend
  /// (lỗi) gửi string thuần, để không bao giờ crash UI.
  factory SourceRef.fromDynamic(dynamic e) {
    if (e is Map) {
      final map = Map<String, dynamic>.from(e);
      return SourceRef(
        id: map['id']?.toString() ?? '',
        score: (map['score'] as num?)?.toDouble() ?? 0,
        text: map['text']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        category: map['category']?.toString() ?? '',
        source: map['source']?.toString() ?? '',
      );
    }
    // Fallback: backend trả string đơn giản (vd tên điểm đến) — vẫn hiển thị được.
    return SourceRef(id: '', title: e.toString());
  }

  /// Nhãn hiển thị ngắn gọn cho chip UI — KHÔNG BAO GIỜ in cả object.
  String get displayLabel => title.isNotEmpty ? title : (text.length > 40 ? '${text.substring(0, 40)}…' : text);
}

class ChatMessage {
  final String sender; // 'user' | 'ai' | 'system'
  final String text;
  final bool hasItinerary;
  final Map<String, dynamic>? itinerary;
  final List<dynamic>? destinations;
  final List<dynamic>? services;
  final List<SourceRef> sources;
  final String intent;
  final double confidence;
  final bool isTyping;

  const ChatMessage({
    required this.sender,
    required this.text,
    this.hasItinerary = false,
    this.itinerary,
    this.destinations,
    this.services,
    this.sources = const [],
    this.intent = '',
    this.confidence = 0,
    this.isTyping = false,
  });

  factory ChatMessage.typing() => const ChatMessage(
        sender: 'ai',
        text: '',
        isTyping: true,
      );

  factory ChatMessage.error(String message) => ChatMessage(
        sender: 'ai',
        text: message,
        intent: 'error',
      );

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final rawText = json['text'] ?? json['content'] ?? '';
    final rawSources = json['sources'] as List<dynamic>?;
    return ChatMessage(
      sender: json['sender']?.toString() ?? 'ai',
      text: rawText.toString(),
      hasItinerary: json['has_itinerary'] as bool? ?? false,
      itinerary: json['itinerary'] as Map<String, dynamic>?,
      destinations: json['destinations'] as List<dynamic>?,
      services: json['services'] as List<dynamic>?,
      sources: rawSources?.map((e) => SourceRef.fromDynamic(e)).toList() ?? [],
      intent: json['intent'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
    );
  }

  ChatMessage copyWith({String? text, bool? isTyping}) => ChatMessage(
        sender: sender,
        text: text ?? this.text,
        isTyping: isTyping ?? this.isTyping,
        // Copy các thuộc tính khác...
        hasItinerary: hasItinerary, itinerary: itinerary, sources: sources, intent: intent, confidence: confidence,
      );
}