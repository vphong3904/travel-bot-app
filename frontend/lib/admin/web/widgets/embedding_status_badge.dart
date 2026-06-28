// lib/admin/web/widgets/embedding_status_badge.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/data/knowledge_repository.dart';

class EmbeddingStatusBadge extends ConsumerStatefulWidget {
  final String? status;
  final String? jobId;
  final VoidCallback? onStatusChange;

  const EmbeddingStatusBadge({
    super.key,
    required this.status,
    required this.jobId,
    this.onStatusChange,
  });

  @override
  ConsumerState<EmbeddingStatusBadge> createState() =>
      _EmbeddingStatusBadgeState();
}

class _EmbeddingStatusBadgeState
    extends ConsumerState<EmbeddingStatusBadge> {
  Timer? _pollTimer;
  int _attempts = 0;
  late String? _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status;
    _startPollingIfNeeded();
  }

  @override
  void didUpdateWidget(EmbeddingStatusBadge old) {
    super.didUpdateWidget(old);
    if (old.status != widget.status || old.jobId != widget.jobId) {
      _currentStatus = widget.status;
      _stopPolling();
      _attempts = 0;
      _startPollingIfNeeded();
    }
  }

  void _startPollingIfNeeded() {
    if (_currentStatus == 'pending' && widget.jobId != null) {
      _pollTimer =
          Timer.periodic(const Duration(seconds: 3), (_) async {
        _attempts++;
        if (_attempts > 20) {
          _stopPolling();
          return;
        }
        try {
          final repo = ref.read(knowledgeRepositoryProvider);
          final newStatus = await repo.getJobStatus(widget.jobId!);
          if (newStatus != 'pending') {
            if (mounted) setState(() => _currentStatus = newStatus);
            _stopPolling();
            widget.onStatusChange?.call();
          }
        } catch (_) {
          _stopPolling();
        }
      });
    }
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _buildBadge(_currentStatus);

  Widget _buildBadge(String? status) {
    switch (status) {
      case 'pending':
        return _badge(
          label: 'Đang embed...',
          icon: Icons.sync,
          bg: Colors.orange.shade50,
          fg: Colors.orange.shade700,
          spinning: true,
        );
      case 'done':
        return _badge(
          label: 'Đã đồng bộ ✓',
          icon: Icons.check_circle_outline,
          bg: Colors.green.shade50,
          fg: Colors.green.shade700,
        );
      case 'error':
        return _badge(
          label: 'Lỗi embed',
          icon: Icons.error_outline,
          bg: Colors.red.shade50,
          fg: Colors.red.shade700,
        );
      default:
        return _badge(
          label: 'Chưa embed',
          icon: Icons.radio_button_unchecked,
          bg: Colors.grey.shade100,
          fg: Colors.grey.shade600,
        );
    }
  }

  Widget _badge({
    required String label,
    required IconData icon,
    required Color bg,
    required Color fg,
    bool spinning = false,
  }) {
    Widget iconWidget = Icon(icon, size: 12, color: fg);
    if (spinning) {
      iconWidget = SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation<Color>(fg),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        iconWidget,
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
              fontSize: 11,
              color: fg,
              fontWeight: FontWeight.w500),
        ),
      ]),
    );
  }
}
