// lib/admin/web/screens/media_screen.dart
//
// Trình quản lý ảnh dạng CMS:
//  - Cây thư mục: tạo / đổi tên / xoá thư mục, tạo thư mục con.
//  - Mở thư mục → xem ảnh bên trong; nút "Thêm ảnh" multi-select upload.
//  - Thư mục sắp xếp theo lần thêm ảnh gần nhất (mới cập nhật lên đầu).
import 'dart:typed_data';
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
  ConsumerState<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends ConsumerState<MediaScreen> {
  double? _uploadProgress;

  @override
  Widget build(BuildContext context) {
    final currentFolder = ref.watch(currentFolderProvider);
    final page = ref.watch(mediaPageProvider);
    final foldersAsync = ref.watch(mediaFoldersProvider);
    final listAsync =
        ref.watch(mediaListProvider(MediaListKey(currentFolder, page)));

    final allFolders = foldersAsync.maybeWhen(
      data: (f) => f,
      orElse: () => const <MediaFolderModel>[],
    );
    // Thư mục con của thư mục hiện tại, sắp xếp theo lần thêm ảnh gần nhất.
    final children = allFolders
        .where((f) => f.parentId == currentFolder)
        .toList()
      ..sort((a, b) => (b.lastAdded ?? b.createdAt ?? '')
          .compareTo(a.lastAdded ?? a.createdAt ?? ''));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            onCreateFolder: () => _createFolder(currentFolder),
            onUpload: _pickAndUpload,
          ),
          const SizedBox(height: 12),
          _Breadcrumb(
            folders: allFolders,
            currentId: currentFolder,
            onNavigate: (id) {
              ref.read(currentFolderProvider.notifier).state = id;
              ref.read(mediaPageProvider.notifier).state = 1;
            },
          ),
          const SizedBox(height: 16),

          if (_uploadProgress != null) ...[
            Row(children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: Colors.grey.shade200,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Text('${((_uploadProgress ?? 0) * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12)),
            ]),
            const SizedBox(height: 16),
          ],

          Expanded(
            child: foldersAsync.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      // ── Thư mục con ──
                      if (children.isNotEmpty) ...[
                        const _SectionLabel('Thư mục'),
                        const SizedBox(height: 8),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 240,
                            mainAxisExtent: 84,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: children.length,
                          itemBuilder: (_, i) => _FolderTile(
                            folder: children[i],
                            isNewest: i == 0 && children[i].lastAdded != null,
                            onOpen: () {
                              ref.read(currentFolderProvider.notifier).state =
                                  children[i].id;
                              ref.read(mediaPageProvider.notifier).state = 1;
                            },
                            onRename: () => _renameFolder(children[i]),
                            onCreateSub: () => _createFolder(children[i].id),
                            onDelete: () => _deleteFolder(children[i]),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ── Ảnh trong thư mục ──
                      const _SectionLabel('Ảnh'),
                      const SizedBox(height: 8),
                      listAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text('Lỗi tải ảnh: $e'),
                        ),
                        data: (data) {
                          if (data.items.isEmpty) {
                            return _EmptyImages(onUpload: _pickAndUpload);
                          }
                          return Column(children: [
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                childAspectRatio: 1,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: data.items.length,
                              itemBuilder: (_, i) => _MediaTile(
                                item: data.items[i],
                                onDeleted: _refresh,
                              ),
                            ),
                            _Pagination(
                              page: page,
                              total: data.total,
                              pageSize: 24,
                              onPageChange: (p) => ref
                                  .read(mediaPageProvider.notifier)
                                  .state = p,
                            ),
                          ]);
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _refresh() {
    ref.invalidate(mediaListProvider);
    ref.invalidate(mediaFoldersProvider);
  }

  // ── Folder actions ───────────────────────────────────────────────────────

  Future<void> _createFolder(String? parentId) async {
    final name = await _promptName(context,
        title: parentId == null ? 'Tạo thư mục' : 'Tạo thư mục con');
    if (name == null || name.isEmpty) return;
    try {
      await ref
          .read(mediaRepositoryProvider)
          .createFolder(name: name, parentId: parentId);
      ref.invalidate(mediaFoldersProvider);
      _toast('Đã tạo thư mục "$name"');
    } catch (e) {
      _toast('Lỗi: $e');
    }
  }

  Future<void> _renameFolder(MediaFolderModel folder) async {
    final name = await _promptName(context,
        title: 'Đổi tên thư mục', initial: folder.name);
    if (name == null || name.isEmpty || name == folder.name) return;
    try {
      await ref.read(mediaRepositoryProvider).renameFolder(folder.id, name);
      ref.invalidate(mediaFoldersProvider);
      _toast('Đã đổi tên thư mục');
    } catch (e) {
      _toast('Lỗi: $e');
    }
  }

  Future<void> _deleteFolder(MediaFolderModel folder) async {
    final ok = await _confirm(context,
        title: 'Xoá thư mục?',
        message:
            'Xoá "${folder.name}" và các thư mục con. Ảnh bên trong sẽ được giữ lại (chuyển về chưa phân loại).');
    if (!ok) return;
    try {
      await ref.read(mediaRepositoryProvider).deleteFolder(folder.id);
      if (ref.read(currentFolderProvider) == folder.id) {
        ref.read(currentFolderProvider.notifier).state = folder.parentId;
      }
      _refresh();
      _toast('Đã xoá thư mục');
    } catch (e) {
      _toast('Lỗi: $e');
    }
  }

  // ── Upload ───────────────────────────────────────────────────────────────

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final files = <({Uint8List bytes, String filename, String mimeType})>[];
    for (final f in result.files) {
      if (f.bytes == null) continue;
      files.add((
        bytes: f.bytes!,
        filename: f.name,
        mimeType: _mimeFromExt(f.extension ?? 'jpg'),
      ));
    }
    if (files.isEmpty) return;

    setState(() => _uploadProgress = 0.0);
    try {
      await ref.read(mediaRepositoryProvider).uploadMany(
            files: files,
            folderId: ref.read(currentFolderProvider),
            onProgress: (sent, total) {
              if (total > 0) setState(() => _uploadProgress = sent / total);
            },
          );
      _refresh();
      _toast('Đã tải lên ${files.length} ảnh');
    } catch (e) {
      _toast('Lỗi: $e');
    } finally {
      if (mounted) setState(() => _uploadProgress = null);
    }
  }

  String _mimeFromExt(String ext) => switch (ext.toLowerCase()) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ── Dialog helpers ─────────────────────────────────────────────────────────────

Future<String?> _promptName(BuildContext context,
    {required String title, String initial = ''}) {
  final ctrl = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Tên thư mục',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => Navigator.pop(ctx, ctrl.text.trim()),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Lưu')),
      ],
    ),
  );
}

