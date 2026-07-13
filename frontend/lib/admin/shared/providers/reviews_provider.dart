// lib/admin/shared/providers/reviews_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/reviews_repository.dart';
import '../models/review_item.dart';

class ReviewsFilter {
  final String search;
  final int? rating;
  final int page;

  const ReviewsFilter({this.search = '', this.rating, this.page = 1});

  ReviewsFilter copyWith({String? search, int? rating, bool clearRating = false, int? page}) =>
      ReviewsFilter(
        search: search ?? this.search,
        rating: clearRating ? null : (rating ?? this.rating),
        page: page ?? this.page,
      );

  @override
  bool operator ==(Object other) =>
      other is ReviewsFilter &&
      search == other.search &&
      rating == other.rating &&
      page == other.page;

  @override
  int get hashCode => Object.hash(search, rating, page);
}

// autoDispose: reset filter khi rời màn hình (cùng lý do các filter provider
// khác trong admin — xem usersFilterProvider).
final reviewsFilterProvider =
    StateProvider.autoDispose<ReviewsFilter>((ref) => const ReviewsFilter());

final reviewsListProvider = FutureProvider.autoDispose
    .family<({List<ReviewItem> items, int total}), ReviewsFilter>(
  (ref, filter) async {
    final repo = ref.watch(reviewsRepositoryProvider);
    return repo.listReviews(
      search: filter.search,
      rating: filter.rating,
      page: filter.page,
    );
  },
);
