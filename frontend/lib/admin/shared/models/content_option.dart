// lib/admin/shared/models/content_option.dart

class ContentOption {
  final String id;
  final String contentType;
  final String field;
  final String code;
  final String label;
  final int sortOrder;
  final bool isActive;

  const ContentOption({
    required this.id,
    required this.contentType,
    required this.field,
    required this.code,
    required this.label,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory ContentOption.fromJson(Map<String, dynamic> j) => ContentOption(
        id: j['id'] as String,
        contentType: j['content_type'] as String,
        field: j['field'] as String,
        code: j['code'] as String,
        label: j['label'] as String,
        sortOrder: j['sort_order'] as int? ?? 0,
        isActive: j['is_active'] as bool? ?? true,
      );
}
