// lib/admin/shared/models/media_file_model.dart

class MediaFileModel {
  final String id;
  final String filename;
  final String? originalName;
  final String filePath;
  final int? fileSize;
  final String? mimeType;
  final int? width;
  final int? height;
  final List<String> tags;
  final String createdAt;
  final String? uploadedByName;

  const MediaFileModel({
    required this.id,
    required this.filename,
    this.originalName,
    required this.filePath,
    this.fileSize,
    this.mimeType,
    this.width,
    this.height,
    required this.tags,
    required this.createdAt,
    this.uploadedByName,
  });

  factory MediaFileModel.fromJson(Map<String, dynamic> j) =>
      MediaFileModel(
        id: j['id'] as String,
        filename: j['filename'] as String,
        originalName: j['original_name'] as String?,
        filePath: j['file_path'] as String,
        fileSize: j['file_size'] as int?,
        mimeType: j['mime_type'] as String?,
        width: j['width'] as int?,
        height: j['height'] as int?,
        tags: (j['tags'] as List?)?.cast<String>() ?? [],
        createdAt: j['created_at'] as String,
        uploadedByName: j['uploaded_by_name'] as String?,
      );

  String get thumbnailUrl => '/uploads/$filename';

  String get sizeDisplay {
    if (fileSize == null) return '—';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize! / 1024 / 1024).toStringAsFixed(1)} MB';
  }
}
