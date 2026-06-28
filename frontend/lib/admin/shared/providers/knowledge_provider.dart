// lib/admin/shared/providers/knowledge_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/knowledge_repository.dart';
import '../models/knowledge_entry.dart';

class KnowledgeFilter {
  final String search;
  final String category;
  final int page;

  const KnowledgeFilter(
      {this.search = '', this.category = '', this.page = 1});

  KnowledgeFilter copyWith(
          {String? search, String? category, int? page}) =>
      KnowledgeFilter(
        search: search ?? this.search,
        category: category ?? this.category,
        page: page ?? this.page,
      );
}

final knowledgeFilterProvider =
    StateProvider<KnowledgeFilter>((ref) => const KnowledgeFilter());

final knowledgeListProvider = FutureProvider.autoDispose.family<
    ({List<KnowledgeEntry> items, int total}),
    KnowledgeFilter>((ref, filter) async {
  final repo = ref.watch(knowledgeRepositoryProvider);
  return repo.list(
    search: filter.search,
    category: filter.category,
    page: filter.page,
  );
});
