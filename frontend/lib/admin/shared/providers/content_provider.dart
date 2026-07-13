// lib/admin/shared/providers/content_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/content_repository.dart';
import '../models/content_item.dart';

class ContentFilter {
  final String citySlug;
  final String status;
  final String search;
  final String sort; // newest | oldest | name
  final String dateFrom; // YYYY-MM-DD | ''
  final String dateTo;
  final String field;
  final String value;
  final int page;

  const ContentFilter({
    this.citySlug = '',
    this.status = '',
    this.search = '',
    this.sort = 'newest',
    this.dateFrom = '',
    this.dateTo = '',
    this.field = '',
    this.value = '',
    this.page = 1,
  });

  ContentFilter copyWith({
    String? citySlug,
    String? status,
    String? search,
    String? sort,
    String? dateFrom,
    String? dateTo,
    String? field,
    String? value,
    int? page,
  }) =>
      ContentFilter(
        citySlug: citySlug ?? this.citySlug,
        status: status ?? this.status,
        search: search ?? this.search,
        sort: sort ?? this.sort,
        dateFrom: dateFrom ?? this.dateFrom,
        dateTo: dateTo ?? this.dateTo,
        field: field ?? this.field,
        value: value ?? this.value,
        page: page ?? this.page,
      );
}

// autoDispose: reset filter khi rời màn hình (destinations/hotels/foods/...)
// — xem giải thích ở users_provider.dart (usersFilterProvider), cùng bug.
final contentFilterFamily =
    StateProvider.autoDispose.family<ContentFilter, String>(
  (ref, contentType) => const ContentFilter(),
);

final contentListFamily = FutureProvider.autoDispose
    .family<({List<ContentItem> items, int total}),
        ({String contentType, ContentFilter filter})>(
  (ref, arg) async {
    // Không còn gate bắt buộc city — mặc định xem tất cả.
    final repo = ref.watch(contentRepositoryProvider);
    final f = arg.filter;
    return repo.list(
      contentType: arg.contentType,
      citySlug: f.citySlug,
      status: f.status,
      search: f.search,
      sort: f.sort,
      dateFrom: f.dateFrom,
      dateTo: f.dateTo,
      field: f.field,
      value: f.value,
      page: f.page,
    );
  },
);

/// Danh sách city cho dropdown filter (tên đẹp từ /admin/cities).
final citiesProvider =
    FutureProvider.autoDispose<List<CityOption>>((ref) async {
  return ref.watch(contentRepositoryProvider).fetchCities();
});
