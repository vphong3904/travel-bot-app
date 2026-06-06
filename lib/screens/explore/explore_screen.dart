import 'package:flutter/material.dart';
import '../../services/travel_api.dart';
import '../../widgets/common_widgets.dart';
import '../chat/intent_setup_screen.dart';
import '../trip_detail/destination_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<dynamic> destinations = [];
  List<dynamic> filtered = [];
  bool loading = true;
  final _searchCtrl = TextEditingController();

  final categories = [
    {'label': 'Tất cả', 'tag': ''},
    {'label': 'Biển', 'tag': 'biển'},
    {'label': 'Núi', 'tag': 'núi'},
    {'label': 'Nghỉ dưỡng', 'tag': 'nghỉ dưỡng'},
    {'label': 'Khám phá', 'tag': 'khám phá'},
  ];
  int selectedCat = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String? tag}) async {
    setState(() => loading = true);
    final data = await DestinationService.getDestinations(tag: tag?.isEmpty == true ? null : tag);
    if (mounted) {
      setState(() {
        destinations = data;
        filtered = data;
        loading = false;
      });
    }
  }

  void _search(String q) {
    setState(() {
      filtered = destinations.where((d) {
        final text = '${d['name']} ${d['description']} ${d['tags']}'.toLowerCase();
        return text.contains(q.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Xin chào, Lữ khách! 👋', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark)),
                  Text('Hôm nay bạn muốn đi đâu?', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchCtrl,
                    onChanged: _search,
                    decoration: InputDecoration(
                      hintText: 'Tìm địa điểm, món ăn, khách sạn...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); _search(''); })
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GradientCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                              SizedBox(width: 8),
                              Text('Lên lịch trình thông minh bằng AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('Nhập sở thích, ngân sách & thời gian — AI thiết kế chuyến đi tối ưu trong vài giây.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IntentSetupScreen())),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white),
                            child: const Text('Thử ngay với AI'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (_, i) {
                        final cat = categories[i];
                        final selected = selectedCat == i;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(cat['label']!),
                            selected: selected,
                            onSelected: (_) {
                              setState(() => selectedCat = i);
                              _load(tag: cat['tag']);
                            },
                            selectedColor: AppColors.primary.withValues(alpha: 0.15),
                            checkmarkColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SectionTitle(title: 'Điểm đến nổi bật'),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          if (loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (filtered.isEmpty)
            const SliverFillRemaining(child: Center(child: Text('Không tìm thấy địa điểm')))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _DestinationCard(
                    dest: filtered[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DestinationDetailScreen(destination: filtered[i])),
                    ),
                  ),
                  childCount: filtered.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final Map<String, dynamic> dest;
  final VoidCallback onTap;

  const _DestinationCard({required this.dest, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  dest['image_url'] ?? '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.landscape, size: 48, color: AppColors.primary),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dest['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(dest['region'] ?? '', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                    const Spacer(),
                    Text(
                      '${formatCurrency(dest['budget_low'] ?? 0)} - ${formatCurrency(dest['budget_high'] ?? 0)}',
                      style: const TextStyle(fontSize: 10, color: AppColors.secondary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