Future<bool> _confirm(BuildContext context,
    {required String title, required String message}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ')),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Xoá'),
        ),
      ],
    ),
  );
  return r ?? false;
}

// ── Header ──────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onCreateFolder;
  final VoidCallback onUpload;
  const _Header({required this.onCreateFolder, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quản lý ảnh',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text('Thư mục ảnh cho nội dung (CMS)',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
      const Spacer(),
      OutlinedButton.icon(
        onPressed: onCreateFolder,
        icon: const Icon(Icons.create_new_folder_outlined, size: 18),
        label: const Text('Tạo thư mục'),
      ),
      const SizedBox(width: 12),
      FilledButton.icon(
        onPressed: onUpload,
        icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
        label: const Text('Thêm ảnh'),
      ),
    ]);
  }
}

// ── Breadcrumb ────────────────────────────────────────────────────────────────

class _Breadcrumb extends StatelessWidget {
  final List<MediaFolderModel> folders;
  final String? currentId;
  final ValueChanged<String?> onNavigate;

  const _Breadcrumb({
    required this.folders,
    required this.currentId,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    // Dựng đường dẫn từ gốc tới thư mục hiện tại.
    final byId = {for (final f in folders) f.id: f};
    final trail = <MediaFolderModel>[];
    var cursor = currentId;
    while (cursor != null && byId[cursor] != null) {
      final f = byId[cursor]!;
      trail.insert(0, f);
      cursor = f.parentId;
    }

    final crumbs = <Widget>[
      _crumb(context, 'Tất cả thư mục', () => onNavigate(null),
          isLast: trail.isEmpty),
    ];
    for (var i = 0; i < trail.length; i++) {
      crumbs.add(const Icon(Icons.chevron_right, size: 16, color: Colors.grey));
      crumbs.add(_crumb(context, trail[i].name, () => onNavigate(trail[i].id),
          isLast: i == trail.length - 1));
    }

    return Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: crumbs);
  }

