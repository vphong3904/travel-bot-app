// lib/services/trip_api_service.dart
// [P1] Lưu lịch trình AI thành "chuyến đi" (TripPlan + items) qua /trips.
import 'api_service.dart';

class TripApiService {
  final TokenProvider tokenProvider;
  final TokenRefresher? tokenRefresher;

  const TripApiService({required this.tokenProvider, this.tokenRefresher});

  ApiClient get _client =>
      ApiClient(tokenProvider: tokenProvider, tokenRefresher: tokenRefresher);

  /// Danh sách chuyến đi của tôi.
  Future<List<dynamic>> listTrips() async {
    final data = await _client.get('/trips/') as List<dynamic>;
    return data;
  }

  Future<Map<String, dynamic>> getTrip(String tripId) async {
    return await _client.get('/trips/$tripId') as Map<String, dynamic>;
  }

  Future<void> deleteTrip(String tripId) async {
    await _client.delete('/trips/$tripId');
  }

  /// TP-001: AI lên lịch trình. Trả về {status: need_info|draft, ...}
  /// (contract .agent/trip-ai/TRIP_AI_ROADMAP.md §2.1).
  Future<Map<String, dynamic>> aiPlan(Map<String, dynamic> payload) async {
    return await _client.post('/trips/ai/plan', payload) as Map<String, dynamic>;
  }

  /// TP-002: Lưu plan user đã chốt vào lịch sử chuyến đi. Trả về TripPlanOut.
  Future<Map<String, dynamic>> aiConfirm(Map<String, dynamic> plan) async {
    return await _client.post('/trips/ai/confirm', plan) as Map<String, dynamic>;
  }

  /// Lưu một itinerary thành TripPlan kèm các item theo ngày. Hỗ trợ CẢ 2
  /// shape itinerary đang tồn tại trong app (khác nguồn dữ liệu, cùng ý
  /// nghĩa):
  ///   - Từ chatbot/RAG (structured_search.build_itinerary): 'destination',
  ///     'days': [{'day': N, 'activities': ['chuỗi mô tả', ...]}]
  ///   - Từ itinerary mẫu tĩnh (/travel/itineraries/{id}): 'destination_name',
  ///     'title', 'days': [{'day_no': N, 'items': [{'title':...,
  ///     'description':...}, ...]}]
  /// Bug đã sửa: trước đây chỉ đọc đúng shape đầu tiên — gọi trên shape thứ 2
  /// (itinerary mẫu tĩnh) sẽ tạo được TripPlan nhưng KHÔNG lưu item nào (day
  /// luôn ra 1, activities luôn rỗng) vì đọc sai tên field.
  /// Trả về tripId đã tạo.
  Future<String> saveItinerary(Map<String, dynamic> itinerary) async {
    final title = (itinerary['title'] ?? itinerary['name'])?.toString() ?? '';
    final dest = (itinerary['destination'] ?? itinerary['destination_name'] ?? '').toString();
    final budgetHigh = itinerary['budget_high'];
    final body = <String, dynamic>{
      if (itinerary['destination_id'] != null)
        'destination_id': itinerary['destination_id'].toString(),
      'title': title.isNotEmpty
          ? title
          : (dest.isNotEmpty ? 'Lịch trình $dest' : 'Lịch trình của tôi'),
      if (budgetHigh is num && budgetHigh > 0) 'budget': budgetHigh.toInt(),
      // Dùng 'group_type' (key thật: solo/couple/family/group) chứ KHÔNG
      // dùng 'group' (nhãn hiển thị tiếng Việt, vd "Nhóm bạn") — bug đã sửa:
      // gửi thẳng nhãn hiển thị làm travel_type vi phạm CHECK constraint ở
      // backend, khiến lưu chuyến đi lỗi (IntegrityError/"Failed to fetch").
      if (itinerary['group_type'] != null &&
          itinerary['group_type'].toString().isNotEmpty)
        'travel_type': itinerary['group_type'].toString(),
    };
    final trip = await _client.post('/trips', body) as Map<String, dynamic>;
    final tripId = trip['id'].toString();

    // Thêm item theo từng ngày — chấp nhận cả 'day'/'activities' (chatbot) và
    // 'day_no'/'items' (itinerary mẫu tĩnh).
    final days = itinerary['days'] is List ? itinerary['days'] as List : const [];
    for (final d in days) {
      if (d is! Map) continue;
      final dayNo = (d['day'] as num?)?.toInt() ?? (d['day_no'] as num?)?.toInt() ?? 1;
      final rawActs = d['activities'] is List
          ? d['activities'] as List
          : (d['items'] is List ? d['items'] as List : const []);
      var order = 0;
      for (final a in rawActs) {
        // 'activities' là chuỗi mô tả sẵn; 'items' là object {title,
        // description, time_slot} — gộp thành 1 dòng dễ đọc.
        final title = a is Map
            ? (a['title'] ?? a['description'] ?? '').toString()
            : a.toString();
        if (title.isEmpty) continue;
        await _client.post('/trips/$tripId/items', {
          'day_number': dayNo,
          'order_in_day': order++,
          'title': title,
        });
      }
    }
    return tripId;
  }
}
