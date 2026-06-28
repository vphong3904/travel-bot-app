// lib/admin/shared/data/intent_patterns_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/intent_patterns_models.dart';
import '../providers/dio_provider.dart';

class IntentPatternsRepository {
  final Dio _dio;
  IntentPatternsRepository(this._dio);

  Future<List<IntentPattern>> fetchAll() async {
    final resp =
        await _dio.get<Map<String, dynamic>>('/admin/intent-patterns');
    final data = resp.data ?? {};
    return data.entries
        .map((e) =>
            IntentPattern.fromJson(e.key, e.value as Map<String, dynamic>))
        .toList();
  }

  Future<void> addKeyword(String intent, String keyword) async {
    await _dio.post<void>(
      '/admin/intent-patterns/$intent/keywords',
      data: {'keyword': keyword},
    );
  }

  Future<void> deleteKeyword(String intent, String keyword) async {
    await _dio.delete<void>(
      '/admin/intent-patterns/$intent/keywords/$keyword',
    );
  }

  Future<IntentTestResult> testText(String text) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/admin/intent-patterns/test',
      data: {'text': text},
    );
    return IntentTestResult.fromJson(resp.data!);
  }
}

final intentPatternsRepositoryProvider =
    Provider<IntentPatternsRepository>((ref) {
  return IntentPatternsRepository(ref.watch(apiDioProvider));
});
