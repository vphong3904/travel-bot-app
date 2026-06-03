import 'package:flutter/material.dart';
import '../../services/travel_api.dart';
import '../../widgets/common_widgets.dart';

class KBManagementScreen extends StatefulWidget {
  const KBManagementScreen({super.key});

  @override
  State<KBManagementScreen> createState() => _KBManagementScreenState();
}

class _KBManagementScreenState extends State<KBManagementScreen> {
  List<dynamic> entries = [];
  bool loading = true;
  String? filterCategory;

  final categories = ['weather', 'budget', 'cuisine', 'tips', 'itinerary', 'transport', 'recommendation'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final data = await AdminService.getKB(category: filterCategory);
    if (mounted) setState(() { entries = data; loading = false; });
  }

  Future<void> _showForm({Map<String, dynamic>? entry}) async {
    final titleCtrl = TextEditingController(text: entry?['title'] ?? '');
    final contentCtrl = TextEditingController(text: entry?['content'] ?? '');
    final destCtrl = TextEditingController(text: entry?['destination'] ?? '');
    final tagsCtrl = TextEditingController(text: entry?['tags'] ?? '');
    String category = entry?['category'] ?? 'tips';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(entry == null ? 'Thêm KB Entry' : 'Sửa KB Entry', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tiêu đề')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: category,
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => category = v ?? 'tips',
                decoration: const InputDecoration(labelText: 'Danh mục'),
              ),
              const SizedBox(height: 12),
              TextField(controller: destCtrl, decoration: const InputDecoration(labelText: 'Điểm đến (tùy chọn)')),
              const SizedBox(height: 12),
              TextField(controller: contentCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Nội dung')),
              const SizedBox(height: 12),
              TextField(controller: tagsCtrl, decoration: const InputDecoration(labelText: 'Tags')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final data = {'title': titleCtrl.text, 'category': category, 'destination': destCtrl.text, 'content': contentCtrl.text, 'tags': tagsCtrl.text};
                  if (entry == null) {
                    await AdminService.createKB(data);
                  } else {
                    await AdminService.updateKB(entry['id'], data);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  _load();
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: Text(entry == null ? 'Thêm' : 'Cập nhật'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Knowledge Base', style: TextStyle(fontWeight: FontWeight.bold))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: [
                FilterChip(label: const Text('Tất cả'), selected: filterCategory == null, onSelected: (_) { filterCategory = null; _load(); }),
                ...categories.map((c) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: FilterChip(label: Text(c), selected: filterCategory == c, onSelected: (_) { filterCategory = c; _load(); }),
                    )),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    itemBuilder: (_, i) {
                      final e = entries[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(e['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${e['category']} • ${e['destination'] ?? 'Chung'}', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                          trailing: PopupMenuButton(
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                              const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: AppColors.error))),
                            ],
                            onSelected: (v) async {
                              if (v == 'edit') _showForm(entry: e);
                              if (v == 'delete') {
                                await AdminService.deleteKB(e['id']);
                                _load();
                              }
                            },
                          ),
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(e['title'] ?? ''),
                              content: SingleChildScrollView(child: Text(e['content'] ?? '')),
                              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
