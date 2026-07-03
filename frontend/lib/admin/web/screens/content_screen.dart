// lib/admin/web/screens/content_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/content_item.dart';
import '../../shared/providers/content_provider.dart';
import '../../shared/data/content_repository.dart';
import '../../shared/data/content_option_repository.dart';
import '../../shared/providers/dio_provider.dart';
import '../../shared/content_labels.dart';
import '../widgets/city_selector.dart';
import '../widgets/content_form_sheet.dart';
import '../widgets/content_status_badge.dart';

/// Nhãn hiển thị: ưu tiên DB (taxonomy), fallback từ điển tĩnh; rỗng → '—'.
String labelOf(String? raw, Map<String, String> dbLabels) {
  if (raw == null || raw.trim().isEmpty) return '—';
  return dbLabels[raw] ?? vnLabel(raw);
}

class ContentColumn {
  final String label;
  final String fieldKey;
  final double? width;
  final Widget Function(ContentItem item)? customBuilder;

  const ContentColumn({
    required this.label,
    required this.fieldKey,
    this.width,
    this.customBuilder,
  });
}

class ContentScreen extends ConsumerStatefulWidget {
  final String contentType;
  final String title;
  final List<ContentColumn> columns;
  final List<ContentFormField> formFields;

  const ContentScreen({
    super.key,
    required this.contentType,
    required this.title,
    required this.columns,
    required this.formFields,
  });

  @override
  ConsumerState<ContentScreen> createState() =>
      _ContentScreenState();
}

class _ContentScreenState extends ConsumerState<ContentScreen> {
  ContentItem? _selectedItem;
  bool _formOpen = false;

