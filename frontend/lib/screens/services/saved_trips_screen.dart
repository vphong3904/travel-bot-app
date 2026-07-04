// lib/screens/services/saved_trips_screen.dart
// [P2] Danh mục chuyến đi đã lưu (GET /trips) — xem/xóa.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../services/trip_api_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/loading_state_widgets.dart';
import '../auth/login_register_screen.dart';

class SavedTripsScreen extends StatefulWidget {
  /// Khi nhúng làm tab trong Trip hub → chỉ render body, không có Scaffold/AppBar.
  final bool embedded;
  const SavedTripsScreen({super.key, this.embedded = false});

  @override
  State<SavedTripsScreen> createState() => _SavedTripsScreenState();
}

class _SavedTripsScreenState extends State<SavedTripsScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _trips = [];

  TripApiService _api(AppState s) => TripApiService(
        tokenProvider: () => s.token,
        tokenRefresher: () => s.refreshAccessToken(),
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) _load();
  }

  Future<void> _load() async {
    final s = context.read<AppState>();
    if (!s.isLoggedIn) {
      setState(() { _loading = false; _error = 'login'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final trips = await _api(s).listTrips();
      if (!mounted) return;
      setState(() { _trips = trips; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = friendlyError(e); _loading = false; });
    }
  }

  Future<void> _delete(String id) async {
    final s = context.read<AppState>();
    try {
      await _api(s).deleteTrip(id);
      setState(() => _trips.removeWhere((t) => t['id'].toString() == id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi xóa: ${friendlyError(e)}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _buildBody();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Chuyến đi đã lưu',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return _loading
          ? const LoadingScreen(message: 'Đang tải...')
          : _error == 'login'
              ? _loginPrompt()
              : _error != null
                  ? ErrorScreen(message: _error!, onRetry: _load)
                  : _trips.isEmpty
                      ? EmptyScreen(
                          title: 'Chưa có chuyến đi',
                          message: 'Lưu lịch trình từ trợ lý AI để xem lại ở đây.',
                          icon: Icons.luggage_outlined,
                          onRetry: _load,
                        )
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _trips.length,
                            itemBuilder: (_, i) => _tripCard(_trips[i] as Map<String, dynamic>),
                          ),
                        );
  }

  Widget _loginPrompt() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: AppColors.muted),
              const SizedBox(height: 14),
              const Text('Đăng nhập để xem chuyến đi đã lưu',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: AppColors.dark)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LoginRegisterScreen())),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: const Text('Đăng nhập'),
              ),
            ],
          ),
        ),
      );

  Widget _tripCard(Map<String, dynamic> t) {
    final id = t['id'].toString();
    final title = (t['title'] ?? 'Chuyến đi').toString();
    final status = (t['status'] ?? '').toString();
    final aiGen = t['ai_generated'] == true;
    final travelers = t['travelers'] ?? 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.map_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.group_outlined, size: 12, color: AppColors.muted),
                  const SizedBox(width: 3),
                  Text('$travelers người',
                      style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                  if (aiGen) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.auto_awesome, size: 12, color: AppColors.secondary),
                    const SizedBox(width: 2),
                    const Text('AI', style: TextStyle(fontSize: 11, color: AppColors.secondary)),
                  ],
                  if (status.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(status, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                  ],
                ]),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.muted, size: 20),
            onPressed: () => _confirmDelete(id, title),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa chuyến đi?'),
        content: Text('Xóa "$title" khỏi danh sách đã lưu?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () { Navigator.pop(context); _delete(id); },
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
