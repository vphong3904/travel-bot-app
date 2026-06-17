class ChatMessage {
  final String sender; // 'user' | 'ai' | 'system'
  final String text;
  final bool hasItinerary;
  final Map<String, dynamic>? itinerary;
  final List<dynamic>? destinations;
  final List<dynamic>? services;
  final List<String> sources;
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

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        sender: 'ai',
        text: json['text'] as String? ?? '',
        hasItinerary: json['has_itinerary'] as bool? ?? false,
        itinerary: json['itinerary'] as Map<String, dynamic>?,
        destinations: json['destinations'] as List<dynamic>?,
        services: json['services'] as List<dynamic>?,
        sources: (json['sources'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        intent: json['intent'] as String? ?? '',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      );

  ChatMessage copyWith({String? text, bool? isTyping}) => ChatMessage(
        sender: sender,
        text: text ?? this.text,
        isTyping: isTyping ?? this.isTyping,
        // Copy các thuộc tính khác...
        hasItinerary: hasItinerary, itinerary: itinerary, sources: sources, intent: intent, confidence: confidence,
      );
}