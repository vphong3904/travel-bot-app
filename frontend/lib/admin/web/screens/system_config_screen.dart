// lib/admin/web/screens/system_config_screen.dart
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:web/web.dart' as web;
import '../../shared/models/auth_user.dart';
import '../../shared/models/system_config.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/system_config_provider.dart';
import '../../shared/data/system_config_repository.dart';
import '../../shared/data/system_backup_repository.dart';

class SystemConfigScreen extends ConsumerWidget {
  const SystemConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(systemConfigProvider);
    final currentRole = ref.watch(authProvider).user?.role;
    final isSuperAdmin = currentRole == AdminRole.superAdmin;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Configuration',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Cấu hình hệ thống chatbot',
                    style: TextStyle(
                        color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              if (!isSuperAdmin) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: Colors.amber.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline,
                          size: 14,
                          color: Colors.amber.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Chỉ đọc — yêu cầu Super Admin để chỉnh sửa',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade800),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: configAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Lỗi: $e')),
              data: (configs) {
                final configMap = {
                  for (final c in configs) c.key: c
                };
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _ConfigSection(
                        title: 'Chatbot',
                        icon: Icons.chat_bubble_outline,
                        children: [
                          if (configMap['chatbot_enabled'] !=
                              null)
                            _ToggleConfigTile(
                              config: configMap[
                                  'chatbot_enabled']!,
                              label: 'Bật/Tắt chatbot',
                              description: configMap[
                                      'chatbot_enabled']!
                                  .description,
                              isSuperAdmin: isSuperAdmin,
                              onChanged: (v) => _save(
                                  context,
                                  ref,
                                  configMap[
                                      'chatbot_enabled']!,
                                  v),
                            ),
                          if (configMap['fallback_to_llm'] !=
                              null)
                            _ToggleConfigTile(
                              config: configMap[
                                  'fallback_to_llm']!,
                              label: 'Fallback to LLM',
                              description: configMap[
                                      'fallback_to_llm']!
                                  .description,
                              isSuperAdmin: isSuperAdmin,
                              isDangerous: true,
                              onChanged: (v) => _save(
                                  context,
                                  ref,
                                  configMap[
                                      'fallback_to_llm']!,
                                  v),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _ConfigSection(
                        title: 'RAG / Retrieval',
                        icon: Icons.search,
                        children: [
                          if (configMap[
                                  'gemini_temperature'] !=
                              null)
                            _SliderConfigTile(
                              config: configMap[
                                  'gemini_temperature']!,
                              label: 'Gemini Temperature',
                              description:
                                  'Mức độ sáng tạo của AI (0 = chính xác, 1 = sáng tạo)',
                              min: 0.0,
                              max: 1.0,
                              isSuperAdmin: isSuperAdmin,
                              onChanged: (v) => _save(
                                  context,
                                  ref,
                                  configMap[
                                      'gemini_temperature']!,
                                  double.parse(
                                      v.toStringAsFixed(2))),
                            ),
                          if (configMap['rag_top_k_default'] !=
                              null)
                            _NumberConfigTile(
                              config: configMap[
                                  'rag_top_k_default']!,
                              label: 'RAG Top-K',
                              description:
                                  'Số chunks lấy mỗi query',
                              min: 1,
                              max: 20,
                              isSuperAdmin: isSuperAdmin,
                              onChanged: (v) => _save(
                                  context,
                                  ref,
                                  configMap[
                                      'rag_top_k_default']!,
                                  v),
                            ),
                          if (configMap['use_reranking'] !=
                              null)
                            _ToggleConfigTile(
                              config: configMap[
                                  'use_reranking']!,
                              label: 'Bật Re-ranking',
                              description: configMap[
                                      'use_reranking']!
                                  .description,
                              isSuperAdmin: isSuperAdmin,
                              onChanged: (v) => _save(
                                  context,
                                  ref,
                                  configMap['use_reranking']!,
                                  v),
                            ),
                        ],
                      ),
                      if (isSuperAdmin) ...[
                        const SizedBox(height: 16),
                        const _BackupSection(),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    SystemConfig config,
    dynamic newValue,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận thay đổi cấu hình'),
        content: Text(
          'Thay đổi "${config.key}" sẽ ảnh hưởng toàn bộ chatbot.\n\n'
          'Giá trị cũ: ${config.value}\nGiá trị mới: $newValue\n\nTiếp tục?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Huỷ')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Lưu thay đổi'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(systemConfigRepositoryProvider)
          .update(config.key, newValue);
      ref.invalidate(systemConfigProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Đã cập nhật "${config.key}"')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }
}

// ── Section wrapper ───────────────────────────────────────────────────────────

class _ConfigSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _ConfigSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Icon(icon,
                    size: 18,
                    color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

// ── Toggle (bool) ─────────────────────────────────────────────────────────────

class _ToggleConfigTile extends StatelessWidget {
  final SystemConfig config;
  final String label;
  final String? description;
  final bool isSuperAdmin;
  final bool isDangerous;
  final ValueChanged<bool> onChanged;

  const _ToggleConfigTile({
    required this.config,
    required this.label,
    this.description,
    required this.isSuperAdmin,
    this.isDangerous = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14)),
          if (isDangerous) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '⚠️ Nguy cơ hallucination',
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.red.shade700),
              ),
            ),
          ],
        ],
      ),
      subtitle: description != null
          ? Text(description!,
              style: const TextStyle(fontSize: 12))
          : null,
      trailing: Switch(
        value: config.boolValue,
        onChanged: isSuperAdmin ? onChanged : null,
        activeThumbColor: isDangerous ? Colors.red : null,
      ),
    );
  }
}

