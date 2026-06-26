// lib/services/travel_api_service.dart (bổ sung endpoints dịch vụ)
// ---------------------------------------------------------------------------
// TravelApiService — toàn bộ endpoints trang dịch vụ / khám phá:
//
//   GET  /travel/destinations     → Danh sách điểm đến (có filter, paginate)
//   GET  /travel/destinations/:id → Chi tiết điểm đến
//   GET  /travel/hotels           → Danh sách khách sạn
//   GET  /travel/hotels/:id       → Chi tiết khách sạn
//   GET  /travel/tours            → Danh sách tour
//   GET  /travel/tours/:id        → Chi tiết tour
//   GET  /search                  → Tìm kiếm tổng hợp (hotels + tours + destinations)
//
//   Favorites:
//   GET  /favorites               → Danh sách yêu thích (cần auth)
//   POST /favorites               → Thêm yêu thích (cần auth)
//   DELETE /favorites/:id         → Xoá yêu thích (cần auth)
//
//   Reviews:
//   GET  /reviews?destination_id= → Reviews của 1 điểm đến
//   POST /reviews                 → Tạo review (cần auth)
//
//   Trips:
//   GET  /trips                   → Lịch trình của user (cần auth)
//   POST /trips                   → Tạo lịch trình (cần auth)
//   GET  /trips/:id               → Chi tiết lịch trình
//   PATCH /trips/:id              → Cập nhật lịch trình
//   DELETE /trips/:id             → Xóa lịch trình
// ---------------------------------------------------------------------------

import '../models/destination.dart';
import '../models/review.dart';
import '../models/service.dart';
import 'api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Search result
// ─────────────────────────────────────────────────────────────────────────────

class SearchResult {
  final List<Service> hotels;
  final List<Service> tours;
  final List<Service> destinations;

  const SearchResult({
    required this.hotels,
    required this.tours,
    required this.destinations,
  });

  List<Service> get all => [...hotels, ...tours, ...destinations];
}

// ─────────────────────────────────────────────────────────────────────────────

class TravelApiService {
  final ApiClient _client;

  TravelApiService({String? accessToken, TokenProvider? tokenProvider})
      : _client = ApiClient(
          token: accessToken,
          tokenProvider: tokenProvider,
        );

  // ── Destinations ─────────────────────────────────────────────────────────

  Future<List<Destination>> getDestinations({
    String? province,
    String? region,
    int page = 1,
    int pageSize = 20,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'page_size': '$pageSize',
      if (province != null) 'province': province,
      if (region != null) 'region': region,
    };
    final data = await _client.get('/travel/destinations', params);
    if (data == null) return [];
    final list = (data['items'] ?? data) as List;
    return list
        .whereType<Map<String, dynamic>>()
        .map(Destination.fromJson)
        .toList();
  }

  Future<Destination?> getDestinationById(int id) async {
    try {
      final data = await _client.get('/travel/destinations/$id');
      if (data == null) return null;
      return Destination.fromJson(data as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  // ── Hotels ────────────────────────────────────────────────────────────────

  Future<List<Service>> getHotels({
    String? destinationId,
    String? province,
    int page = 1,
    int pageSize = 20,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'page_size': '$pageSize',
      if (destinationId != null) 'destination_id': destinationId,
      if (province != null) 'province': province,
    };
    final data = await _client.get('/travel/hotels', params);
    if (data == null) return [];
    final list = (data['items'] ?? data) as List;
    return list
        .whereType<Map<String, dynamic>>()
        .map((j) => Service.fromJson({...j, 'type': 'hotel'}))
        .toList();
  }

  Future<Service?> getHotelById(int id) async {
    try {
      final data = await _client.get('/travel/hotels/$id');
      if (data == null) return null;
      return Service.fromJson({...(data as Map<String, dynamic>), 'type': 'hotel'});
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  // ── Tours ─────────────────────────────────────────────────────────────────

  Future<List<Service>> getTours({
    String? destinationId,
    String? province,
    int page = 1,
    int pageSize = 20,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'page_size': '$pageSize',
      if (destinationId != null) 'destination_id': destinationId,
      if (province != null) 'province': province,
    };
    final data = await _client.get('/travel/tours', params);
    if (data == null) return [];
    final list = (data['items'] ?? data) as List;
    return list
        .whereType<Map<String, dynamic>>()
        .map((j) => Service.fromJson({...j, 'type': 'tour'}))
        .toList();
  }

  Future<Service?> getTourById(int id) async {
    try {
      final data = await _client.get('/travel/tours/$id');
      if (data == null) return null;
      return Service.fromJson({...(data as Map<String, dynamic>), 'type': 'tour'});
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  // ── Search tổng hợp ───────────────────────────────────────────────────────

  Future<SearchResult> search({
    String q = '',
    String? type,        // 'hotel' | 'tour' | 'destination' | null (tất cả)
    String? province,
    int limit = 10,
  }) async {
    final params = <String, String>{
      'q': q,
      'limit': '$limit',
      if (type != null) 'type': type,
      if (province != null) 'province': province,
    };
    final data = await _client.get('/search', params);
    if (data == null) {
      return const SearchResult(hotels: [], tours: [], destinations: []);
    }

    List<Service> parseList(String key, String serviceType) {
      final list = data[key];
      if (list is! List) return [];
      return list
          .whereType<Map<String, dynamic>>()
          .map((j) => Service.fromJson({...j, 'type': serviceType}))
          .toList();
    }

    return SearchResult(
      hotels:       parseList('hotels', 'hotel'),
      tours:        parseList('tours', 'tour'),
      destinations: parseList('destinations', 'destination'),
    );
  }

  // ── Favorites (cần auth) ──────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final data = await _client.get('/favorites');
    if (data == null) return [];
    return (data as List).whereType<Map<String, dynamic>>().toList();
  }

  Future<void> addFavorite({
    required int destinationId,
    String? note,
  }) async {
    await _client.post('/favorites', {
      'destination_id': destinationId,
      if (note != null) 'note': note,
    });
  }

  Future<void> removeFavorite(int favoriteId) async {
    await _client.delete('/favorites/$favoriteId');
  }

  // ── Reviews ───────────────────────────────────────────────────────────────

  Future<List<Review>> getReviews({
    int? destinationId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'page_size': '$pageSize',
      if (destinationId != null) 'destination_id': '$destinationId',
    };
    final data = await _client.get('/reviews', params);
    if (data == null) return [];
    final list = (data['items'] ?? data) as List;
    return list.whereType<Map<String, dynamic>>().map(Review.fromJson).toList();
  }

  Future<void> createReview({
    required int destinationId,
    required double rating,
    String? comment,
  }) async {
    await _client.post('/reviews', {
      'destination_id': destinationId,
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    });
  }

  // ── Trips / Lịch trình (cần auth) ─────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getTrips() async {
    final data = await _client.get('/trips');
    if (data == null) return [];
    return (data as List).whereType<Map<String, dynamic>>().toList();
  }

  Future<Map<String, dynamic>?> getTripById(String tripId) async {
    try {
      final data = await _client.get('/trips/$tripId');
      return data as Map<String, dynamic>?;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createTrip({
    required String title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final data = await _client.post('/trips', {
      'title': title,
      if (description != null) 'description': description,
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
    });
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateTrip(
    String tripId, {
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (startDate != null) body['start_date'] = startDate.toIso8601String();
    if (endDate != null) body['end_date'] = endDate.toIso8601String();

    final data = await _client.patch('/trips/$tripId', body);
    return data as Map<String, dynamic>;
  }

  Future<void> deleteTrip(String tripId) async {
    await _client.delete('/trips/$tripId');
  }
}
