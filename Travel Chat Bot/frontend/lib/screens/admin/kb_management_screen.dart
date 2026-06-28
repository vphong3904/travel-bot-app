import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../services/admin_api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/web_layout.dart';

class KBManagementScreen extends StatefulWidget {
  const KBManagementScreen({super.key});

  @override
  State<KBManagementScreen> createState() => _KBManagementScreenState();
}

class _KBManagementScreenState extends State<KBManagementScreen> {
  late AdminApiService _api;
  List<dynamic> entries = [];
  List<dynamic> filtered = [];
  bool loading = true;
  String? filterCategory;
  final _searchCtrl = TextEditingController();

  final categories = ['weather', 'budget', 'cuisine', 'tips', 'itinerary', 'transport', 'recommendation'];

  @override
  void initState() {
    super.initState();
    final token = context.read<AppState>().token;
    _api = AdminApiService(token: token);
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final data = await _api.getKB(category: filterCategory);
      if (mounted) {
        setState(() {
          entries = data;
          _applyFilter();
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { loading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    filtered = entries.where((e) {
      if (q.isEmpty) return true;
      final text = '${e['title']} ${e['content']} ${e['destination']} ${e['tags']}'.toLowerCase();
      return text.contains(q);
    }).toList();
  }

  Future<void> _showForm({Map<String, dynamic>? entry}) async {
    final titleCtrl   = TextEditingController(text: entry?['title'] ?? '');
    final contentCtrl = TextEditingController(text: entry?['content'] ?? '');
    final destCtrl    = TextEditingController(text: entry?['destination'] ?? '');
    final tagsCtrl    = TextEditingController(text: entry?['tags'] ?? '');
    String category   = entry?['category'] ?? 'tips';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  entry == null ? 'Thêm KB Entry' : 'Sửa KB Entry',
                  style: AppTheme.heading(size: 18),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Tiêu đề'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(kbCategoryLabel(c))))
                      .toList(),
                  onChanged: (v) => setModalState(() => category = v ?? 'tips'),
                  decoration: const InputDecoration(labelText: 'Danh mục'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: destCtrl,
                  decoration: const InputDecoration(labelText: 'Điểm đến (tùy chọn)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Nội dung'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tagsCtrl,
                  decoration: const InputDecoration(labelText: 'Tags'),
                ),
                const SizedBox(height: 16),
                AppPrimaryButton(
                  label: entry == null ? 'Thêm' : 'Cập nhật',
                  onPressed: () async {
                    final data = {
                      'title':       titleCtrl.text.trim(),
                      'category':    category,
                      'destination': destCtrl.text.trim(),
                      'content':     contentCtrl.text.trim(),
                      'tags':        tagsCtrl.text.trim(),
                    };
                    if ((data['title'] ?? '').isEmpty || (data['content'] ?? '').isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Vui lòng nhập tiêu đề và nội dung')),
                      );
                      return;
                    }
                    final ok = entry == null
                        ? await _api.createKB(data)
                        : await _api.updateKB((entry['id'] ?? '').toString(), data);
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok ? 'Lưu thành công' : 'Lưu thất bại'),
                        backgroundColor: ok ? AppColors.success : AppColors.error,
                      ),
                    );
                    _load();
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WebAdminShell(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text('Knowledge Base', style: AppTheme.heading(size: 18)),
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showForm(),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add_rounded),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: AppSearchBar(
                controller: _searchCtrl,
                hint: 'Tìm tiêu đề, nội dung, điểm đến...',
                margin: EdgeInsets.zero,
                onChanged: (_) => setState(_applyFilter),
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  FilterChip(
                    label: const Text('Tất cả'),
                    selected: filterCategory == null,
                    onSelected: (_) {
                      setState(() => filterCategory = null);
                      _load();
                    },
                  ),
                  ...categories.map((c) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(kbCategoryLabel(c)),
                      selected: filterCategory == c,
                      onSelected: (_) {
                        setState(() => filterCategory = c);
                        _load();
                      },
                    ),
                  )),
                ],
              ),
            ),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : filtered.isEmpty
                      ? Center(
                          child: Text(
                            'Không có dữ liệu KB',
                            style: AppTheme.body(color: AppColors.muted),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final e = filtered[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                              ),
                              child: ListTile(
                                title: Text(
                                  e['title'] ?? '',
                                  style: AppTheme.body(size: 15, weight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  '${kbCategoryLabel(e['category'] ?? '')} · '
                                  '${(e['destination']?.toString().isEmpty ?? true) ? 'Chung' : e['destination']}',
                                  style: AppTheme.body(size: 12, color: AppColors.muted),
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(value: 'edit', child: Text('Sửa')),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Xóa', style: TextStyle(color: AppColors.error)),
                                    ),
                                  ],
                                  onSelected: (v) async {
                                    if (v == 'edit') _showForm(entry: e);
                                    if (v == 'delete') {
                                      final ok = await _api.deleteKB((e['id'] ?? '').toString());
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(ok ? 'Đã xóa' : 'Xóa thất bại'),
                                          backgroundColor: ok ? AppColors.success : AppColors.error,
                                        ),
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