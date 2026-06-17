// lib/services/travel_api_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// TravelApiService — /travel/destinations + sub-resources
// SearchApiService — /search
// AdminApiService  — /admin/*  (cần role admin)
// ─────────────────────────────────────────────────────────────────────────────

import '../models/destination.dart';
import 'api_service.dart';

// ═════════════════════════════════════════════════════════════════════════════
// TRAVEL
// ═════════════════════════════════════════════════════════════════════════════

class TravelApiService {
  final String? token;

  TravelApiService({this.token});

  ApiClient get _client => ApiClient(token: token);

  // ── Destinations ───────────────────────────────────────────────────────────

  Future<List<Destination>> getDestinations({
    String? search,
    String? region,
    String? tag,
    int skip = 0,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'skip': '$skip',
      'limit': '$limit',
    };
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (region != null && region.isNotEmpty) params['region'] = region;
    if (tag != null && tag.isNotEmpty) params['tag'] = tag;

    final data =
        await _client.get('/travel/destinations', params) as List<dynamic>;
    return data
        .map((e) => Destination.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Destination?> getDestination(dynamic id) async {
    try {
      final data = await _client.get('/travel/destinations/$id')
          as Map<String, dynamic>;
      return Destination.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<List<dynamic>> getHotels(dynamic destinationId) async {
    final data = await _client
        .get('/travel/destinations/$destinationId/hotels') as List<dynamic>;
    return data;
  }

  Future<List<dynamic>> getTours(dynamic destinationId) async {
    final data = await _client
        .get('/travel/destinations/$destinationId/tours') as List<dynamic>;
    return data;
  }

  Future<List<dynamic>> getTickets(dynamic destinationId) async {
    final data = await _client
        .get('/travel/destinations/$destinationId/tickets') as List<dynamic>;
    return data;
  }

  Future<List<dynamic>> getEvents(dynamic destinationId) async {
    final data = await _client
        .get('/travel/destinations/$destinationId/events') as List<dynamic>;
    return data;
  }

  Future<List<dynamic>> getTransport(dynamic destinationId) async {
    final data = await _client
        .get('/travel/destinations/$destinationId/transport') as List<dynamic>;
    return data;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TRIPS
// ═════════════════════════════════════════════════════════════════════════════

class TripApiService {
  final String token;

  TripApiService({required this.token});

  ApiClient get _client => ApiClient(token: token);

  Future<List<dynamic>> getTrips() async {
    final data = await _client.get('/trips') as List<dynamic>;
    return data;
  }

  Future<Map<String, dynamic>> getTrip(String tripId) async {
    final data = await _client.get('/trips/$tripId') as Map<String, dynamic>;
    return data;
  }

  Future<Map<String, dynamic>> createTrip(Map<String, dynamic> body) async {
    final data = await _client.post('/trips', body) as Map<String, dynamic>;
    return data;
  }

  Future<Map<String, dynamic>> updateTrip(
      String tripId, Map<String, dynamic> body) async {
    final data =
        await _client.patch('/trips/$tripId', body) as Map<String, dynamic>;
    return data;
  }

  Future<void> deleteTrip(String tripId) async {
    await _client.delete('/trips/$tripId');
  }

  Future<Map<String, dynamic>> addItem(
      String tripId, Map<String, dynamic> body) async {
    final data = await _client.post('/trips/$tripId/items', body)
        as Map<String, dynamic>;
    return data;
  }

  Future<Map<String, dynamic>> updateItem(
      String tripId, String itemId, Map<String, dynamic> body) async {
    final data = await _client.patch('/trips/$tripId/items/$itemId', body)
        as Map<String, dynamic>;
    return data;
  }

  Future<void> deleteItem(String tripId, String itemId) async {
    await _client.delete('/trips/$tripId/items/$itemId');
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SEARCH
// ═════════════════════════════════════════════════════════════════════════════

class SearchApiService {
  final String? token;

  SearchApiService({this.token});

  ApiClient get _client => ApiClient(token: token);

  Future<List<dynamic>> search({
    required String q,
    String? type,
    String? destination,
  }) async {
    final params = <String, String>{'q': q};
    if (type != null && type.isNotEmpty) params['type'] = type;
    if (destination != null && destination.isNotEmpty)
      params['destination'] = destination;

    final data = await _client.get('/search', params);
    if (data is List) return data;
    // Một số backend trả {'results': [...]}
    if (data is Map && data.containsKey('results')) {
      return data['results'] as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> getHistory() async {
    if (token == null) return [];
    final data = await _client.get('/search/history');
    if (data is List) return data;
    return [];
  }

  Future<void> clearHistory() async {
    if (token == null) return;
    await _client.delete('/search/history');
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ADMIN (cần role: admin)
// ═════════════════════════════════════════════════════════════════════════════

class AdminApiService {
  final String token;

  AdminApiService({required this.token});

  ApiClient get _client => ApiClient(token: token);

  // ── Stats ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getStatsQuestions() async =>
      await _client.get('/admin/stats/questions') as Map<String, dynamic>;

  Future<Map<String, dynamic>> getStatsDestinations() async =>
      await _client.get('/admin/stats/destinations') as Map<String, dynamic>;

  Future<Map<String, dynamic>> getStatsChatbot() async =>
      await _client.get('/admin/stats/chatbot') as Map<String, dynamic>;

  Future<Map<String, dynamic>> getStatsUsers() async =>
      await _client.get('/admin/stats/users') as Map<String, dynamic>;

  // ── Users ──────────────────────────────────────────────────────────────────

  Future<List<dynamic>> getUsers() async {
    final data = await _client.get('/admin/users') as List<dynamic>;
    return data;
  }

  Future<Map<String, dynamic>> updateUser(
      String userId, Map<String, dynamic> body) async {
    return await _client.patch('/admin/users/$userId', body)
        as Map<String, dynamic>;
  }

  // ── Knowledge Base ─────────────────────────────────────────────────────────

  Future<List<dynamic>> getKnowledge({String? category}) async {
    final params = category != null ? {'category': category} : null;
    final data = await _client.get('/admin/knowledge', params) as List<dynamic>;
    return data;
  }

  Future<Map<String, dynamic>> createKnowledge(
      Map<String, dynamic> body) async {
    return await _client.post('/admin/knowledge', body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateKnowledge(
      String id, Map<String, dynamic> body) async {
    return await _client.patch('/admin/knowledge/$id', body)
        as Map<String, dynamic>;
  }

  Future<void> deleteKnowledge(String id) async {
    await _client.delete('/admin/knowledge/$id');
  }

  // ── Chat Logs ──────────────────────────────────────────────────────────────

  Future<List<dynamic>> getChatLogs({String? intent}) async {
    final params = intent != null ? {'intent': intent} : null;
    final data =
        await _client.get('/admin/chat-logs', params) as List<dynamic>;
    return data;
  }

  // ── Embedding Jobs ─────────────────────────────────────────────────────────

  Future<List<dynamic>> getEmbeddingJobs() async {
    final data =
        await _client.get('/admin/embedding-jobs') as List<dynamic>;
    return data;
  }
}