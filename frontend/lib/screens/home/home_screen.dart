import 'package:flutter/material.dart';

import '../../models/destination.dart';
import '../../services/destination_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/destination_card.dart';
import '../../widgets/recommendation_carousel.dart';
import '../chat/chatbot_screen.dart';
import '../trip_detail/destination_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  final categories = [
    {'label': 'Tất cả', 'tag': ''},
    {'label': 'Biển', 'tag': 'biển'},
    {'label': 'Núi', 'tag': 'núi'},
    {'label': 'Nghỉ dưỡng', 'tag': 'nghỉ dưỡng'},
    {'label': 'Khám phá', 'tag': 'khám phá'},
  ];

  List<Destination> _allDestinations = [];
  List<Destination> _filteredDestinations = [];
  bool _loading = true;
  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    _loadDestinations();
    _searchCtrl.addListener(() => _search(_searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDestinations({String? tag}) async {
    setState(() => _loading = true);
    final data = await DestinationRepository.fetchDestinations(tag: tag);
    if (!mounted) return;

    setState(() {
      _allDestinations = data;
      _filteredDestinations = data;
      _loading = false;
    });
  }

  void _search(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredDestinations = [..._allDestinations];
      } else {
        _filteredDestinations = _allDestinations.where((item) {
          final content = '${item.name} ${item.description} ${item.region} ${item.tags.join(' ')}'.toLowerCase();
          return content.contains(q);
        }).toList();
      }
    });
  }

  void _selectCategory(int index) {
    setState(() => _selectedCategory = index);
    _loadDestinations(tag: categories[index]['tag'] as String?);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.bg,
              expandedHeight: 120,
              pinned: true,
              toolbarHeight: 80,
              elevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Xin chào, Lữ khách!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.dark)),
                    SizedBox(height: 6),
                    Text('Khám phá hành trình, điểm đến và trải nghiệm mới.', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSearchBar(
                      controller: _searchCtrl,
                      hint: 'Tìm địa điểm, trải nghiệm, dịch vụ...',
                    ),
                    const SizedBox(height: 16),
                    GradientCard(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Gợi ý hành trình cá nhân hoá', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            const Text('Slide bên dưới sẽ tự động hiển thị đề xuất mới mỗi vài giây.', style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ChatBotScreen(autoPrompt: true)),
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary),
                              child: const Text('Thử AI ngay'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    RecommendationCarousel(destinations: _allDestinations),
                    const SizedBox(height: 20),
                    const SectionTitle(title: 'Điểm đến nổi bật'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final selected = _selectedCategory == index;
                          return ChoiceChip(
                            label: Text(category['label'] as String),
                            selected: selected,
                            onSelected: (_) => _selectCategory(index),
                            selectedColor: AppColors.primary.withValues(alpha: 0.16),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(color: selected ? AppColors.primary : AppColors.dark, fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (_filteredDestinations.isEmpty)
              const SliverFillRemaining(child: Center(child: Text('Chưa có điểm đến phù hợp. Thử lọc khác nhé!')))
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final destination = _filteredDestinations[index];
                      return DestinationCard(
                        destination: destination,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DestinationDetailScreen(destination: destination),
                            ),
                          );
                        },
                      );
                    },
                    childCount: _filteredDestinations.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}
