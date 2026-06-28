// lib/admin/shared/data/kb_health_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kb_health_models.dart';
import '../providers/dio_provider.dart';

class KbHealthRepository {
  final Dio _dio;
  KbHealthRepository(this._dio);

  Future<KbHealthResponse> fetchHealth() async {
    final resp =
        await _dio.get<Map<String, dynamic>>('/admin/kb-health');
    return KbHealthResponse.fromJson(resp.data!);
  }
}

final kbHealthRepositoryProvider = Provider<KbHealthRepository>((ref) {
  return KbHealthRepository(ref.watch(apiDioProvider));
});
