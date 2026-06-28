// lib/admin/web/screens/intent_patterns_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/data/intent_patterns_repository.dart';
import '../../shared/models/intent_patterns_models.dart';
import '../../shared/providers/intent_patterns_provider.dart';

class IntentPatternsScreen extends ConsumerStatefulWidget {
  const IntentPatternsScreen({super.key});

  @override
  ConsumerState<IntentPatternsScreen> createState() =>
      _IntentPatternsScreenState();
}

class _IntentPatternsScreenState
    extends ConsumerState<IntentPatternsScreen> {
  final _testController = TextEditingController();
  bool _isTesting = false;

  @override
  void dispose() {
    _testController.dispose();
    super.dispose();
  }

  Future<void> _runTest() async {
    final text = _testController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isTesting = true);
    try {
      final result = await ref
          .read(intentPatternsRepositoryProvider)
          .testText(text);
      ref.read(intentTestResultProvider.notifier).state = result;
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final patternsAsync = ref.watch(intentPatternsProvider);
    final selectedIntent = ref.watch(selectedIntentProvider);
    final testResult = ref.watch(intentTestResultProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Intent Patterns',
            style:
                TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Quản lý keyword intent — thay đổi có hiệu lực ngay, không cần deploy lại',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Test panel
          _TestPanel(
            controller: _testController,
            isTesting: _isTesting,
            result: testResult,
            onTest: _runTest,
          ),
          const SizedBox(height: 16),

          // Main body
          Expanded(
            child: patternsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Lỗi: $e')),
              data: (patterns) {
                final selected = selectedIntent != null
                    ? patterns
                        .where((p) => p.intent == selectedIntent)
                        .firstOrNull
                    : null;
                if (selectedIntent == null && patterns.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(selectedIntentProvider.notifier).state =
                        patterns.first.intent;
                  });
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 220,
                      child: _IntentSidebar(
                        patterns: patterns,
                        selected: selectedIntent,
                        testResult: testResult,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: selected == null
                          ? const Center(
                              child: Text('Chọn intent bên trái'))
                          : _KeywordPanel(pattern: selected),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Test panel ────────────────────────────────────────────────────────────────

class _TestPanel extends StatelessWidget {
  final TextEditingController controller;
  final bool isTesting;
  final IntentTestResult? result;
  final VoidCallback onTest;

  const _TestPanel({
    required this.controller,
    required this.isTesting,
    required this.result,
    required this.onTest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Nhập câu hỏi để test...',
                    isDense: true,
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (_) => onTest(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: isTesting ? null : onTest,
                child: isTesting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child:
                            CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Test'),
              ),
            ],
          ),
          if (result != null) ...[
            const SizedBox(height: 10),
            _TestResultRow(result: result!),
          ],
        ],
      ),
    );
  }
}

class _TestResultRow extends StatelessWidget {
  final IntentTestResult result;
  const _TestResultRow({required this.result});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _Badge(
          label:
              'Intent: ${result.intent} (${(result.confidence * 100).toStringAsFixed(0)}%)',
          color: Colors.indigo,
        ),
        ...result.matchedKeywords.map((kw) => _Badge(
              label: '"$kw"',
              color: Colors.teal,
            )),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final MaterialColor color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.shade200),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12,
              color: color.shade800,
              fontWeight: FontWeight.w500)),
    );
  }
}

// ── Intent sidebar ────────────────────────────────────────────────────────────

class _IntentSidebar extends ConsumerWidget {
  final List<IntentPattern> patterns;
  final String? selected;
  final IntentTestResult? testResult;

  const _IntentSidebar({
    required this.patterns,
    required this.selected,
    required this.testResult,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        itemCount: patterns.length,
        itemBuilder: (_, i) {
          final p = patterns[i];
          final isSelected = p.intent == selected;
          final isDetected = testResult?.intent == p.intent;
          return InkWell(
            onTap: () => ref
                .read(selectedIntentProvider.notifier)
                .state = p.intent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue.shade50
                    : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color: isSelected
                        ? Colors.blue
                        : Colors.transparent,
                    width: 3,
                  ),
                  bottom: BorderSide(color: Colors.grey.shade100),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.intent,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          '${p.keywords.length} keywords',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (isDetected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '✓',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.green.shade700),
                      ),
                    ),
                  if (p.collisionWarnings.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(Icons.warning_amber,
                          size: 14,
                          color: Colors.orange.shade600),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Keyword panel ─────────────────────────────────────────────────────────────

class _KeywordPanel extends ConsumerStatefulWidget {
  final IntentPattern pattern;
  const _KeywordPanel({required this.pattern});

  @override
  ConsumerState<_KeywordPanel> createState() =>
      _KeywordPanelState();
}

class _KeywordPanelState extends ConsumerState<_KeywordPanel> {
  bool _showAddInput = false;
  final _addController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  Future<void> _addKeyword() async {
    final kw = _addController.text.trim();
    if (kw.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await ref
          .read(intentPatternsRepositoryProvider)
          .addKeyword(widget.pattern.intent, kw);
      ref.invalidate(intentPatternsProvider);
      _addController.clear();
      setState(() => _showAddInput = false);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteKeyword(String keyword) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá keyword?'),
        content:
            Text('Xoá "$keyword" khỏi ${widget.pattern.intent}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Huỷ')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade600),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(intentPatternsRepositoryProvider)
        .deleteKeyword(widget.pattern.intent, keyword);
    ref.invalidate(intentPatternsProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8)),
              border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Text(
                  widget.pattern.intent,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.pattern.keywords.length} keywords',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Thêm keyword'),
                  onPressed: () => setState(
                      () => _showAddInput = !_showAddInput),
                ),
              ],
            ),
          ),
          if (widget.pattern.collisionWarnings.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(6),
                border:
                    Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber,
                      size: 16, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Collision với tên tỉnh: ${widget.pattern.collisionWarnings.join(", ")}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade800),
                    ),
                  ),
                ],
              ),
            ),
          if (_showAddInput)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _AddKeywordRow(
                controller: _addController,
                isSaving: _isSaving,
                onAdd: _addKeyword,
                onCancel: () {
                  _addController.clear();
                  setState(() => _showAddInput = false);
                },
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.pattern.keywords
                    .map((kw) => _KeywordChip(
                          keyword: kw,
                          onDelete: () =>
                              _deleteKeyword(kw.keyword),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddKeywordRow extends StatelessWidget {
  final TextEditingController controller;
  final bool isSaving;
  final VoidCallback onAdd;
  final VoidCallback onCancel;

  const _AddKeywordRow({
    required this.controller,
    required this.isSaving,
    required this.onAdd,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Nhập keyword mới...',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => onAdd(),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: isSaving ? null : onAdd,
          child: isSaving
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child:
                      CircularProgressIndicator(strokeWidth: 2))
              : const Text('Lưu'),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: onCancel,
          child: const Text('Huỷ'),
        ),
      ],
    );
  }
}

class _KeywordChip extends StatelessWidget {
  final IntentKeyword keyword;
  final VoidCallback onDelete;

  const _KeywordChip(
      {required this.keyword, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isCollision = keyword.isCollision;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isCollision
            ? Colors.orange.shade50
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCollision
              ? Colors.orange.shade300
              : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCollision) ...[
            Icon(Icons.warning_amber,
                size: 13, color: Colors.orange.shade700),
            const SizedBox(width: 4),
          ],
          Text(
            keyword.keyword,
            style: TextStyle(
              fontSize: 13,
              color: isCollision
                  ? Colors.orange.shade800
                  : Colors.grey.shade800,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.close,
              size: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
