// lib/admin/shared/providers/feedback_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/feedback_repository.dart';
import '../models/feedback_item.dart';

class FeedbackFilter {
  final String type;
  final String tab;
  final String category;
  final String intent;
  final int page;

  const FeedbackFilter({
    this.type = '',
    this.tab = 'all',
    this.category = '',
    this.intent = '',
    this.page = 1,
  });

  FeedbackFilter copyWith({
    String? type,
    String? tab,
    String? category,
    String? intent,
    int? page,
  }) =>
      FeedbackFilter(
        type: type ?? this.type,
        tab: tab ?? this.tab,
        category: category ?? this.category,
        intent: intent ?? this.intent,
        page: page ?? this.page,
      );
}

// autoDispose: reset filter khi rời màn hình — xem giải thích ở
// users_provider.dart (usersFilterProvider), cùng bug.
final feedbackFilterProvider =
    StateProvider.autoDispose<FeedbackFilter>((ref) => const FeedbackFilter());

final feedbackListProvider = FutureProvider.autoDispose
    .family<({List<FeedbackItem> items, int total}), FeedbackFilter>(
  (ref, filter) {
    final repo = ref.watch(feedbackRepositoryProvider);
    String resolvedType = filter.type;
    if (filter.tab == 'positive') resolvedType = 'positive';
    if (filter.tab == 'negative') resolvedType = 'negative';
    return repo.list(
      type: resolvedType,
      category: filter.category,
      intent: filter.intent,
      page: filter.page,
    );
  },
);

final feedbackStatsProvider =
    FutureProvider.autoDispose<FeedbackStats>(
  (ref) =>
      ref.watch(feedbackRepositoryProvider).fetchStats(),
);
