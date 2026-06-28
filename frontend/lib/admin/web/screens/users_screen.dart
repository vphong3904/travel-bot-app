// lib/admin/web/screens/users_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../shared/models/user_model.dart';
import '../../shared/providers/users_provider.dart';
import '../widgets/role_badge.dart';
import '../widgets/user_detail_panel.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
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
      ref.read(usersFilterProvider.notifier).update(
            (s) => s.copyWith(search: value, page: 1),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(usersFilterProvider);
    final usersAsync = ref.watch(usersListProvider(filter));

    return Row(
      children: [
        // ── Main list ────────────────────────────────────────────────────────
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
                          'Người dùng',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        usersAsync.when(
                          data: (d) => Text('${d.total} tài khoản',
                              style:
                                  const TextStyle(color: Colors.grey)),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Filter bar
                Row(
                  children: [
                    SizedBox(
                      width: 280,
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Tìm email, tên...',
                          prefixIcon:
                              const Icon(Icons.search, size: 18),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: filter.role.isEmpty ? null : filter.role,
                        hint: const Text('Tất cả role'),
                        borderRadius: BorderRadius.circular(8),
                        items: const [
                          DropdownMenuItem(
                              value: null,
                              child: Text('Tất cả role')),
                          DropdownMenuItem(
                              value: 'super_admin',
                              child: Text('Super Admin')),
                          DropdownMenuItem(
                              value: 'admin', child: Text('Admin')),
                          DropdownMenuItem(
                              value: 'content_manager',
                              child: Text('Content Manager')),
                          DropdownMenuItem(
                              value: 'moderator',
                              child: Text('Moderator')),
                          DropdownMenuItem(
                              value: 'user', child: Text('User')),
                        ],
                        onChanged: (v) => ref
                            .read(usersFilterProvider.notifier)
                            .update((s) =>
                                s.copyWith(role: v ?? '', page: 1)),
                      ),
                    ),
                    const Spacer(),
                    // Refresh
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Tải lại',
                      onPressed: () =>
                          ref.invalidate(usersListProvider),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Table + pagination
                Expanded(
                  child: usersAsync.when(
                    loading: () => const Center(
                        child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Center(child: Text('Lỗi: $e')),
                    data: (data) => Column(
                      children: [
                        Expanded(
                          child: _UsersTable(
                            users: data.items,
                            selectedId: _selectedUserId,
                            onSelect: (id) =>
                                setState(() => _selectedUserId = id),
                          ),
                        ),
                        _Pagination(
                          page: filter.page,
                          total: data.total,
                          pageSize: 20,
                          onPageChange: (p) => ref
                              .read(usersFilterProvider.notifier)
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

        // ── Detail panel ─────────────────────────────────────────────────────
        if (_selectedUserId != null)
          UserDetailPanel(
            userId: _selectedUserId!,
            onClose: () => setState(() => _selectedUserId = null),
          ),
      ],
    );
  }
}

// ── Users DataTable ───────────────────────────────────────────────────────────

class _UsersTable extends StatelessWidget {
  final List<UserModel> users;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  const _UsersTable({
    required this.users,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(
        child: Text('Không có kết quả',
            style: TextStyle(color: Colors.grey)),
      );
    }

    return SingleChildScrollView(
      child: DataTable(
        headingRowColor:
            WidgetStateProperty.all(Colors.grey.shade50),
        showCheckboxColumn: false,
        columnSpacing: 16,
        columns: const [
          DataColumn(label: Text('Người dùng')),
          DataColumn(label: Text('Role')),
          DataColumn(label: Text('Trạng thái')),
          DataColumn(label: Text('Ngày đăng ký')),
          DataColumn(label: Text('')),
        ],
        rows: users.map((user) {
          final isSelected = user.id == selectedId;
          return DataRow(
            selected: isSelected,
            color: WidgetStateProperty.resolveWith(
              (states) =>
                  isSelected ? Colors.blue.shade50 : null,
            ),
            onSelectChanged: (_) => onSelect(user.id),
            cells: [
              DataCell(_UserCell(user: user)),
              DataCell(RoleBadge(role: user.role)),
              DataCell(_StatusCell(isActive: user.isActive)),
              DataCell(Text(
                DateFormat('dd/MM/yyyy').format(user.createdAt),
                style: const TextStyle(fontSize: 13),
              )),
              DataCell(
                TextButton(
                  onPressed: () => onSelect(user.id),
                  child: const Text('Chi tiết →'),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _UserCell extends StatelessWidget {
  final UserModel user;
  const _UserCell({required this.user});

  @override
  Widget build(BuildContext context) {
    final initial = (user.fullName?.isNotEmpty == true
            ? user.fullName![0]
            : user.email[0])
        .toUpperCase();
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFF2563EB),
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user.fullName ?? '—',
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 13),
            ),
            Text(
              user.email,
              style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusCell extends StatelessWidget {
  final bool isActive;
  const _StatusCell({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:
            isActive ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'Đang hoạt động' : 'Đã khoá',
        style: TextStyle(
          color: isActive
              ? Colors.green.shade700
              : Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ── Pagination ────────────────────────────────────────────────────────────────

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

    final start = (page - 1) * pageSize + 1;
    final end = (page * pageSize).clamp(0, total);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$start–$end / $total',
            style:
                TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: page > 1 ? () => onPageChange(page - 1) : null,
            tooltip: 'Trang trước',
          ),
          Text('$page / $totalPages'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: page < totalPages
                ? () => onPageChange(page + 1)
                : null,
            tooltip: 'Trang sau',
          ),
        ],
      ),
    );
  }
}
