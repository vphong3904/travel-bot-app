// lib/admin/shared/data/media_repository.dart
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/media_file_model.dart';
import '../providers/dio_provider.dart';

class MediaRepository {
  final Dio _dio;
  MediaRepository(this._dio);

  // ── Folders ────────────────────────────────────────────────────────────────

  /// Toàn bộ thư mục (phẳng) kèm số ảnh + thời điểm thêm ảnh gần nhất.
  Future<List<MediaFolderModel>> listFolders() async {
    final resp = await _dio.get<List<dynamic>>('/admin/media/folders');
    return (resp.data ?? [])
        .map((e) => MediaFolderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MediaFolderModel> createFolder({
    required String name,
    String? parentId,
  }) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/admin/media/folders',
      data: {'name': name, if (parentId != null) 'parent_id': parentId},
    );
    return MediaFolderModel.fromJson(resp.data!);
  }

  Future<void> renameFolder(String id, String name) async {
    await _dio.patch<void>('/admin/media/folders/$id', data: {'name': name});
  }

  Future<void> deleteFolder(String id) async {
    await _dio.delete<void>('/admin/media/folders/$id');
  }

  // ── Files ──────────────────────────────────────────────────────────────────

  Future<({List<MediaFileModel> items, int total})> list({
    String? folderId,
    String tag = '',
    int page = 1,
  }) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/admin/media',
      queryParameters: {
        if (folderId != null) 'folder_id': folderId,
        if (tag.isNotEmpty) 'tag': tag,
        'page': page,
        'page_size': 24,
      },
    );
    final data = resp.data ?? {};
    return (
      items: (data['items'] as List<dynamic>? ?? [])
          .map((e) => MediaFileModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: data['total'] as int? ?? 0,
    );
  }

  /// Upload nhiều ảnh 1 lần vào thư mục đang mở.
  Future<List<MediaFileModel>> uploadMany({
    required List<({Uint8List bytes, String filename, String mimeType})> files,
    String? folderId,
    void Function(int sent, int total)? onProgress,
  }) async {
    final formData = FormData();
    for (final f in files) {
      formData.files.add(MapEntry(
        'files',
        MultipartFile.fromBytes(
          f.bytes,
          filename: f.filename,
          contentType: DioMediaType.parse(f.mimeType),
        ),
      ));
    }
    final resp = await _dio.post<List<dynamic>>(
      '/admin/media/upload',
      data: formData,
      queryParameters: {if (folderId != null) 'folder_id': folderId},
      onSendProgress: onProgress,
    );
    return (resp.data ?? [])
        .map((e) => MediaFileModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> delete(String id) async {
    await _dio.delete<void>('/admin/media/$id');
  }
}

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepository(ref.watch(apiDioProvider));
});