// ── Slider (double) ───────────────────────────────────────────────────────────

class _SliderConfigTile extends StatefulWidget {
  final SystemConfig config;
  final String label;
  final String description;
  final double min, max;
  final bool isSuperAdmin;
  final ValueChanged<double> onChanged;

  const _SliderConfigTile({
    required this.config,
    required this.label,
    required this.description,
    required this.min,
    required this.max,
    required this.isSuperAdmin,
    required this.onChanged,
  });

  @override
  State<_SliderConfigTile> createState() =>
      _SliderConfigTileState();
}

class _SliderConfigTileState
    extends State<_SliderConfigTile> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.config.doubleValue;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Text(widget.label,
              style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(
            _value.toStringAsFixed(2),
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.description,
              style: const TextStyle(fontSize: 12)),
          Slider(
            value: _value,
            min: widget.min,
            max: widget.max,
            divisions: 20,
            onChanged: widget.isSuperAdmin
                ? (v) => setState(() => _value = v)
                : null,
            onChangeEnd:
                widget.isSuperAdmin ? widget.onChanged : null,
          ),
        ],
      ),
    );
  }
}

// ── Number input (int) ────────────────────────────────────────────────────────

class _NumberConfigTile extends StatefulWidget {
  final SystemConfig config;
  final String label;
  final String description;
  final int min, max;
  final bool isSuperAdmin;
  final ValueChanged<int> onChanged;

  const _NumberConfigTile({
    required this.config,
    required this.label,
    required this.description,
    required this.min,
    required this.max,
    required this.isSuperAdmin,
    required this.onChanged,
  });

  @override
  State<_NumberConfigTile> createState() =>
      _NumberConfigTileState();
}

class _NumberConfigTileState
    extends State<_NumberConfigTile> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.config.intValue.toString());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.label,
          style: const TextStyle(fontSize: 14)),
      subtitle: Text(widget.description,
          style: const TextStyle(fontSize: 12)),
      trailing: SizedBox(
        width: 80,
        child: TextField(
          controller: _ctrl,
          enabled: widget.isSuperAdmin,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onSubmitted: (v) {
            final parsed = int.tryParse(v);
            if (parsed != null &&
                parsed >= widget.min &&
                parsed <= widget.max) {
              widget.onChanged(parsed);
            }
          },
        ),
      ),
    );
  }
}

// ── Backup database ────────────────────────────────────────────────────────────

class _BackupSection extends ConsumerStatefulWidget {
  const _BackupSection();

  @override
  ConsumerState<_BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends ConsumerState<_BackupSection> {
  bool _isBackingUp = false;

  Future<void> _backupNow() async {
    setState(() => _isBackingUp = true);
    try {
      await ref.read(systemBackupRepositoryProvider).triggerBackup();
      ref.invalidate(backupsListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã tạo bản backup mới')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup thất bại: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _download(String filename) async {
    try {
      final bytes = await ref
          .read(systemBackupRepositoryProvider)
          .downloadBackup(filename);
      final jsArray = bytes.map((b) => b.toJS).toList().toJS;
      final blob = web.Blob(
        jsArray,
        web.BlobPropertyBag(type: 'application/sql'),
      );
      final url = web.URL.createObjectURL(blob);
      (web.document.createElement('a') as web.HTMLAnchorElement)
        ..href = url
        ..setAttribute('download', filename)
        ..click();
      web.URL.revokeObjectURL(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tải file thất bại: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final backupsAsync = ref.watch(backupsListProvider);

    return _ConfigSection(
      title: 'Sao lưu dữ liệu',
      icon: Icons.backup_outlined,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Backup tự động chạy mỗi ngày lúc 00:00. '
                  'Bạn cũng có thể backup thủ công bất cứ lúc nào.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _isBackingUp ? null : _backupNow,
                icon: _isBackingUp
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child:
                            CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.backup, size: 16),
                label: Text(_isBackingUp ? 'Đang backup...' : 'Backup ngay'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        backupsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Lỗi: $e'),
          ),
          data: (backups) {
            if (backups.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Chưa có bản backup nào',
                    style: TextStyle(color: Colors.grey)),
              );
            }
            return Column(
              children: backups
                  .map((b) => ListTile(
                        leading: const Icon(Icons.description_outlined,
                            size: 20),
                        title: Text(b.filename,
                            style: const TextStyle(fontSize: 13)),
                        subtitle: Text(
                          '${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(b.createdAt))} · ${_formatSize(b.sizeBytes)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.download, size: 18),
                          tooltip: 'Tải xuống',
                          onPressed: () => _download(b.filename),
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
