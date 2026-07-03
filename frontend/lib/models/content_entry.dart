// lib/models/content_entry.dart
//
// Content do Admin quản lý (content_items) mà mobile đọc qua API public
// /content/{type}. Tách khỏi Service (id:int) vì content_items id là UUID (String).

class ContentEntry {
  final String id;
  final String? citySlug;
  final String? imageUrl;
  final Map<String, dynamic> data;

  const ContentEntry({
    required this.id,
    this.citySlug,
    this.imageUrl,
    required this.data,
  });

  factory ContentEntry.fromJson(Map<String, dynamic> j) {
    final data = Map<String, dynamic>.from(j['data'] as Map? ?? {});
    return ContentEntry(
      id: j['id']?.toString() ?? '',
      citySlug: j['city_slug'] as String?,
      imageUrl: (j['image_url'] ?? data['image_url']) as String?,
      data: data,
    );
  }

  /// Tên hiển thị (mọi content_type đều có 'name' trong data).
  String get name => (data['name'] ?? '').toString();

  String? getString(String key) => data[key]?.toString();
}
