// lib/admin/web/widgets/media_picker_dialog.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/data/media_repository.dart';
import '../../shared/models/media_file_model.dart';
import '../../shared/providers/media_provider.dart';

/// Dialog chọn ảnh từ thư viện Media. Mặc định mở thư mục đang chọn gần nhất
/// (currentFolderProvider). Có thể tải ảnh mới (nhiều ảnh) vào thư mục hiện tại.
/// Trả về `file_path` (dạng /uploads/xxx) của ảnh được chọn qua Navigator.pop.
class MediaPickerDialog extends ConsumerStatefulWidget {
  const MediaPickerDialog({super.key});

  @override
  ConsumerState<MediaPickerDialog> createState() => _MediaPickerDialogState();
}

class _MediaPickerDialogState extends ConsumerState<MediaPickerDialog> {
  bool _uploading = false;

  String _mimeFromExt(String ext) => switch (ext.toLowerCase()) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };

  Future<void> _uploadNew() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final files = result.files
        .where((f) => f.bytes != null)
        .map((f) => (
              bytes: f.bytes!,
              filename: f.name,
              mimeType: _mimeFromExt(f.extension ?? 'jpg'),
            ))
        .toList();
    if (files.isEmpty) return;

    setState(() => _uploading = true);
    try {
      final folderId = ref.read(currentFolderProvider);
      await ref.read(mediaRepositoryProvider).uploadMany(
            files: files,
            folderId: folderId,
          );
      ref.invalidate(mediaListProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi upload: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final folderId = ref.watch(currentFolderProvider);
    final foldersAsync = ref.watch(mediaFoldersProvider);
    final listAsync = ref.watch(mediaListProvider(MediaListKey(folderId, 1)));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 720,
        height: 560,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  const Text('Chọn ảnh',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  // Folder dropdown
                  foldersAsync.maybeWhen(
                    data: (folders) => DropdownButton<String?>(
                      value: folderId,
                      hint: const Text('Tất cả thư mục'),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('Tất cả thư mục')),
                        ...folders.map((f) => DropdownMenuItem(
                              value: f.id,
                              child: Text(f.name,
                                  style: const TextStyle(fontSize: 13)),
                            )),
                      ],
                      onChanged: (v) =>
                          ref.read(currentFolderProvider.notifier).state = v,
                    ),
                    orElse: () => const SizedBox(),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: _uploading ? null : _uploadNew,
                    icon: _uploading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.upload, size: 16),
                    label: const Text('Tải ảnh mới'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: listAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Lỗi: $e')),
                data: (data) => data.items.isEmpty
                    ? const Center(
                        child: Text('Chưa có ảnh nào — bấm "Tải ảnh mới"',
                            style: TextStyle(color: Colors.grey)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: data.items.length,
                        itemBuilder: (_, i) => _PickTile(item: data.items[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickTile extends StatelessWidget {
  final MediaFileModel item;
  const _PickTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, item.filePath),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          item.url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
