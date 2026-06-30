// lib/admin/shared/providers/media_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/media_repository.dart';
import '../models/media_file_model.dart';

/// Toàn bộ thư mục (phẳng) — FE tự dựng cây từ parentId.
final mediaFoldersProvider =
    FutureProvider.autoDispose<List<MediaFolderModel>>(
  (ref) => ref.watch(mediaRepositoryProvider).listFolders(),
);

/// Thư mục đang mở (null = thư mục gốc).
final currentFolderProvider = StateProvider<String?>((ref) => null);

/// Trang hiện tại của lưới ảnh.
final mediaPageProvider = StateProvider.autoDispose<int>((ref) => 1);

/// Khoá truy vấn ảnh: (folderId, page).
class MediaListKey {
  final String? folderId;
  final int page;
  const MediaListKey(this.folderId, this.page);

  @override
  bool operator ==(Object other) =>
      other is MediaListKey &&
      other.folderId == folderId &&
      other.page == page;

  @override
  int get hashCode => Object.hash(folderId, page);
}

final mediaListProvider = FutureProvider.autoDispose
    .family<({List<MediaFileModel> items, int total}), MediaListKey>(
  (ref, key) => ref.watch(mediaRepositoryProvider).list(
        folderId: key.folderId,
        page: key.page,
      ),
);
