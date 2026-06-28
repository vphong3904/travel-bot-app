// lib/admin/shared/providers/media_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/media_repository.dart';
import '../models/media_file_model.dart';

class MediaFilter {
  final String tag;
  final int page;

  const MediaFilter({this.tag = '', this.page = 1});

  MediaFilter copyWith({String? tag, int? page}) =>
      MediaFilter(
          tag: tag ?? this.tag, page: page ?? this.page);
}

final mediaFilterProvider =
    StateProvider<MediaFilter>((ref) => const MediaFilter());

final mediaListProvider = FutureProvider.autoDispose
    .family<({List<MediaFileModel> items, int total}), MediaFilter>(
  (ref, filter) =>
      ref.watch(mediaRepositoryProvider).list(
            tag: filter.tag,
            page: filter.page,
          ),
);
