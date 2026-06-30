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
    final data = await _client.get('/trips') as List<dynamic>;
    return data;
  }

  Future<Map<String, dynamic>> getTrip(String tripId) async {
    return await _client.get('/trips/$tripId') as Map<String, dynamic>;
  }

  Future<void> deleteTrip(String tripId) async {
    await _client.delete('/trips/$tripId');
  }

  /// Lưu một itinerary (từ chatbot) thành TripPlan kèm các item theo ngày.
  /// Trả về tripId đã tạo.
  Future<String> saveItinerary(Map<String, dynamic> itinerary) async {
    final dest = (itinerary['destination'] ?? '').toString();
    final budgetHigh = itinerary['budget_high'];
    final body = <String, dynamic>{
      if (itinerary['destination_id'] != null)
        'destination_id': itinerary['destination_id'].toString(),
      'title': dest.isNotEmpty ? 'Lịch trình $dest' : 'Lịch trình của tôi',
      if (budgetHigh is num && budgetHigh > 0) 'budget': budgetHigh.toInt(),
      if (itinerary['group'] != null && itinerary['group'].toString().isNotEmpty)
        'travel_type': itinerary['group'].toString(),
    };
    final trip = await _client.post('/trips', body) as Map<String, dynamic>;
    final tripId = trip['id'].toString();

    // Thêm item theo từng ngày
    final days = itinerary['days'] is List ? itinerary['days'] as List : const [];
    for (final d in days) {
      if (d is! Map) continue;
      final dayNo = (d['day'] as num?)?.toInt() ?? 1;
      final acts = d['activities'] is List ? d['activities'] as List : const [];
      var order = 0;
      for (final a in acts) {
        await _client.post('/trips/$tripId/items', {
          'day_number': dayNo,
          'order_in_day': order++,
          'title': a.toString(),
        });
      }
    }
    return tripId;
  }
}
