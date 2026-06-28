// lib/admin/web/screens/knowledge_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../shared/models/knowledge_entry.dart';
import '../../shared/providers/knowledge_provider.dart';
import '../../shared/data/knowledge_repository.dart';
import '../widgets/embedding_status_badge.dart';
import '../widgets/knowledge_form_sheet.dart';

class KnowledgeScreen extends ConsumerStatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  ConsumerState<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends ConsumerState<KnowledgeScreen> {
  KnowledgeEntry? _selectedEntry;
  bool _formOpen = false;
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(knowledgeFilterProvider);
    final listAsync = ref.watch(knowledgeListProvider(filter));

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Knowledge Base',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        listAsync.when(
                          data: (d) => Text(
                            '${d.total} entries',
                            style:
                                const TextStyle(color: Colors.grey),
                          ),
                          loading: () => const SizedBox(),
                          error: (_, __) => const SizedBox(),
                        ),
                      ],
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () =>
                          context.go('/knowledge/health'),
                      icon: const Icon(
                          Icons.health_and_safety_outlined,
                          size: 16),
                      label: const Text('KB Health'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () => setState(() {
                        _selectedEntry = null;
                        _formOpen = true;
                      }),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Thêm mới'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Filter bar
                Row(
                  children: [
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: _onSearch,
                        decoration: InputDecoration(
                          hintText: 'Tìm tiêu đề, nội dung...',
                          prefixIcon:
                              const Icon(Icons.search, size: 18),
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: filter.category.isEmpty
                            ? null
                            : filter.category,
                        hint: const Text('Tất cả category'),
                        items: const [
                          DropdownMenuItem(
                              value: null,
                              child: Text('Tất cả')),
                          DropdownMenuItem(
                              value: 'faq', child: Text('FAQ')),
                          DropdownMenuItem(
                              value: 'policy',
                              child: Text('Policy')),
                          DropdownMenuItem(
                              value: 'destination',
                              child: Text('Destination')),
                        ],
                        onChanged: (v) => ref
                            .read(knowledgeFilterProvider.notifier)
                            .update((s) =>
                                s.copyWith(category: v ?? '', page: 1)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Table
                Expanded(
                  child: listAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Center(child: Text('Lỗi: $e')),
                    data: (data) => Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                  Colors.grey.shade50),
                              columns: const [
                                DataColumn(
                                    label: Text('Tiêu đề')),
                                DataColumn(
                                    label: Text('Category')),
                                DataColumn(label: Text('Tags')),
                                DataColumn(
                                    label: Text('Embedding')),
                                DataColumn(
                                    label: Text('Cập nhật')),
                                DataColumn(label: Text('')),
                              ],
                              rows: data.items
                                  .map((entry) => DataRow(
                                        cells: [
                                          DataCell(SizedBox(
                                            width: 220,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
                                              children: [
                                                Text(
                                                  entry.title,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight
                                                              .w500,
                                                      fontSize: 13),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                ),
                                                if (!entry.isActive)
                                                  const Text(
                                                    'Inactive',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color:
                                                            Colors.grey),
                                                  ),
                                              ],
                                            ),
                                          )),
                                          DataCell(Text(
                                              entry.category ?? '—',
                                              style: const TextStyle(
                                                  fontSize: 13))),
                                          DataCell(entry.tags.isEmpty
                                              ? const Text('—',
                                                  style: TextStyle(
                                                      color:
                                                          Colors.grey))
                                              : Text(
                                                  '${entry.tags.take(2).join(', ')}${entry.tags.length > 2 ? '...' : ''}',
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                )),
                                          DataCell(
                                            EmbeddingStatusBadge(
                                              status:
                                                  entry.embeddingStatus,
                                              jobId:
                                                  entry.embeddingJobId,
                                              onStatusChange: () =>
                                                  ref.invalidate(
                                                      knowledgeListProvider(
                                                          filter)),
                                            ),
                                          ),
                                          DataCell(Text(
                                            DateFormat('dd/MM/yy')
                                                .format(entry.updatedAt),
                                            style: const TextStyle(
                                                fontSize: 12),
                                          )),
                                          DataCell(
                                            Row(
                                              mainAxisSize:
                                                  MainAxisSize.min,
                                              children: [
                                                TextButton(
                                                  onPressed: () =>
                                                      setState(() {
                                                    _selectedEntry =
                                                        entry;
                                                    _formOpen = true;
                                                  }),
                                                  style: TextButton
                                                      .styleFrom(
                                                    minimumSize:
                                                        Size.zero,
                                                    padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal:
                                                                8),
                                                  ),
                                                  child:
                                                      const Text('Sửa'),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons
                                                          .delete_outline,
                                                      size: 18,
                                                      color: Colors.red),
                                                  onPressed: () =>
                                                      _deleteEntry(entry),
                                                  padding:
                                                      EdgeInsets.zero,
                                                  visualDensity:
                                                      VisualDensity
                                                          .compact,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                        _Pagination(
                          page: filter.page,
                          total: data.total,
                          pageSize: 20,
                          onPageChange: (p) => ref
                              .read(knowledgeFilterProvider.notifier)
                              .update((s) => s.copyWith(page: p)),
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
          KnowledgeFormSheet(
            open: _formOpen,
            entry: _selectedEntry,
            onClose: () => setState(() => _formOpen = false),
            onSuccess: () {
              setState(() => _formOpen = false);
              ref.invalidate(knowledgeListProvider);
            },
          ),
      ],
    );
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref
          .read(knowledgeFilterProvider.notifier)
          .update((s) => s.copyWith(search: v, page: 1));
    });
  }

  Future<void> _deleteEntry(KnowledgeEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá entry?'),
        content: Text(
            'Bạn chắc chắn muốn xoá "${entry.title}"?\n(Entry sẽ bị deactivate)'),
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
    if (confirmed != true || !mounted) return;
    await ref.read(knowledgeRepositoryProvider).delete(entry.id);
    ref.invalidate(knowledgeListProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xoá entry')));
    }
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
    if (totalPages <= 1) return const SizedBox.shrink();
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
