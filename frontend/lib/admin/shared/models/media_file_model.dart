// lib/admin/shared/models/media_file_model.dart
import '../providers/dio_provider.dart' show mediaUrl;

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
  final String? folderId;
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
    this.folderId,
    required this.createdAt,
    this.uploadedByName,
  });

  factory MediaFileModel.fromJson(Map<String, dynamic> j) => MediaFileModel(
        id: j['id'] as String,
        filename: j['filename'] as String,
        originalName: j['original_name'] as String?,
        filePath: j['file_path'] as String? ?? '/uploads/${j['filename']}',
        fileSize: j['file_size'] as int?,
        mimeType: j['mime_type'] as String?,
        width: j['width'] as int?,
        height: j['height'] as int?,
        tags: (j['tags'] as List?)?.cast<String>() ?? [],
        folderId: j['folder_id'] as String?,
        createdAt: j['created_at'] as String? ?? DateTime.now().toIso8601String(),
        uploadedByName: j['uploaded_by_name'] as String?,
      );

  /// URL tuyệt đối để hiển thị (Image.network).
  String get url => mediaUrl(filePath);

  String get sizeDisplay {
    if (fileSize == null) return '—';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize! / 1024 / 1024).toStringAsFixed(1)} MB';
  }
}

/// Thư mục trong trình quản lý ảnh (CMS). parentId=null => thư mục gốc.
class MediaFolderModel {
  final String id;
  final String name;
  final String? parentId;
  final int imageCount;
  final String? lastAdded; // ISO time ảnh thêm gần nhất (để sắp xếp)
  final String? createdAt;

  const MediaFolderModel({
    required this.id,
    required this.name,
    this.parentId,
    this.imageCount = 0,
    this.lastAdded,
    this.createdAt,
  });

  factory MediaFolderModel.fromJson(Map<String, dynamic> j) => MediaFolderModel(
        id: j['id'] as String,
        name: j['name'] as String,
        parentId: j['parent_id'] as String?,
        imageCount: j['image_count'] as int? ?? 0,
        lastAdded: j['last_added'] as String?,
        createdAt: j['created_at'] as String?,
      );
}
