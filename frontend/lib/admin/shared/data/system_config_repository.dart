// lib/admin/shared/data/system_config_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/system_config.dart';
import '../providers/dio_provider.dart';

class SystemConfigRepository {
  final Dio _dio;
  SystemConfigRepository(this._dio);

  Future<List<SystemConfig>> fetchAll() async {
    final resp =
        await _dio.get<List<dynamic>>('/admin/system-config');
    return (resp.data ?? [])
        .map((e) =>
            SystemConfig.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> update(String key, dynamic value) async {
    await _dio.patch<void>(
      '/admin/system-config/$key',
      data: {'value': value},
    );
  }
}

final systemConfigRepositoryProvider =
    Provider<SystemConfigRepository>((ref) {
  return SystemConfigRepository(ref.watch(apiDioProvider));
});
