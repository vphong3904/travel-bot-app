// lib/services/travel_api_service.dart
// ---------------------------------------------------------------------------
// TravelApiService — gợi ý cá nhân hoá "Dành cho bạn" (TP-003/007).
//
//   GET /travel/suggestions/for-you → gợi ý điểm đến theo hồ sơ sở thích.
// ---------------------------------------------------------------------------

import '../models/destination.dart';
import 'api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Gợi ý cá nhân hoá "Dành cho bạn" (TP-003)
// ─────────────────────────────────────────────────────────────────────────────

class ForYouResult {
  final List<Destination> items;
  final List<String> tagLabels; // nhãn sở thích đã nhận diện (vd "Biển đảo")
  final String? reason;         // lời giải thích, null khi chưa đủ tín hiệu

  const ForYouResult({
    required this.items,
    required this.tagLabels,
    this.reason,
  });

  bool get personalized => tagLabels.isNotEmpty;
}

// ─────────────────────────────────────────────────────────────────────────────

class TravelApiService {
  final ApiClient _client;

  TravelApiService({String? accessToken, TokenProvider? tokenProvider})
      : _client = ApiClient(
          token: accessToken,
          tokenProvider: tokenProvider,
        );

  /// GET /travel/suggestions/for-you — gợi ý theo hồ sơ sở thích hành vi.
  /// Trả về ForYouResult; user mới/guest → tags rỗng + items nổi bật.
  Future<ForYouResult> getForYouSuggestions({int limit = 10}) async {
    final data = await _client.get(
        '/travel/suggestions/for-you', {'limit': '$limit'}) as Map<String, dynamic>;
    final items = <Destination>[];
    if (data['items'] is List) {
      for (final it in data['items'] as List) {
        if (it is Map) items.add(Destination.fromJson(Map<String, dynamic>.from(it)));
      }
    }
    final tags = <String>[];
    if (data['tags'] is List) {
      for (final t in data['tags'] as List) {
        if (t is Map && t['label'] != null) tags.add(t['label'].toString());
      }
    }
    return ForYouResult(
      items: items,
      tagLabels: tags,
      reason: data['reason']?.toString(),
    );
  }
}
