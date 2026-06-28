// lib/screens/home/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/destination.dart';
import '../../providers/app_state.dart';
import '../../services/destination_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/destination_card.dart';
import '../chat/chatbot_screen.dart';
import '../explore/destination_list_screen.dart';
import '../search/search_screen.dart';
import '../trip_detail/destination_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _bannerCtrl = PageController();
  Timer? _bannerTimer;
  int _bannerPage = 0;
  List<Destination> _hotDests = [];
  bool _hotLoading = true;

  List<Category> _categories = [];
  String? _selectedCategorySlug;
  List<Destination> _categoryDests = [];
  bool _catLoading = false;

  static const _regions = ['Miền Bắc', 'Miền Trung', 'Miền Nam'];
  String? _selectedRegion;
  List<Destination> _regionDests = [];
  bool _regionLoading = false;

  int _budgetTab = 0;
  List<Destination> _budgetDests = [];
  bool _budgetLoading = false;

  late int _selectedMonth;
  List<Destination> _monthDests = [];
  bool _monthLoading = false;

  List<Destination> _featuredDests = [];
  bool _featuredLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now().month;
    _loadAll();
  }

  void _loadAll() {
    _loadHot();
    _loadCategories();
    _loadRegion(null);
    _loadBudget(0);
    _loadMonth(_selectedMonth);
    _loadFeatured();
  }

  Future<void> _loadHot() async {
    setState(() => _hotLoading = true);
    try {
      final data = await DestinationRepository.fetchHot(limit: 4);
      if (!mounted) return;
      setState(() { _hotDests = data; _hotLoading = false; });
      if (data.length > 1) _startBannerTimer();
    } catch (_) {
      if (mounted) setState(() => _hotLoading = false);
    }
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || _hotDests.isEmpty) return;
      _bannerPage = (_bannerPage + 1) % _hotDests.length;
      _bannerCtrl.animateToPage(_bannerPage,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await DestinationRepository.fetchCategories();
      if (mounted) setState(() => _categories = cats);
      if (cats.isNotEmpty) _loadCategoryDests(cats.first.slug);
    } catch (_) {}
  }

  Future<void> _loadCategoryDests(String slug) async {
    setState(() { _catLoading = true; _selectedCategorySlug = slug; });
    try {
      final data = await DestinationRepository.fetchDestinations(category: slug, limit: 6);
      if (mounted) setState(() { _categoryDests = data; _catLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _catLoading = false);
    }
  }

  Future<void> _loadRegion(String? region) async {
    setState(() { _regionLoading = true; _selectedRegion = region; });
    try {
      final data = await DestinationRepository.fetchDestinations(region: region, limit: 6);
      if (mounted) setState(() { _regionDests = data; _regionLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _regionLoading = false);
    }
  }

  Future<void> _loadBudget(int tab) async {
    setState(() { _budgetLoading = true; _budgetTab = tab; });
    try {
      final data = tab == 0
          ? await DestinationRepository.fetchDestinations(budgetMax: 2000000, limit: 6)
          : await DestinationRepository.fetchDestinations(budgetMin: 2000000, limit: 6);
      if (mounted) setState(() { _budgetDests = data; _budgetLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _budgetLoading = false);
    }
  }

  Future<void> _loadMonth(int month) async {
    setState(() { _monthLoading = true; _selectedMonth = month; });
    try {
      final data = await DestinationRepository.fetchDestinations(month: month, limit: 6);
      if (mounted) setState(() { _monthDests = data; _monthLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _monthLoading = false);
    }
  }

  Future<void> _loadFeatured() async {
    setState(() => _featuredLoading = true);
    try {
      final data = await DestinationRepository.fetchDestinations(
        sortBy: 'rating',
        limit: 20,
      );
      if (mounted) setState(() { _featuredDests = data; _featuredLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _featuredLoading = false);
    }
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerCtrl.dispose();
    super.dispose();
  }

  void _openDetail(Destination d) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => DestinationDetailScreen(destination: d)));
  }

  void _openSearch() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen()));
  }

  void _openListBasic({String? region, int? budgetMax, int? budgetMin, int? month, String? category, String title = 'Địa điểm'}) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => DestinationListScreen(
        title: title,
        region: region, budgetMax: budgetMax, budgetMin: budgetMin,
        month: month, category: category,
      ),
    ));
  }

  void _openList({String? region, int? budgetMax, int? budgetMin, int? month, String? category, String sortBy = 'rating', required String title}) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => DestinationListScreen(
        title: title, region: region, budgetMax: budgetMax,
        budgetMin: budgetMin, month: month, category: category, sortBy: sortBy,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().user;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(user?.displayName ?? 'Lữ khách')),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: _TapSearchBar(onTap: _openSearch),
              ),
            ),

            SliverToBoxAdapter(child: _buildHotBanner()),
            SliverToBoxAdapter(child: _buildCategorySection()),
            SliverToBoxAdapter(child: _buildRegionSection()),
            SliverToBoxAdapter(child: _buildBudgetSection()),
            SliverToBoxAdapter(child: _buildMonthSection()),

            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
              child: SectionTitle(
                title: 'Điểm đến nổi bật',
                action: 'Xem tất cả',
                onAction: () => _openListBasic(title: 'Tất cả điểm đến'),
              ),
            )),
            _featuredLoading
                ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                : _featuredDests.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: Text('Không có điểm đến nào')),
                        ))
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            // FIX: tăng childAspectRatio để card không bị chật theo chiều dọc
                            childAspectRatio: 0.72,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => DestinationCard(
                              destination: _featuredDests[i],
                              onTap: () => _openDetail(_featuredDests[i]),
                            ),
                            childCount: _featuredDests.length,
                          ),
                        ),
                      ),
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Xin chào, $name 👋',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.dark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    const Text('Hôm nay bạn muốn khám phá đâu?',
                        style: TextStyle(fontSize: 13, color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // FIX: Tách AI card thành 2 phần riêng — info row + input row
          // để tránh overflow khi màn hình nhỏ
          GradientCard(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ChatBotScreen())),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Icon + title + subtitle
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Trợ lý AI du lịch',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                              SizedBox(height: 2),
                              Text('Lên lịch trình, hỏi đáp, gợi ý điểm đến...',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Row 2: Quick input — full width, không bị overflow
                    _QuickAiInput(
                      onSend: (msg) => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => ChatBotScreen(initialMessage: msg))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotBanner() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: SectionTitle(
            title: '🔥 Đang hot',
            action: 'Xem tất cả',
            onAction: () => _openList(sortBy: 'popular', title: 'Địa điểm hot nhất'),
          ),
        ),
        _hotLoading
            ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
            : _hotDests.isEmpty
                ? const SizedBox.shrink()
                : SizedBox(
                    // FIX: dùng LayoutBuilder để height tương đối vs screen
                    height: 200,
                    child: PageView.builder(
                      controller: _bannerCtrl,
                      itemCount: _hotDests.length,
                      onPageChanged: (i) => setState(() => _bannerPage = i),
                      itemBuilder: (_, i) => _HotBannerCard(
                        dest: _hotDests[i],
                        onTap: () => _openDetail(_hotDests[i]),
                      ),
                    ),
                  ),
        if (!_hotLoading && _hotDests.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_hotDests.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _bannerPage == i ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _bannerPage == i ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
            ),
          ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return _SectionShell(
      title: 'Theo sở thích',
      onSeeAll: _selectedCategorySlug != null
          ? () => _openListBasic(category: _selectedCategorySlug, title: 'Theo sở thích')
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = cat.slug == _selectedCategorySlug;
                return ChoiceChip(
                  label: Text(cat.name),
                  selected: selected,
                  onSelected: (_) => _loadCategoryDests(cat.slug),
                  selectedColor: AppColors.primary.withValues(alpha: 0.14),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.primary : AppColors.dark,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12.5,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _HorizontalDestList(dests: _categoryDests, loading: _catLoading, onTap: _openDetail),
        ],
      ),
    );
  }

  Widget _buildRegionSection() {
    return _SectionShell(
      title: 'Theo khu vực',
      onSeeAll: () => _openListBasic(region: _selectedRegion, title: 'Theo khu vực'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _RegionChip(label: 'Tất cả', selected: _selectedRegion == null,
                    onTap: () => _loadRegion(null)),
                ..._regions.map((r) => _RegionChip(
                  label: r, selected: _selectedRegion == r,
                  onTap: () => _loadRegion(r),
                )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _HorizontalDestList(dests: _regionDests, loading: _regionLoading, onTap: _openDetail),
        ],
      ),
    );
  }

  Widget _buildBudgetSection() {
    return _SectionShell(
      title: 'Theo ngân sách',
      onSeeAll: () => _openListBasic(
        budgetMax: _budgetTab == 0 ? 2000000 : null,
        budgetMin: _budgetTab == 1 ? 2000000 : null,
        title: _budgetTab == 0 ? 'Dưới 2 triệu/ngày' : 'Trên 2 triệu/ngày',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _BudgetTab(label: '≤ 2 triệu/ngày', selected: _budgetTab == 0, onTap: () => _loadBudget(0)),
                  _BudgetTab(label: '> 2 triệu/ngày', selected: _budgetTab == 1, onTap: () => _loadBudget(1)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _HorizontalDestList(dests: _budgetDests, loading: _budgetLoading, onTap: _openDetail),
        ],
      ),
    );
  }

  Widget _buildMonthSection() {
    const monthNames = ['T1','T2','T3','T4','T5','T6','T7','T8','T9','T10','T11','T12'];
    return _SectionShell(
      title: 'Theo mùa (Tháng $_selectedMonth)',
      onSeeAll: () => _openListBasic(month: _selectedMonth, title: 'Đi tháng $_selectedMonth'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 12,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final m = i + 1;
                final selected = m == _selectedMonth;
                return GestureDetector(
                  onTap: () => _loadMonth(m),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    // FIX: T10/T11/T12 cần rộng hơn một chút
                    width: monthNames[i].length > 2 ? 44 : 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      monthNames[i],
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : AppColors.dark,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _HorizontalDestList(dests: _monthDests, loading: _monthLoading, onTap: _openDetail),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Search bar (fake tap)
// ─────────────────────────────────────────────
class _TapSearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const _TapSearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search_rounded, color: AppColors.muted, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Tìm địa điểm, tỉnh thành...',
                style: TextStyle(fontSize: 14, color: AppColors.muted),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Tìm kiếm',
                style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Shared sub-widgets
// ─────────────────────────────────────────────
class _SectionShell extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onSeeAll;
  const _SectionShell({required this.title, required this.child, this.onSeeAll});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
        child: SectionTitle(title: title, action: onSeeAll != null ? 'Xem tất cả' : null, onAction: onSeeAll),
      ),
      child,
    ],
  );
}