  @override
  Widget build(BuildContext context) {
    final filter =
        ref.watch(contentFilterFamily(widget.contentType));
    final listAsync = ref.watch(contentListFamily(
        (contentType: widget.contentType, filter: filter)));
    final dbLabels = <String, String>{
      for (final o in ref
              .watch(contentOptionsProvider(widget.contentType))
              .valueOrNull ??
          const [])
        o.code: o.label
    };

    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        listAsync.when(
                          data: (d) => Text(
                            '${d.total} mục',
                            style: const TextStyle(
                                color: Colors.grey),
                          ),
                          loading: () => const SizedBox(),
                          error: (_, __) => const SizedBox(),
                        ),
                      ],
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => setState(() {
                        _selectedItem = null;
                        _formOpen = true;
                      }),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Thêm mới'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Filters
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      child: CitySelector(
                        value: filter.citySlug,
                        onChange: (slug) => _update(
                            (s) => s.copyWith(citySlug: slug, page: 1)),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Tìm theo tên...',
                          prefixIcon: Icon(Icons.search, size: 18),
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) =>
                            _update((s) => s.copyWith(search: v, page: 1)),
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: filter.status.isEmpty ? null : filter.status,
                        hint: const Text('Tất cả status'),
                        items: const [
                          DropdownMenuItem(
                              value: null, child: Text('Tất cả status')),
                          DropdownMenuItem(
                              value: 'draft', child: Text('Draft')),
                          DropdownMenuItem(
                              value: 'published', child: Text('Published')),
                        ],
                        onChanged: (v) => _update(
                            (s) => s.copyWith(status: v ?? '', page: 1)),
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: filter.sort,
                        items: const [
                          DropdownMenuItem(
                              value: 'newest', child: Text('Mới nhất')),
                          DropdownMenuItem(
                              value: 'oldest', child: Text('Cũ nhất')),
                          DropdownMenuItem(
                              value: 'name', child: Text('Tên A→Z')),
                        ],
                        onChanged: (v) => _update(
                            (s) => s.copyWith(sort: v ?? 'newest', page: 1)),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _pickDateRange,
                      icon: const Icon(Icons.date_range, size: 16),
                      label: Text(filter.dateFrom.isEmpty
                          ? 'Ngày'
                          : '${filter.dateFrom} → ${filter.dateTo}'),
                    ),
                    SizedBox(
                      width: 160,
                      child: DropdownButtonFormField<String>(
                        initialValue:
                            filter.field.isEmpty ? null : filter.field,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          hintText: 'Lọc theo field',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        items: widget.columns
                            .map((c) => DropdownMenuItem(
                                  value: c.fieldKey,
                                  child: Text(c.label,
                                      style: const TextStyle(fontSize: 13),
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (v) => _update(
                            (s) => s.copyWith(field: v ?? '', page: 1)),
                      ),
                    ),
                    if (filter.field.isNotEmpty)
                      SizedBox(
                        width: 140,
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Giá trị...',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) =>
                              _update((s) => s.copyWith(value: v, page: 1)),
                        ),
                      ),
                    if (_hasActiveFilter(filter))
                      TextButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Xoá lọc'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Table
                Expanded(
                  child: listAsync.when(
                          loading: () => const Center(
                              child:
                                  CircularProgressIndicator()),
                          error: (e, _) =>
                              Center(child: Text('Lỗi: $e')),
                          data: (data) =>
                              data.items.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [
                                          const Icon(
                                              Icons.inbox,
                                              size: 48,
                                              color:
                                                  Colors.grey),
                                          const SizedBox(
                                              height: 8),
                                          Text(
                                            'Chưa có ${widget.title} nào',
                                            style: const TextStyle(
                                                color: Colors
                                                    .grey),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        Expanded(
                                          child:
                                              SingleChildScrollView(
                                            child: DataTable(
                                              headingRowColor:
                                                  WidgetStateProperty
                                                      .all(Colors
                                                          .grey
                                                          .shade50),
                                              columns: [
                                                const DataColumn(
                                                    label: Text('Ảnh')),
                                                ...widget.columns
                                                    .map(
                                                        (c) =>
                                                            DataColumn(
                                                              label:
                                                                  SizedBox(
                                                                width:
                                                                    c.width,
                                                                child:
                                                                    Text(c.label),
                                                              ),
                                                            )),
                                                const DataColumn(
                                                    label: Text(
                                                        'Status')),
                                                const DataColumn(
                                                    label:
                                                        Text('')),
                                              ],
                                              rows: data.items
                                                  .map((item) =>
                                                      DataRow(
                                                          cells: [
                                                        DataCell(_Thumb(
                                                            url:
                                                                item.imageUrl)),
                                                        ...widget
                                                            .columns
                                                            .map((c) =>
                                                                DataCell(c.customBuilder !=
                                                                        null
                                                                    ? c.customBuilder!(item)
                                                                    : SizedBox(
                                                                        width:
                                                                            c.width,
                                                                        child:
                                                                            Text(
                                                                          labelOf(item.getString(c.fieldKey), dbLabels),
                                                                          style: const TextStyle(fontSize: 13),
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ))),
                                                        DataCell(
                                                            ContentStatusBadge(
                                                                status: item
                                                                    .status)),
                                                        DataCell(Row(
                                                          mainAxisSize:
                                                              MainAxisSize
                                                                  .min,
                                                          children: [
                                                            if (item.status ==
                                                                'draft')
                                                              TextButton(
                                                                onPressed: () =>
                                                                    _publishItem(
                                                                        item),
                                                                child:
                                                                    const Text(
                                                                        'Publish'),
                                                              ),
                                                            TextButton(
                                                              onPressed:
                                                                  () =>
                                                                      setState(
                                                                          () {
                                                                        _selectedItem =
                                                                            item;
                                                                        _formOpen =
                                                                            true;
                                                                      }),
                                                              child:
                                                                  const Text(
                                                                      'Sửa'),
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                  Icons
                                                                      .delete_outline,
                                                                  size:
                                                                      18,
                                                                  color: Colors
                                                                      .red),
                                                              onPressed: () =>
                                                                  _deleteItem(
                                                                      item),
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              visualDensity:
                                                                  VisualDensity
                                                                      .compact,
                                                            ),
                                                          ],
                                                        )),
                                                      ]))
                                                  .toList(),
                                            ),
                                          ),
                                        ),
                                        _Pagination(
                                          page: filter.page,
                                          total: data.total,
                                          pageSize: 20,
                                          onPageChange: (p) =>
                                              ref
                                                  .read(contentFilterFamily(
                                                          widget
                                                              .contentType)
                                                      .notifier)
                                                  .update((s) =>
                                                      s.copyWith(
                                                          page: p)),
                                        ),
                                      ],
                                    ),
                        ),
                ),
              ],
            ),
          ),
        ),

        // Side panel
        if (_formOpen)
          ContentFormSheet(
            open: _formOpen,
            item: _selectedItem,
            contentType: widget.contentType,
            citySlug: ref
                .read(contentFilterFamily(widget.contentType))
                .citySlug,
            formFields: widget.formFields,
            onClose: () => setState(() => _formOpen = false),
            onSuccess: () {
              setState(() => _formOpen = false);
              ref.invalidate(contentListFamily);
            },
          ),
      ],
    );
  }

  void _update(ContentFilter Function(ContentFilter) fn) => ref
      .read(contentFilterFamily(widget.contentType).notifier)
      .update(fn);

  bool _hasActiveFilter(ContentFilter f) =>
      f.citySlug.isNotEmpty ||
      f.status.isNotEmpty ||
      f.search.isNotEmpty ||
      f.dateFrom.isNotEmpty ||
      f.field.isNotEmpty ||
      f.sort != 'newest';

  void _clearFilters() => ref
      .read(contentFilterFamily(widget.contentType).notifier)
      .state = const ContentFilter();

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
    );
    if (picked == null) return;
    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    _update((s) => s.copyWith(
        dateFrom: fmt(picked.start), dateTo: fmt(picked.end), page: 1));
  }

  Future<void> _publishItem(ContentItem item) async {
    final filter =
        ref.read(contentFilterFamily(widget.contentType));
    await ref
        .read(contentRepositoryProvider)
        .publish(widget.contentType, filter.citySlug, item.id);
    ref.invalidate(contentListFamily);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Đã publish! Embedding job đang tạo...'),
        ),
      );
    }
  }

  Future<void> _deleteItem(ContentItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá mục này?'),
        content:
            const Text('Mục sẽ bị deactivate (soft delete)'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Huỷ')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final filter =
        ref.read(contentFilterFamily(widget.contentType));
    await ref
        .read(contentRepositoryProvider)
        .delete(widget.contentType, filter.citySlug, item.id);
    ref.invalidate(contentListFamily);
  }
}

class _Thumb extends StatelessWidget {
  final String? url;
  const _Thumb({this.url});

  @override
  Widget build(BuildContext context) {
    final resolved = mediaUrl(url ?? '');
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 40,
        height: 40,
        child: resolved.isEmpty
            ? Container(
                color: Colors.grey.shade100,
                child: const Icon(Icons.image_outlined,
                    size: 18, color: Colors.grey),
              )
            : Image.network(
                resolved,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.broken_image,
                      size: 18, color: Colors.grey),
                ),
              ),
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  final int page;
  final int total;
  final int pageSize;
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
