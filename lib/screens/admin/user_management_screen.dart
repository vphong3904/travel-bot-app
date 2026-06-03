import 'package:flutter/material.dart';
import '../../services/travel_api.dart';
import '../../widgets/common_widgets.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<dynamic> users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final data = await AdminService.getUsers();
    if (mounted) setState(() { users = data; loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý người dùng', style: TextStyle(fontWeight: FontWeight.bold))),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (_, i) {
                final u = users[i];
                final active = u['is_active'] ?? true;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: u['role'] == 'admin' ? AppColors.secondary.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.15),
                      child: Text((u['name'] ?? '?').substring(0, 1), style: TextStyle(color: u['role'] == 'admin' ? AppColors.secondary : AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(u['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${u['email']} • ${u['role']}'),
                    trailing: Switch(
                      value: active,
                      onChanged: (_) async {
                        await AdminService.toggleUser(u['id']);
                        _load();
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
