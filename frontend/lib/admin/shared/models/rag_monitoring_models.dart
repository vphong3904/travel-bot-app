// lib/admin/shared/models/rag_monitoring_models.dart

class RagOverview {
  final double avgConfidenceScore;
  final double avgSearchMs;
  final double avgLlmMs;
  final double hallucinationRate;
  final double avgChunkCount;
  final Map<String, double> cacheHitRate;
  final Map<String, double> searchMethodBreakdown;
  final List<({String date, double avgScore})> confidenceOverTime;

  const RagOverview({
    required this.avgConfidenceScore,
    required this.avgSearchMs,
    required this.avgLlmMs,
    required this.hallucinationRate,
    required this.avgChunkCount,
    required this.cacheHitRate,
    required this.searchMethodBreakdown,
    required this.confidenceOverTime,
  });

  factory RagOverview.fromJson(Map<String, dynamic> j) => RagOverview(
        avgConfidenceScore:
            (j['avg_confidence_score'] as num?)?.toDouble() ?? 0,
        avgSearchMs: (j['avg_search_ms'] as num?)?.toDouble() ?? 0,
        avgLlmMs: (j['avg_llm_ms'] as num?)?.toDouble() ?? 0,
        hallucinationRate:
            (j['hallucination_rate'] as num?)?.toDouble() ?? 0,
        avgChunkCount: (j['avg_chunk_count'] as num?)?.toDouble() ?? 0,
        cacheHitRate: Map<String, double>.from(
          (j['cache_hit_rate'] as Map?)?.map((k, v) =>
                  MapEntry(k as String, (v as num).toDouble())) ??
              {},
        ),
        searchMethodBreakdown: Map<String, double>.from(
          (j['search_method_breakdown'] as Map?)?.map((k, v) =>
                  MapEntry(k as String, (v as num).toDouble())) ??
              {},
        ),
        confidenceOverTime:
            ((j['confidence_over_time'] as List?) ?? [])
                .map((e) => (
                      date: e['date'] as String,
                      avgScore:
                          (e['avg_score'] as num).toDouble(),
                    ))
                .toList(),
      );
}
