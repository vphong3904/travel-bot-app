// lib/admin/web/screens/media_screen.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../shared/data/media_repository.dart';
import '../../shared/models/media_file_model.dart';
import '../../shared/providers/media_provider.dart';

class MediaScreen extends ConsumerStatefulWidget {
  const MediaScreen({super.key});

  @override
  ConsumerState<MediaScreen> createState() =>
      _MediaScreenState();
}

class _MediaScreenState extends ConsumerState<MediaScreen> {
  double? _uploadProgress;

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(mediaFilterProvider);
    final listAsync = ref.watch(mediaListProvider(filter));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Media Management',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Quản lý ảnh và file đã tải lên',
                    style: TextStyle(
                        color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _pickAndUpload,
                icon: const Icon(Icons.upload, size: 18),
                label: const Text('Tải ảnh lên'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Upload progress
          if (_uploadProgress != null) ...[
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: Colors.grey.shade200,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${((_uploadProgress ?? 0) * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          _DropZoneHint(onTap: _pickAndUpload),
          const SizedBox(height: 20),

          // Grid
          Expanded(
            child: listAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Lỗi: $e')),
              data: (data) => data.items.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Chưa có ảnh nào',
                            style:
                                TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: _MediaGrid(
                            items: data.items,
                          ),
                        ),
                        _Pagination(
                          page: filter.page,
                          total: data.total,
                          pageSize: 24,
                          onPageChange: (p) => ref
                              .read(mediaFilterProvider
                                  .notifier)
                              .update(
                                  (s) => s.copyWith(page: p)),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() => _uploadProgress = 0.0);
    try {
      await ref.read(mediaRepositoryProvider).upload(
        bytes: file.bytes!,
        filename: file.name,
        mimeType: _mimeFromExt(file.extension ?? 'jpg'),
        onProgress: (sent, total) {
          setState(() => _uploadProgress = sent / total);
        },
      );
      ref.invalidate(mediaListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tải lên thành công')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploadProgress = null);
    }
  }

  String _mimeFromExt(String ext) => switch (ext.toLowerCase()) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };
}

// ── Grid ──────────────────────────────────────────────────────────────────────

class _MediaGrid extends ConsumerWidget {
  final List<MediaFileModel> items;
  const _MediaGrid({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _MediaTile(
          item: item,
          onDeleted: () => ref.invalidate(mediaListProvider),
        );
      },
    );
  }
}

class _MediaTile extends ConsumerStatefulWidget {
  final MediaFileModel item;
  final VoidCallback onDeleted;
  const _MediaTile(
      {required this.item, required this.onDeleted});

  @override
  ConsumerState<_MediaTile> createState() =>
      _MediaTileState();
}

class _MediaTileState extends ConsumerState<_MediaTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => _showDetail(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.item.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image,
                      color: Colors.grey),
                ),
              ),
              if (_hovered)
                Container(
                  color: Colors.black
                      .withValues(alpha: 0.55),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.originalName ??
                            widget.item.filename,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            widget.item.sizeDisplay,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () =>
                                _delete(context),
                            child: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) =>
          _MediaDetailDialog(item: widget.item),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa ảnh?'),
        content: Text(
            'Bạn chắc chắn muốn xóa "${widget.item.originalName}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Huỷ')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(mediaRepositoryProvider)
        .delete(widget.item.id);
    widget.onDeleted();
  }
}

// ── Detail dialog ─────────────────────────────────────────────────────────────

class _MediaDetailDialog extends StatelessWidget {
  final MediaFileModel item;
  const _MediaDetailDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12)),
              child: Image.network(
                item.thumbnailUrl,
                height: 320,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    item.originalName ?? item.filename,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  _metaRow('Kích thước', item.sizeDisplay),
                  _metaRow(
                    'Dimensions',
                    item.width != null
                        ? '${item.width} × ${item.height} px'
                        : '—',
                  ),
                  _metaRow(
                    'Ngày tải lên',
                    DateFormat('dd/MM/yyyy HH:mm').format(
                        DateTime.parse(item.createdAt)),
                  ),
                  if (item.uploadedByName != null)
                    _metaRow(
                        'Tải lên bởi', item.uploadedByName!),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 13),
              ),
            ),
            Text(value,
                style: const TextStyle(fontSize: 13)),
          ],
        ),
      );
}

// ── Drop zone hint ────────────────────────────────────────────────────────────

class _DropZoneHint extends StatelessWidget {
  final VoidCallback onTap;
  const _DropZoneHint({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_upload_outlined,
                size: 32, color: Colors.blue.shade400),
            const SizedBox(height: 6),
            Text(
              'Click để chọn ảnh',
              style: TextStyle(
                  color: Colors.blue.shade700, fontSize: 13),
            ),
            Text(
              'JPG, PNG, WebP — tối đa 5MB',
              style: TextStyle(
                  color: Colors.blue.shade400, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pagination ────────────────────────────────────────────────────────────────

class _Pagination extends StatelessWidget {
  final int page, total, pageSize;
  final ValueChanged<int> onPageChange;

  const _Pagination({
    required this.page,
    required this.total,
    required this.pageSize,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = (total / pageSize).ceil();
    if (totalPages <= 1) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed:
                page > 1 ? () => onPageChange(page - 1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('Trang $page / $totalPages',
              style: const TextStyle(fontSize: 13)),
          IconButton(
            onPressed: page < totalPages
                ? () => onPageChange(page + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
