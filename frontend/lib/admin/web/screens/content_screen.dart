// lib/admin/web/screens/content_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/content_item.dart';
import '../../shared/providers/content_provider.dart';
import '../../shared/data/content_repository.dart';
import '../widgets/city_selector.dart';
import '../widgets/content_form_sheet.dart';
import '../widgets/content_status_badge.dart';

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
                      onPressed: filter.citySlug.isEmpty
                          ? null
                          : () => setState(() {
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
                Row(
                  children: [
                    SizedBox(
                      width: 240,
                      child: CitySelector(
                        value: filter.citySlug,
                        onChange: (slug) => ref
                            .read(contentFilterFamily(
                                    widget.contentType)
                                .notifier)
                            .update((s) => s.copyWith(
                                citySlug: slug, page: 1)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: filter.status.isEmpty
                            ? null
                            : filter.status,
                        hint: const Text('Tất cả status'),
                        items: const [
                          DropdownMenuItem(
                              value: null,
                              child: Text('Tất cả')),
                          DropdownMenuItem(
                              value: 'draft',
                              child: Text('Draft')),
                          DropdownMenuItem(
                              value: 'published',
                              child: Text('Published')),
                        ],
                        onChanged: (v) => ref
                            .read(contentFilterFamily(
                                    widget.contentType)
                                .notifier)
                            .update((s) => s.copyWith(
                                status: v ?? '', page: 1)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Table
                Expanded(
                  child: filter.citySlug.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_city_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Chọn thành phố để xem dữ liệu',
                                style: TextStyle(
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : listAsync.when(
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
                                            'Chưa có ${widget.title} nào cho ${filter.citySlug}',
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
                                                                          item.getString(c.fieldKey) ??
                                                                              '—',
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