  Widget _crumb(BuildContext context, String label, VoidCallback onTap,
      {required bool isLast}) {
    return InkWell(
      onTap: isLast ? null : onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
            color: isLast
                ? null
                : Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
            letterSpacing: 0.5),
      );
}

// ── Folder tile ───────────────────────────────────────────────────────────────

class _FolderTile extends StatelessWidget {
  final MediaFolderModel folder;
  final bool isNewest;
  final VoidCallback onOpen, onRename, onCreateSub, onDelete;

  const _FolderTile({
    required this.folder,
    required this.isNewest,
    required this.onOpen,
    required this.onRename,
    required this.onCreateSub,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(children: [
            Icon(Icons.folder, color: Colors.amber.shade600, size: 32),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(folder.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                    if (isNewest) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('Mới',
                            style: TextStyle(
                                fontSize: 10, color: Colors.green.shade700)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 2),
                  Text('${folder.imageCount} ảnh',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18),
              onSelected: (v) {
                switch (v) {
                  case 'open':
                    onOpen();
                  case 'sub':
                    onCreateSub();
                  case 'rename':
                    onRename();
                  case 'delete':
                    onDelete();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'open', child: Text('Mở')),
                PopupMenuItem(value: 'sub', child: Text('Tạo thư mục con')),
                PopupMenuItem(value: 'rename', child: Text('Đổi tên')),
                PopupMenuItem(value: 'delete', child: Text('Xoá')),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Media tile ────────────────────────────────────────────────────────────────

class _MediaTile extends ConsumerStatefulWidget {
  final MediaFileModel item;
  final VoidCallback onDeleted;
  const _MediaTile({required this.item, required this.onDeleted});

  @override
  ConsumerState<_MediaTile> createState() => _MediaTileState();
}

class _MediaTileState extends ConsumerState<_MediaTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => showDialog(
          context: context,
          builder: (_) => _MediaDetailDialog(item: widget.item),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(fit: StackFit.expand, children: [
            Image.network(
              widget.item.url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
            if (_hovered)
              Container(
                color: Colors.black.withValues(alpha: 0.55),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.originalName ?? widget.item.filename,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text(widget.item.sizeDisplay,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 10)),
                      const Spacer(),
                      GestureDetector(
                        onTap: _delete,
                        child: const Icon(Icons.delete_outline,
                            size: 18, color: Colors.redAccent),
                      ),
                    ]),
                  ],
                ),
              ),
          ]),
        ),
      ),
    );
  }

  Future<void> _delete() async {
    final ok = await _confirm(context,
        title: 'Xoá ảnh?',
        message:
            'Xoá "${widget.item.originalName ?? widget.item.filename}"?');
    if (!ok) return;
    await ref.read(mediaRepositoryProvider).delete(widget.item.id);
    widget.onDeleted();
  }
}

class _MediaDetailDialog extends StatelessWidget {
  final MediaFileModel item;
  const _MediaDetailDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 600,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(item.url,
                height: 320, width: double.infinity, fit: BoxFit.contain),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.originalName ?? item.filename,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                SelectableText(item.url,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                const SizedBox(height: 12),
                _metaRow('Kích thước', item.sizeDisplay),
                _metaRow(
                    'Dimensions',
                    item.width != null
                        ? '${item.width} × ${item.height} px'
                        : '—'),
                _metaRow(
                    'Ngày tải lên',
                    DateFormat('dd/MM/yyyy HH:mm')
                        .format(DateTime.parse(item.createdAt).toLocal())),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng')),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _metaRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          SizedBox(
              width: 120,
              child: Text(label,
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(
              child: Text(value, style: const TextStyle(fontSize: 13))),
        ]),
      );
}

// ── Empty / pagination ──────────────────────────────────────────────────────────

class _EmptyImages extends StatelessWidget {
  final VoidCallback onUpload;
  const _EmptyImages({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(children: [
        Icon(Icons.photo_library_outlined,
            size: 40, color: Colors.blue.shade300),
        const SizedBox(height: 8),
        const Text('Chưa có ảnh trong thư mục này',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onUpload,
          icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
          label: const Text('Thêm ảnh'),
        ),
      ]),
    );
  }
}

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
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(
          onPressed: page > 1 ? () => onPageChange(page - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text('Trang $page / $totalPages',
            style: const TextStyle(fontSize: 13)),
        IconButton(
          onPressed: page < totalPages ? () => onPageChange(page + 1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ]),
    );
  }
}
