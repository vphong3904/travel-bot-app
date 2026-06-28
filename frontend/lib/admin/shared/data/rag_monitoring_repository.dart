// lib/admin/shared/data/rag_monitoring_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rag_monitoring_models.dart';
import '../providers/dio_provider.dart';

class RagMonitoringRepository {
  final Dio _dio;
  RagMonitoringRepository(this._dio);

  Future<RagOverview> fetchOverview({
    DateTime? from,
    DateTime? to,
  }) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/admin/rag-monitoring/overview',
      queryParameters: {
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
      },
    );
    return RagOverview.fromJson(resp.data!);
  }

  Future<List<Map<String, dynamic>>> fetchLatency() async {
    final resp = await _dio
        .get<Map<String, dynamic>>('/admin/rag-monitoring/latency');
    return (resp.data!['items'] as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchErrors() async {
    final resp = await _dio
        .get<Map<String, dynamic>>('/admin/rag-monitoring/errors');
    return (resp.data!['items'] as List).cast<Map<String, dynamic>>();
  }
}

final ragMonitoringRepositoryProvider =
    Provider<RagMonitoringRepository>((ref) {
  return RagMonitoringRepository(ref.watch(apiDioProvider));
});
