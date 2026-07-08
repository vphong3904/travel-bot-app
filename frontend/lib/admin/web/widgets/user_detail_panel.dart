// lib/admin/web/widgets/user_detail_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../shared/models/auth_user.dart';
import '../../shared/models/user_model.dart';
import '../../shared/data/users_repository.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/users_provider.dart';
import 'role_badge.dart';
import 'change_role_dialog.dart';
import 'user_sessions_tab.dart';

class UserDetailPanel extends ConsumerStatefulWidget {
  final String userId;
  final VoidCallback onClose;

  const UserDetailPanel({
    super.key,
    required this.userId,
    required this.onClose,
  });

  @override
  ConsumerState<UserDetailPanel> createState() => _UserDetailPanelState();
}

class _UserDetailPanelState extends ConsumerState<UserDetailPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userDetailProvider(widget.userId));
    final currentUser = ref.watch(authProvider).user;
    final currentUserRole = currentUser?.role;
    final canManage = currentUserRole == AdminRole.superAdmin ||
        currentUserRole == AdminRole.admin;
    // Đổi role chỉ Super Admin — Admin kế thừa quyền khoá/xoá tài khoản
    // nhưng không được cấp vai trò cho người khác.
    final canChangeRole = currentUserRole == AdminRole.superAdmin;

    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                const Text(
                  'Chi tiết người dùng',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: userAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Lỗi: $e')),
              data: (user) => Column(
                children: [
                  // Avatar + name
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFF2563EB),
                          child: Text(
                            (user.fullName?.isNotEmpty == true
                                    ? user.fullName![0]
                                    : user.email[0])
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName ?? 'Chưa có tên',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                user.email,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tabs
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Thông tin'),
                      Tab(text: 'Lịch sử chat'),
                      Tab(text: 'Phiên đăng nhập'),
                    ],
                  ),

                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _InfoTab(
                          user: user,
                          canChangeRole: canChangeRole,
                          canDelete: canManage &&
                              (user.role != 'super_admin' ||
                                  currentUserRole == AdminRole.superAdmin) &&
                              user.id != currentUser?.id,
                          onToggleActive: () => _toggleActive(user),
                          onDelete: () => _deleteUser(user),
                        ),
                        _ChatHistoryTab(sessions: user.recentSessions),
                        UserSessionsTab(userId: user.id),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleActive(UserDetail user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(user.isActive ? 'Khoá tài khoản?' : 'Mở khoá tài khoản?'),
        content: Text(
          user.isActive
              ? 'Người dùng sẽ không thể đăng nhập.'
              : 'Người dùng sẽ có thể đăng nhập lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor:
                  user.isActive ? Colors.red : Colors.green,
            ),
            child: Text(user.isActive ? 'Khoá' : 'Mở khoá'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await ref
        .read(usersRepositoryProvider)
        .updateUser(widget.userId, isActive: !user.isActive);
    ref.invalidate(userDetailProvider(widget.userId));
    ref.invalidate(usersListProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              user.isActive ? 'Đã khoá tài khoản' : 'Đã mở khoá tài khoản'),
        ),
      );
    }
  }

  Future<void> _deleteUser(UserDetail user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá tài khoản?'),
        content: Text(
          'Tài khoản "${user.fullName ?? user.email}" sẽ bị xoá vĩnh viễn khỏi hệ thống. Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(usersRepositoryProvider).deleteUser(widget.userId);
      ref.invalidate(usersListProvider);
      if (mounted) {
        widget.onClose();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xoá tài khoản')),
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
}

// ── Info Tab ─────────────────────────────────────────────────────────────────

class _InfoTab extends StatelessWidget {
  final UserDetail user;
  final bool canChangeRole;
  final bool canDelete;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const _InfoTab({
    required this.user,
    required this.canChangeRole,
    required this.canDelete,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoGrid([
            ('Role', RoleBadge(role: user.role)),
            (
              'Trạng thái',
              _StatusBadge(isActive: user.isActive),
            ),
            ('Đăng nhập qua', Text(user.authProvider.toUpperCase())),
            (
              'Ngày đăng ký',
              Text(DateFormat('dd/MM/yyyy').format(user.createdAt)),
            ),
            ('Chat sessions', Text(user.totalChatSessions.toString())),
            ('Tổng tin nhắn', Text(user.totalMessages.toString())),
          ]),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: onToggleActive,
                style: ElevatedButton.styleFrom(
                  backgroundColor: user.isActive
                      ? Colors.red.shade600
                      : Colors.green.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: Text(
                    user.isActive ? 'Khoá tài khoản' : 'Mở khoá'),
              ),
              if (canChangeRole)
                ChangeRoleDialog(
                  userId: user.id,
                  currentRole: user.role,
                ),
              if (canDelete)
                OutlinedButton.icon(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Xoá tài khoản'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoGrid(List<(String, Widget)> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            items[i].$1,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          items[i].$2,
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'Hoạt động' : 'Đã khoá',
        style: TextStyle(
          color: isActive ? Colors.green.shade700 : Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ── Chat History Tab ──────────────────────────────────────────────────────────

class _ChatHistoryTab extends StatelessWidget {
  final List<ChatSessionSummary> sessions;
  const _ChatHistoryTab({required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(
        child: Text('Chưa có hội thoại',
            style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final s = sessions[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.title ?? 'Hội thoại không tên',
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${s.totalMessages} tin · ${DateFormat('dd/MM/yyyy').format(s.updatedAt)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
