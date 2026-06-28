// lib/admin/shared/providers/content_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/content_repository.dart';
import '../models/content_item.dart';

class ContentFilter {
  final String citySlug;
  final String status;
  final int page;

  const ContentFilter({
    this.citySlug = '',
    this.status = '',
    this.page = 1,
  });

  ContentFilter copyWith({
    String? citySlug,
    String? status,
    int? page,
  }) =>
      ContentFilter(
        citySlug: citySlug ?? this.citySlug,
        status: status ?? this.status,
        page: page ?? this.page,
      );
}

final contentFilterFamily =
    StateProvider.family<ContentFilter, String>(
  (ref, contentType) => const ContentFilter(),
);

final contentListFamily = FutureProvider.autoDispose
    .family<({List<ContentItem> items, int total}),
        ({String contentType, ContentFilter filter})>(
  (ref, arg) async {
    final repo = ref.watch(contentRepositoryProvider);
    if (arg.filter.citySlug.isEmpty) {
      return (items: <ContentItem>[], total: 0);
    }
    return repo.list(
      contentType: arg.contentType,
      citySlug: arg.filter.citySlug,
      status: arg.filter.status,
      page: arg.filter.page,
    );
  },
);

final validCitySlugsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  return ref.watch(contentRepositoryProvider).fetchValidSlugs();
});
