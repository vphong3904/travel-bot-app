// lib/admin/web/screens/feedback_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../shared/data/feedback_repository.dart';
import '../../shared/models/auth_user.dart';
import '../../shared/models/feedback_item.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/feedback_provider.dart';

const _tabs = [
  (key: 'all', label: 'Tất cả'),
  (key: 'positive', label: '👍 Tích cực'),
  (key: 'negative', label: '👎 Tiêu cực'),
  (key: 'pending', label: 'Chờ xử lý'),
];

const _categoryLabels = {
  'wrong_info': 'Sai thông tin',
  'irrelevant': 'Không liên quan',
  'too_long': 'Quá dài',
  'hallucination': 'Hallucination',
  'rude': 'Thiếu lịch sự',
  'other': 'Khác',
};

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() =>
      _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) return;
      ref.read(feedbackFilterProvider.notifier).update(
        (s) => s.copyWith(
          tab: _tabs[_tabCtrl.index].key,
          page: 1,
        ),
      );
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(feedbackFilterProvider);
    final listAsync = ref.watch(feedbackListProvider(filter));
    final statsAsync = ref.watch(feedbackStatsProvider);
    final role = ref.watch(authProvider).user?.role;
    final canResolve =
        role == AdminRole.admin || role == AdminRole.superAdmin;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Feedback Management',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Quản lý phản hồi từ người dùng',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Stats row
          statsAsync.when(
            loading: () => const SizedBox(
              height: 72,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox(),
            data: (stats) => _StatsRow(stats: stats),
          ),
          const SizedBox(height: 20),

          // Tabs
          TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            tabs: _tabs
                .map((t) => Tab(text: t.label))
                .toList(),
          ),
          const SizedBox(height: 12),

          // Filter row
          Row(
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: filter.category.isEmpty
                      ? null
                      : filter.category,
                  hint: const Text('Tất cả category'),
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Tất cả category')),
                    ..._categoryLabels.entries.map((e) =>
                        DropdownMenuItem<String?>(
                          value: e.key,
                          child: Text(e.value),
                        )),
                  ],
                  onChanged: (v) => ref
                      .read(feedbackFilterProvider.notifier)
                      .update((s) => s.copyWith(
                          category: v ?? '', page: 1)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Table
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
                            Icons.feedback_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Chưa có feedback nào',
                            style:
                                TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: DataTable(
                              headingRowColor:
                                  WidgetStateProperty.all(
                                      Colors.grey.shade50),
                              columns: const [
                                DataColumn(
                                    label:
                                        Text('Câu trả lời')),
                                DataColumn(
                                    label:
                                        Text('Feedback')),
                                DataColumn(
                                    label:
                                        Text('Category')),
                                DataColumn(
                                    label: Text('Intent')),
                                DataColumn(
                                    label: Text('Ngày')),
                                DataColumn(
                                    label: Text('Action')),
                              ],
                              rows: data.items
                                  .map((item) =>
                                      _buildRow(item, canResolve))
                                  .toList(),
                            ),
                          ),
                        ),
                        _Pagination(
                          page: filter.page,
                          total: data.total,
                          pageSize: 20,
                          onPageChange: (p) => ref
                              .read(feedbackFilterProvider
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

  DataRow _buildRow(FeedbackItem item, bool canResolve) {
    return DataRow(
      cells: [
        DataCell(SizedBox(
          width: 280,
          child: Text(
            item.contentPreview,
            style: const TextStyle(fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        )),
        DataCell(_FeedbackTypeBadge(type: item.feedbackType)),
        DataCell(item.category != null
            ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _categoryLabels[item.category] ??
                      item.category!,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade700),
                ),
              )
            : const Text('—',
                style: TextStyle(color: Colors.grey))),
        DataCell(Text(
          item.intent ?? '—',
          style: const TextStyle(
              fontSize: 12, color: Colors.grey),
        )),
        DataCell(Text(
          DateFormat('dd/MM/yy')
              .format(DateTime.parse(item.createdAt)),
          style: const TextStyle(fontSize: 12),
        )),
        DataCell(item.resolved
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 16, color: Colors.green),
                  SizedBox(width: 4),
                  Text('Đã xử lý',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.green)),
                ],
              )
            : (canResolve
                ? TextButton(
                    onPressed: () => _resolve(item),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8),
                    ),
                    child: const Text('Đã xử lý'),
                  )
                : const Text('Chờ xử lý',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey)))),
      ],
    );
  }

  Future<void> _resolve(FeedbackItem item) async {
    await ref
        .read(feedbackRepositoryProvider)
        .resolve(item.messageId);
    ref.invalidate(feedbackListProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Đã đánh dấu xử lý')));
    }
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _FeedbackTypeBadge extends StatelessWidget {
  final String type;
  const _FeedbackTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isPositive = type == 'positive';
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPositive
            ? Colors.green.shade50
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPositive
              ? Colors.green.shade200
              : Colors.red.shade200,
        ),
      ),
      child: Text(
        isPositive ? '👍 Tích cực' : '👎 Tiêu cực',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isPositive
              ? Colors.green.shade700
              : Colors.red.shade700,
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final FeedbackStats stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total =
        stats.totalPositive + stats.totalNegative;
    final posRate = total > 0
        ? (stats.totalPositive / total * 100)
            .toStringAsFixed(1)
        : '0.0';
    return Row(
      children: [
        _statCard('Tổng feedback', '$total',
            Colors.black87),
        const SizedBox(width: 12),
        _statCard('👍 Tích cực',
            '${stats.totalPositive}',
            Colors.green.shade700),
        const SizedBox(width: 12),
        _statCard('👎 Tiêu cực',
            '${stats.totalNegative}', Colors.red.shade700),
        const SizedBox(width: 12),
        _statCard(
          'Tỉ lệ tích cực',
          '$posRate%',
          double.parse(posRate) >= 70
              ? Colors.green.shade700
              : Colors.amber.shade700,
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
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
