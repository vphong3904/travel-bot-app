// lib/admin/shared/models/content_item.dart

class ContentItem {
  final String id;
  final String status;
  final bool isDeleted;
  final String createdAt;
  final String? updatedAt;
  final Map<String, dynamic> data;

  const ContentItem({
    required this.id,
    required this.status,
    required this.isDeleted,
    required this.createdAt,
    this.updatedAt,
    required this.data,
  });

  factory ContentItem.fromJson(Map<String, dynamic> j) {
    final extra = Map<String, dynamic>.from(j)
      ..removeWhere((k, _) => const {
            'id',
            'status',
            'is_deleted',
            'created_at',
            'updated_at',
          }.contains(k));
    return ContentItem(
      id: j['id'] as String,
      status: j['status'] as String? ?? 'draft',
      isDeleted: j['is_deleted'] as bool? ?? false,
      createdAt: j['created_at'] as String? ?? '',
      updatedAt: j['updated_at'] as String?,
      data: extra,
    );
  }

  String? getString(String key) => data[key] as String?;
}
