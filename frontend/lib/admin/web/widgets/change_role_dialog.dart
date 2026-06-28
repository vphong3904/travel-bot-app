// lib/admin/web/widgets/change_role_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/data/users_repository.dart';
import '../../shared/providers/users_provider.dart';
import 'role_badge.dart';

const _roles = [
  ('super_admin', 'Super Admin'),
  ('admin', 'Admin'),
  ('content_manager', 'Content Manager'),
  ('moderator', 'Moderator'),
  ('user', 'User'),
];

class ChangeRoleDialog extends ConsumerStatefulWidget {
  final String userId;
  final String currentRole;

  const ChangeRoleDialog({
    super.key,
    required this.userId,
    required this.currentRole,
  });

  @override
  ConsumerState<ChangeRoleDialog> createState() => _ChangeRoleDialogState();
}

class _ChangeRoleDialogState extends ConsumerState<ChangeRoleDialog> {
  bool _isLoading = false;

  Future<void> _changeRole(String newRole) async {
    if (newRole == widget.currentRole) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(usersRepositoryProvider)
          .changeRole(widget.userId, newRole);

      ref.invalidate(userDetailProvider(widget.userId));
      ref.invalidate(usersListProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật role thành công')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showDialog(context),
      icon: const Icon(Icons.manage_accounts_outlined, size: 16),
      label: const Text('Đổi role'),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _isLoading
          ? const Center(child: CircularProgressIndicator())
          : AlertDialog(
              title: const Text('Thay đổi role'),
              content: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _roles.map((r) {
                    final (value, label) = r;
                    final isCurrent = value == widget.currentRole;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: RoleBadge(role: value),
                      title: Text(label),
                      trailing: isCurrent
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        Navigator.pop(ctx);
                        _changeRole(value);
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Huỷ'),
                ),
              ],
            ),
    );
  }
}
