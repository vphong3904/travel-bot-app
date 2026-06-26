import '../models/destination.dart';
import 'api_service.dart';


class FavoriteApiService {
  final ApiClient _client;
  FavoriteApiService({required String token}) : _client = ApiClient(token: token);

  /// Toggle yêu thích cho 1 destination, trả về trạng thái mới (true = đã thích)
  Future<bool> toggle(String destinationId) async {
    final data = await _client.post('/travel/favorites/$destinationId') as Map<String, dynamic>;
    // Backend trả về FavoriteStatusOut với key "is_favorited"
    final v = data['is_favorited'] ?? data['is_favorite'] ?? data['favorited'];
    return v == true;
  }

  /// Kiểm tra trạng thái yêu thích hiện tại
  Future<bool> status(String destinationId) async {
    try {
      final data = await _client.get('/travel/favorites/$destinationId/status') as Map<String, dynamic>;
      // Backend: FavoriteStatusOut.is_favorited
      final v = data['is_favorited'] ?? data['is_favorite'] ?? data['favorited'];
      return v == true;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return false;
      rethrow;
    }
  }

  /// Danh sách destination đã yêu thích của user hiện tại
  /// Backend trả List<FavoriteDestinationOut> — mỗi item có nested field "destination"
  Future<List<Destination>> listMyFavorites() async {
    final data = await _client.get('/travel/favorites') as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map((e) {
          // FavoriteDestinationOut: { destination_id, created_at, destination: {...} }
          final destData = e['destination'];
          if (destData is Map<String, dynamic>) {
            return Destination.fromJson(destData);
          }
          // Fallback nếu backend trả flat
          return Destination.fromJson(e);
        })
        .toList();
  }

  Future<void> remove(String destinationId) async {
    await _client.delete('/travel/favorites/$destinationId');
  }
}
