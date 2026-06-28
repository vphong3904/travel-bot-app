// lib/admin/shared/data/media_repository.dart
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/media_file_model.dart';
import '../providers/dio_provider.dart';

class MediaRepository {
  final Dio _dio;
  MediaRepository(this._dio);

  Future<({List<MediaFileModel> items, int total})> list({
    String tag = '',
    int page = 1,
  }) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/admin/media',
      queryParameters: {
        if (tag.isNotEmpty) 'tag': tag,
        'page': page,
        'page_size': 24,
      },
    );
    final data = resp.data ?? {};
    return (
      items: (data['items'] as List<dynamic>? ?? [])
          .map((e) =>
              MediaFileModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: data['total'] as int? ?? 0,
    );
  }

  Future<MediaFileModel> upload({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
    void Function(int sent, int total)? onProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: DioMediaType.parse(mimeType),
      ),
    });
    final resp = await _dio.post<Map<String, dynamic>>(
      '/admin/media/upload',
      data: formData,
      onSendProgress: onProgress,
    );
    return MediaFileModel.fromJson(resp.data!);
  }

  Future<void> delete(String id) async {
    await _dio.delete<void>('/admin/media/$id');
  }
}

final mediaRepositoryProvider =
    Provider<MediaRepository>((ref) {
  return MediaRepository(ref.watch(apiDioProvider));
});