class _HotBannerCard extends StatelessWidget {
  final Destination dest;
  final VoidCallback onTap;
  const _HotBannerCard({required this.dest, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            dest.imageUrl.isNotEmpty
                ? Image.network(dest.imageUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.primary.withValues(alpha: 0.2)))
                : Container(color: AppColors.primary.withValues(alpha: 0.2)),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.72)],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 14, left: 14, right: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dest.name,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on, color: Colors.white70, size: 13),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(dest.province ?? dest.region,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                    const SizedBox(width: 3),
                    Text(dest.ratingAvg > 0 ? dest.ratingAvg.toStringAsFixed(1) : '–',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    const Icon(Icons.visibility_outlined, color: Colors.white70, size: 13),
                    const SizedBox(width: 3),
                    Text('${dest.viewCount}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// FIX: Tăng chiều cao card list + width để text không bị cắt
class _HorizontalDestList extends StatelessWidget {
  final List<Destination> dests;
  final bool loading;
  final void Function(Destination) onTap;
  const _HorizontalDestList({required this.dests, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (loading) return const SizedBox(height: 160, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    if (dests.isEmpty) return const SizedBox(
      height: 60,
      child: Center(child: Text('Không có địa điểm phù hợp', style: TextStyle(color: AppColors.muted, fontSize: 13))),
    );
    return SizedBox(
      height: 180, // FIX: tăng từ 170 → 180
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: dests.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final d = dests[i];
          return GestureDetector(
            onTap: () => onTap(d),
            child: Container(
              width: 150, // FIX: tăng từ 140 → 150
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: d.imageUrl.isNotEmpty
                          ? Image.network(d.imageUrl, width: double.infinity, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: AppColors.primary.withValues(alpha: 0.1),
                                  child: const Icon(Icons.landscape_outlined, color: AppColors.primary)))
                          : Container(color: AppColors.primary.withValues(alpha: 0.1),
                              child: const Icon(Icons.landscape_outlined, color: AppColors.primary)),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(9, 6, 9, 7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(d.name,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.dark),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          Row(children: [
                            const Icon(Icons.star_rounded, size: 11, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 2),
                            Text(d.ratingAvg > 0 ? d.ratingAvg.toStringAsFixed(1) : '–',
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.muted)),
                            const SizedBox(width: 6),
                            const Icon(Icons.favorite_border, size: 10, color: AppColors.error),
                            const SizedBox(width: 2),
                            Text('${d.favoriteCount}', style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
                          ]),
                        ],
                      ),
                    ),
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

class _RegionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RegionChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? AppColors.primary : AppColors.border),
      ),
      child: Text(label, style: TextStyle(
        color: selected ? Colors.white : AppColors.dark,
        fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      )),
    ),
  );
}

class _BudgetTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _BudgetTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(
          color: selected ? Colors.white : AppColors.muted,
          // FIX: giảm fontSize để label vừa trên màn hình nhỏ
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        )),
      ),
    ),
  );
}

// FIX: _QuickAiInput — layout full width thay vì nhét vào Row
// (giờ được đặt ở Row 2 trong _buildHeader, không còn cạnh tranh chỗ với title)
class _QuickAiInput extends StatefulWidget {
  final void Function(String) onSend;
  const _QuickAiInput({required this.onSend});

  @override
  State<_QuickAiInput> createState() => _QuickAiInputState();
}

class _QuickAiInputState extends State<_QuickAiInput> {
  bool _expanded = false;
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!_expanded) {
      return Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined, color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text('Hỏi ngay',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChatBotScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'Mở trợ lý →',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      );
    }
    // Expanded: full-width input
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Hỏi về du lịch...',
                hintStyle: TextStyle(color: Colors.white60, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onSubmitted: (t) {
                if (t.trim().isNotEmpty) widget.onSend(t.trim());
                setState(() { _expanded = false; _ctrl.clear(); });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white, size: 18),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            onPressed: () {
              final t = _ctrl.text.trim();
              if (t.isNotEmpty) widget.onSend(t);
              setState(() { _expanded = false; _ctrl.clear(); });
            },
          ),
        ],
      ),
    );
  }
}
