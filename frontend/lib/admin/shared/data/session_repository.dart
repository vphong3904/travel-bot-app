// lib/admin/shared/data/session_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_session.dart';
import '../providers/dio_provider.dart';

class SessionRepository {
  final Dio _dio;
  SessionRepository(this._dio);

  Future<List<UserSession>> fetchSessions(
      String userId) async {
    final resp = await _dio.get<List<dynamic>>(
      '/admin/sessions',
      queryParameters: {'user_id': userId},
    );
    return (resp.data ?? [])
        .map((e) =>
            UserSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> revoke(String sessionId) async {
    await _dio.delete<void>('/admin/sessions/$sessionId');
  }
}

final sessionRepositoryProvider =
    Provider<SessionRepository>((ref) {
  return SessionRepository(ref.watch(apiDioProvider));
});
