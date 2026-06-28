import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../services/admin_api_service.dart';
import '../../widgets/common_widgets.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late AdminApiService _api;
  List<dynamic> users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    final token = context.read<AppState>().token;
    _api = AdminApiService(token: token);
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final data = await _api.getUsers();
      if (mounted) setState(() { users = data; loading = false; });
    } catch (e) {
      if (mounted) setState(() { loading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? const Center(child: Text('Không có người dùng nào'))
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
                            final userId = u['id']?.toString() ?? '';
                            if (userId.isNotEmpty) {
                              await _api.toggleUser(userId);
                              _load();
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
