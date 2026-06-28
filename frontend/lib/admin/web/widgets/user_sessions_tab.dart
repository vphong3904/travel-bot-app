// lib/admin/web/widgets/user_sessions_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../shared/data/session_repository.dart';
import '../../shared/models/user_session.dart';
import '../../shared/providers/session_provider.dart';

class UserSessionsTab extends ConsumerWidget {
  final String userId;
  const UserSessionsTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync =
        ref.watch(userSessionsProvider(userId));

    return sessionsAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text('Lỗi: $e')),
      data: (sessions) => sessions.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.devices_outlined,
                      size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Không có phiên nào đang hoạt động',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                    Colors.grey.shade50),
                columns: const [
                  DataColumn(label: Text('IP Address')),
                  DataColumn(
                      label: Text('Trình duyệt')),
                  DataColumn(label: Text('Ngày tạo')),
                  DataColumn(label: Text('Hết hạn')),
                  DataColumn(label: Text('Action')),
                ],
                rows: sessions
                    .map((s) =>
                        _buildRow(context, ref, s))
                    .toList(),
              ),
            ),
    );
  }

  DataRow _buildRow(BuildContext context, WidgetRef ref,
      UserSession session) {
    final fmt = DateFormat('dd/MM/yy HH:mm');
    return DataRow(
      cells: [
        DataCell(Text(
          session.ipAddress ?? '—',
          style: const TextStyle(
              fontSize: 12, fontFamily: 'monospace'),
        )),
        DataCell(SizedBox(
          width: 180,
          child: Text(
            _shortUserAgent(session.userAgent),
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        )),
        DataCell(Text(
          fmt.format(DateTime.parse(session.createdAt)),
          style: const TextStyle(fontSize: 12),
        )),
        DataCell(Text(
          fmt.format(DateTime.parse(session.expiresAt)),
          style: TextStyle(
            fontSize: 12,
            color: session.isExpired ? Colors.red : null,
          ),
        )),
        DataCell(TextButton(
          onPressed: () =>
              _revoke(context, ref, session),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(
                horizontal: 8),
          ),
          child: const Text('Thu hồi',
              style: TextStyle(fontSize: 12)),
        )),
      ],
    );
  }

  String _shortUserAgent(String? ua) {
    if (ua == null) return '—';
    final patterns = [
      RegExp(r'(Chrome/[\d.]+)'),
      RegExp(r'(Firefox/[\d.]+)'),
      RegExp(r'(Safari/[\d.]+)'),
      RegExp(r'(Edge/[\d.]+)'),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(ua);
      if (m != null) return m.group(1) ?? ua;
    }
    return ua.substring(0, ua.length.clamp(0, 40));
  }

  Future<void> _revoke(BuildContext context, WidgetRef ref,
      UserSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thu hồi phiên đăng nhập?'),
        content: Text(
          'IP: ${session.ipAddress ?? "—"}\n'
          'Người dùng sẽ bị đăng xuất khỏi thiết bị này.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Huỷ')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red),
            child: const Text('Thu hồi'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref
        .read(sessionRepositoryProvider)
        .revoke(session.id);
    ref.invalidate(userSessionsProvider(userId));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Đã thu hồi phiên đăng nhập')));
    }
  }
}
