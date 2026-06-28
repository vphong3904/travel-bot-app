// lib/admin/shared/data/city_mapping_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city_mapping_models.dart';
import '../providers/dio_provider.dart';

class CityMappingRepository {
  final Dio _dio;
  CityMappingRepository(this._dio);

  Future<List<CityMapping>> fetchValidate() async {
    final resp = await _dio
        .get<List<dynamic>>('/admin/city-mappings/validate');
    return (resp.data ?? [])
        .map((e) =>
            CityMapping.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> fetchValidSlugs() async {
    final resp = await _dio
        .get<List<dynamic>>('/admin/city-mappings/valid-slugs');
    return (resp.data ?? []).cast<String>();
  }

  Future<void> updateMapping(
      String oldProvince, String newSlug) async {
    await _dio.patch<void>(
      '/admin/city-mappings/$oldProvince',
      data: {'new_slug': newSlug},
    );
  }
}

final cityMappingRepositoryProvider =
    Provider<CityMappingRepository>((ref) {
  return CityMappingRepository(ref.watch(apiDioProvider));
});
