import 'package:flutter/material.dart';
import '../../services/travel_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/web_layout.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<dynamic> users = [];
  bool loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final data = await AdminService.getUsers();
    if (mounted) setState(() { users = data; loading = false; });
  }

  List<dynamic> get filtered {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return users;
    return users.where((u) => '${u['name']} ${u['email']}'.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return WebAdminShell(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(title: Text('Quản lý người dùng', style: AppTheme.heading(size: 18))),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppSearchBar(
                controller: _searchCtrl,
                hint: 'Tìm theo tên, email...',
                margin: EdgeInsets.zero,
                onChanged: (_) => setState(() {}),
              ),
            ),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : filtered.isEmpty
                      ? Center(child: Text('Không tìm thấy người dùng', style: AppTheme.body(color: AppColors.muted)))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final u = filtered[i];
                            final active = u['is_active'] ?? true;
                            final isAdmin = u['role'] == 'admin';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isAdmin ? AppColors.accent.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.15),
                                  child: Text(
                                    (u['name'] ?? '?').substring(0, 1).toUpperCase(),
                                    style: AppTheme.body(color: isAdmin ? AppColors.accent : AppColors.primary, weight: FontWeight.w700),
                                  ),
                                ),
                                title: Text(u['name'] ?? '', style: AppTheme.body(size: 15, weight: FontWeight.w600)),
                                subtitle: Text('${u['email']} · ${isAdmin ? 'Admin' : 'User'}', style: AppTheme.body(size: 12, color: AppColors.muted)),
                                trailing: Switch(
                                  value: active,
                                  activeThumbColor: AppColors.success,
                                  onChanged: (_) async {
                                    final ok = await AdminService.toggleUser(u['id']);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(ok ? 'Đã cập nhật trạng thái' : 'Cập nhật thất bại')),
                                      );
                                      _load();
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
