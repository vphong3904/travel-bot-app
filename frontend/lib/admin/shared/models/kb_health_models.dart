// lib/admin/shared/models/kb_health_models.dart

class KbHealthFile {
  final bool exists;
  final bool hasData;
  final int? sizeBytes;
  final String? lastModified;

  const KbHealthFile({
    required this.exists,
    required this.hasData,
    this.sizeBytes,
    this.lastModified,
  });

  factory KbHealthFile.fromJson(Map<String, dynamic> j) => KbHealthFile(
        exists: j['exists'] as bool,
        hasData: j['has_data'] as bool,
        sizeBytes: j['size_bytes'] as int?,
        lastModified: j['last_modified'] as String?,
      );
}

class KbHealthCity {
  final String citySlug;
  final int filledCount;
  final int totalCount;
  final int completenessPct;
  final bool hasAnyData;
  final Map<String, KbHealthFile> files;

  const KbHealthCity({
    required this.citySlug,
    required this.filledCount,
    required this.totalCount,
    required this.completenessPct,
    required this.hasAnyData,
    required this.files,
  });

  factory KbHealthCity.fromJson(Map<String, dynamic> j) => KbHealthCity(
        citySlug: j['city_slug'] as String,
        filledCount: j['filled_count'] as int,
        totalCount: j['total_count'] as int,
        completenessPct: j['completeness_pct'] as int,
        hasAnyData: j['has_any_data'] as bool,
        files: (j['files'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(
              k, KbHealthFile.fromJson(v as Map<String, dynamic>)),
        ),
      );
}

class KbHealthSummary {
  final int totalCities;
  final int completeCities;
  final int emptyCities;
  final int avgCompletenessPct;

  const KbHealthSummary({
    required this.totalCities,
    required this.completeCities,
    required this.emptyCities,
    required this.avgCompletenessPct,
  });

  factory KbHealthSummary.fromJson(Map<String, dynamic> j) =>
      KbHealthSummary(
        totalCities: j['total_cities'] as int,
        completeCities: j['complete_cities'] as int,
        emptyCities: j['empty_cities'] as int,
        avgCompletenessPct: j['avg_completeness_pct'] as int,
      );
}

class KbHealthResponse {
  final KbHealthSummary summary;
  final List<String> contentTypes;
  final List<KbHealthCity> cities;

  const KbHealthResponse({
    required this.summary,
    required this.contentTypes,
    required this.cities,
  });

  factory KbHealthResponse.fromJson(Map<String, dynamic> j) =>
      KbHealthResponse(
        summary: KbHealthSummary.fromJson(
            j['summary'] as Map<String, dynamic>),
        contentTypes: (j['content_types'] as List).cast<String>(),
        cities: (j['cities'] as List)
            .map((e) =>
                KbHealthCity.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
