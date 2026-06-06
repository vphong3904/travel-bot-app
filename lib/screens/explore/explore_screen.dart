import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../services/travel_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/network_image_widget.dart';
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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
    final userName = context.watch<AppState>().user?.name ?? 'Lữ khách';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Xin chào, $userName', style: AppTheme.heading(size: 22)),
                  const SizedBox(height: 2),
                  Text('Hôm nay bạn muốn đi đâu?', style: AppTheme.body(size: 13, color: AppColors.muted)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AppSearchBar(
              controller: _searchCtrl,
              hint: 'Tìm địa điểm, món ăn, khách sạn...',
              onChanged: _search,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GradientCard(
                padding: const EdgeInsets.all(20),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      right: -8,
                      bottom: -16,
                      child: Icon(Icons.auto_awesome_rounded, size: 72, color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('AI POWERED', style: AppTheme.body(size: 11, color: Colors.white, weight: FontWeight.w700)),
                        ),
                        const SizedBox(height: 10),
                        Text('Lên lịch trình thông minh cùng AI', style: AppTheme.heading(size: 18, color: Colors.white)),
                        const SizedBox(height: 6),
                        Text(
                          'Nhập sở thích, ngân sách & thời gian — AI thiết kế chuyến đi tối ưu.',
                          style: AppTheme.body(size: 12, color: Colors.white.withValues(alpha: 0.9)),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IntentSetupScreen())),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Thử ngay', style: AppTheme.body(size: 13, color: AppColors.primary, weight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                itemCount: categories.length,
                itemBuilder: (_, i) {
                  final cat = categories[i];
                  final selected = selectedCat == i;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AppChoiceChip(
                      label: cat['label']!,
                      selected: selected,
                      onTap: () {
                        setState(() => selectedCat = i);
                        _load(tag: cat['tag']);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: SectionTitle(title: 'Điểm đến nổi bật', action: 'Xem thêm'),
            ),
          ),
          if (loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
          else if (filtered.isEmpty)
            SliverFillRemaining(child: Center(child: Text('Không tìm thấy địa điểm', style: AppTheme.body(color: AppColors.muted))))
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 88),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
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
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(
                    url: dest['image_url'],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFBBF24)),
                          const SizedBox(width: 2),
                          Text('4.8', style: AppTheme.body(size: 11, weight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dest['name'] ?? '', style: AppTheme.heading(size: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: AppColors.muted),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(dest['region'] ?? '', style: AppTheme.body(size: 11, color: AppColors.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '${formatCurrency(dest['budget_low'] ?? 0)} - ${formatCurrency(dest['budget_high'] ?? 0)}/người',
                      style: AppTheme.body(size: 12, color: AppColors.accent, weight: FontWeight.w700),
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
