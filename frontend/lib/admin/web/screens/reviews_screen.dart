// lib/admin/web/screens/reviews_screen.dart
// Quản lý review/đánh giá: xem toàn bộ (mọi role giám sát), chỉ admin/super_admin
// được xoá. Click vào tên user mở UserDetailPanel (tái dùng từ màn Người dùng)
// để khoá tài khoản ngay tại chỗ nếu user cố tình bình luận phá.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../shared/data/reviews_repository.dart';
import '../../shared/models/auth_user.dart';
import '../../shared/models/review_item.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/reviews_provider.dart';
import '../widgets/user_detail_panel.dart';

class ReviewsScreen extends ConsumerStatefulWidget {
  const ReviewsScreen({super.key});

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  String? _selectedUserId;
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(reviewsFilterProvider.notifier).update(
            (s) => s.copyWith(search: value, page: 1),
          );
    });
  }

  Future<void> _deleteReview(ReviewItem r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá đánh giá này?'),
        content: Text(
          'Đánh giá của "${r.userFullName ?? r.username}" về ${r.destinationName} '
          'sẽ bị xoá vĩnh viễn. Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(reviewsRepositoryProvider).deleteReview(r.id);
      ref.invalidate(reviewsListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xoá đánh giá')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(reviewsFilterProvider);
    final reviewsAsync = ref.watch(reviewsListProvider(filter));
    final role = ref.watch(authProvider).user?.role;
    final canDelete =
        role == AdminRole.admin || role == AdminRole.superAdmin;

    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Đánh giá',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        reviewsAsync.when(
                          data: (d) => Text('${d.total} đánh giá',
                              style: const TextStyle(color: Colors.grey)),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Tải lại',
                      onPressed: () => ref.invalidate(reviewsListProvider),
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
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Tìm nội dung, tên, email...',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: filter.rating,
                        hint: const Text('Tất cả số sao'),
                        items: [
                          const DropdownMenuItem<int?>(value: null, child: Text('Tất cả số sao')),
                          for (final n in [5, 4, 3, 2, 1])
                            DropdownMenuItem<int?>(value: n, child: Text('$n ★')),
                        ],
                        onChanged: (v) => ref.read(reviewsFilterProvider.notifier).update(
                              (s) => s.copyWith(rating: v, clearRating: v == null, page: 1),
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: reviewsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Lỗi: $e')),
                    data: (data) => data.items.isEmpty
                        ? const Center(
                            child: Text('Không có đánh giá nào',
                                style: TextStyle(color: Colors.grey)),
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: _ReviewsTable(
                                  reviews: data.items,
                                  canDelete: canDelete,
                                  selectedUserId: _selectedUserId,
                                  onSelectUser: (id) =>
                                      setState(() => _selectedUserId = id),
                                  onDelete: _deleteReview,
                                ),
                              ),
                              _Pagination(
                                page: filter.page,
                                total: data.total,
                                pageSize: 20,
                                onPageChange: (p) => ref
                                    .read(reviewsFilterProvider.notifier)
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

        // Click tên user → mở đúng panel khoá/mở khoá tài khoản đã có sẵn ở
        // màn Người dùng, không xây lại từ đầu.
        if (_selectedUserId != null)
          UserDetailPanel(
            userId: _selectedUserId!,
            onClose: () => setState(() => _selectedUserId = null),
          ),
      ],
    );
  }
}

class _ReviewsTable extends StatelessWidget {
  final List<ReviewItem> reviews;
  final bool canDelete;
  final String? selectedUserId;
  final ValueChanged<String> onSelectUser;
  final ValueChanged<ReviewItem> onDelete;

  const _ReviewsTable({
    required this.reviews,
    required this.canDelete,
    required this.selectedUserId,
    required this.onSelectUser,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
        columnSpacing: 16,
        columns: const [
          DataColumn(label: Text('Người dùng')),
          DataColumn(label: Text('Địa điểm')),
          DataColumn(label: Text('Số sao')),
          DataColumn(label: Text('Nội dung')),
          DataColumn(label: Text('Ngày')),
          DataColumn(label: Text('')),
        ],
        rows: reviews.map((r) {
          final isSelected = r.userId == selectedUserId;
          return DataRow(
            color: WidgetStateProperty.resolveWith(
              (states) => isSelected ? Colors.blue.shade50 : null,
            ),
            cells: [
              DataCell(
                InkWell(
                  onTap: () => onSelectUser(r.userId),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        r.userFullName?.isNotEmpty == true ? r.userFullName! : r.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF2563EB),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      Text(r.userEmail,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5)),
                    ],
                  ),
                ),
              ),
              DataCell(SizedBox(
                width: 140,
                child: Text(r.destinationName,
                    style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
              )),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 2),
                  Text('${r.rating}', style: const TextStyle(fontSize: 13)),
                ],
              )),
              DataCell(SizedBox(
                width: 280,
                child: Text(
                  r.content ?? '',
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
              DataCell(Text(
                r.createdAt != null
                    ? DateFormat('dd/MM/yy').format(DateTime.parse(r.createdAt!))
                    : '—',
                style: const TextStyle(fontSize: 12),
              )),
              DataCell(
                canDelete
                    ? IconButton(
                        icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade600),
                        tooltip: 'Xoá đánh giá',
                        onPressed: () => onDelete(r),
                      )
                    : const SizedBox(),
              ),
            ],
          );
        }).toList(),
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
            onPressed: page > 1 ? () => onPageChange(page - 1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('Trang $page / $totalPages', style: const TextStyle(fontSize: 13)),
          IconButton(
            onPressed: page < totalPages ? () => onPageChange(page + 1) : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
