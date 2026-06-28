// lib/admin/shared/models/intent_patterns_models.dart

class IntentKeyword {
  final String keyword;
  final bool isCollision;

  const IntentKeyword({
    required this.keyword,
    required this.isCollision,
  });

  factory IntentKeyword.fromJson(Map<String, dynamic> j) =>
      IntentKeyword(
        keyword: j['keyword'] as String,
        isCollision: (j['is_collision'] as bool?) ?? false,
      );
}

class IntentPattern {
  final String intent;
  final List<IntentKeyword> keywords;
  final List<String> collisionWarnings;

  const IntentPattern({
    required this.intent,
    required this.keywords,
    required this.collisionWarnings,
  });

  factory IntentPattern.fromJson(String intent, Map<String, dynamic> j) {
    final rawKeywords = j['keywords'] as List<dynamic>? ?? [];
    final warnings = (j['collision_warnings'] as List<dynamic>? ?? [])
        .cast<String>();
    return IntentPattern(
      intent: intent,
      keywords: rawKeywords
          .map((k) => IntentKeyword.fromJson(k as Map<String, dynamic>))
          .toList(),
      collisionWarnings: warnings,
    );
  }
}

class IntentTestResult {
  final String intent;
  final double confidence;
  final List<String> matchedKeywords;

  const IntentTestResult({
    required this.intent,
    required this.confidence,
    required this.matchedKeywords,
  });

  factory IntentTestResult.fromJson(Map<String, dynamic> j) =>
      IntentTestResult(
        intent: j['intent'] as String,
        confidence: (j['confidence'] as num).toDouble(),
        matchedKeywords:
            (j['matched_keywords'] as List<dynamic>? ?? []).cast<String>(),
      );
}
