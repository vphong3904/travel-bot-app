// lib/admin/shared/models/city_mapping_models.dart

class CityMapping {
  final String oldProvince;
  final String mappedSlug;
  final bool folderExists;
  final String? suggestion;

  const CityMapping({
    required this.oldProvince,
    required this.mappedSlug,
    required this.folderExists,
    this.suggestion,
  });

  factory CityMapping.fromJson(Map<String, dynamic> j) =>
      CityMapping(
        oldProvince: j['old_province'] as String,
        mappedSlug: j['mapped_slug'] as String,
        folderExists: j['folder_exists'] as bool,
        suggestion: j['suggestion'] as String?,
      );
}
