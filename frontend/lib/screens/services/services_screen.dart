import 'package:flutter/material.dart';
import '../../services/travel_api.dart';
import '../../widgets/common_widgets.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  Map<String, dynamic> results = {'hotels': [], 'tours': [], 'tickets': []};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load({String q = ''}) async {
    setState(() => loading = true);
    final data = await ServicesApi.search(q: q);
    if (mounted) setState(() { results = data; loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Tra cứu dịch vụ', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(icon: Icon(Icons.hotel), text: 'Khách sạn'),
            Tab(icon: Icon(Icons.tour), text: 'Tour'),
            Tab(icon: Icon(Icons.confirmation_number), text: 'Vé'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên, địa điểm...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: () => _load(q: _searchCtrl.text)),
              ),
              onSubmitted: (q) => _load(q: q),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _ServiceList(items: results['hotels'] ?? [], type: 'hotel'),
                      _ServiceList(items: results['tours'] ?? [], type: 'tour'),
                      _ServiceList(items: results['tickets'] ?? [], type: 'ticket'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ServiceList extends StatelessWidget {
  final List<dynamic> items;
  final String type;

  const _ServiceList({required this.items, required this.type});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text('Không có dữ liệu. Khởi động backend để tải dịch vụ.', style: TextStyle(color: AppColors.muted)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      type == 'hotel' ? Icons.hotel : type == 'tour' ? Icons.tour : Icons.confirmation_number,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(item['destination'] ?? '', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (type == 'hotel') ...[
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    Text(' ${item['rating']} ', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('• ${item['type']}', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${formatCurrency(item['price_per_night'] ?? 0)}/đêm', style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                if ((item['address'] ?? '').isNotEmpty) Text('📍 ${item['address']}', style: TextStyle(fontSize: 12, color: AppColors.muted)),
              ],
              if (type == 'tour') ...[
                Text('⏱ ${item['duration']}', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                Text('${formatCurrency(item['price'] ?? 0)}', style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                if ((item['description'] ?? '').isNotEmpty) Text(item['description'], style: TextStyle(fontSize: 13, color: AppColors.muted)),
              ],
              if (type == 'ticket') ...[
                Text('${formatCurrency(item['price'] ?? 0)}', style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                if ((item['description'] ?? '').isNotEmpty) Text(item['description'], style: TextStyle(fontSize: 13, color: AppColors.muted)),
              ],
            ],
          ),
        );
      },
    );
  }
}
