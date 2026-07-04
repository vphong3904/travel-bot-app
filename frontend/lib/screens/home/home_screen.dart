// lib/screens/home/home_screen.dart
// Explore (Khám phá) — thiết kế lại gọn gàng, giảm lặp:
//   Header → Search → Hero "Đang hot" → Khám phá nhanh (shortcut) →
//   Theo sở thích (category interactive) → Gợi ý cho bạn → Điểm đến nổi bật.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/destination.dart';
import '../../providers/app_state.dart';
import '../../services/destination_service.dart';
import '../../services/favorite_api_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/destination_card.dart';
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

  List<Destination> _forYou = [];
  bool _forYouLoading = false;

  List<Destination> _featuredDests = [];
  bool _featuredLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHot();
    _loadCategories();
    _loadFeatured();
    _loadForYou();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerCtrl.dispose();
    super.dispose();
  }

  // ── Loaders ────────────────────────────────────────────────────────────────
  Future<void> _loadHot() async {
    setState(() => _hotLoading = true);
    try {
      final data = await DestinationRepository.fetchHot(limit: 5);
      if (!mounted) return;
      setState(() { _hotDests = data; _hotLoading = false; });
      if (data.length > 1) _startBannerTimer();
    } catch (_) {
      if (mounted) setState(() => _hotLoading = false);
    }
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
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
      final data = await DestinationRepository.fetchDestinations(category: slug, limit: 8);
      if (mounted) setState(() { _categoryDests = data; _catLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _catLoading = false);
    }
  }

  Future<void> _loadFeatured() async {
    setState(() => _featuredLoading = true);
    try {
      final data = await DestinationRepository.fetchDestinations(sortBy: 'rating', limit: 20);
      if (mounted) setState(() { _featuredDests = data; _featuredLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _featuredLoading = false);
    }
  }

  Future<void> _loadForYou() async {
    final s = context.read<AppState>();
    if (!s.isLoggedIn) return;
    setState(() => _forYouLoading = true);
    try {
      final favs = await FavoriteApiService(token: s.token ?? '').listMyFavorites();
      if (favs.isEmpty) {
        if (mounted) setState(() { _forYou = []; _forYouLoading = false; });
        return;
      }
      final counts = <String, int>{};
      for (final d in favs) {
        for (final c in d.categories) {
          if (c.slug.isNotEmpty) counts[c.slug] = (counts[c.slug] ?? 0) + 1;
        }
      }
      if (counts.isEmpty) {
        if (mounted) setState(() { _forYou = []; _forYouLoading = false; });
        return;
      }
      final topSlug = counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      final favIds = favs.map((d) => d.id).toSet();
      final recs = await DestinationRepository.fetchDestinations(category: topSlug, limit: 8);
      final filtered = recs.where((d) => !favIds.contains(d.id)).toList();
      if (mounted) setState(() { _forYou = filtered; _forYouLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _forYouLoading = false);
    }
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
  void _openDetail(Destination d) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => DestinationDetailScreen(destination: d)));

  void _openSearch() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const SearchScreen()));

  void _openList({
    String? region, int? budgetMax, int? budgetMin, int? month, String? category,
    String sortBy = 'rating', required String title,
  }) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => DestinationListScreen(
        title: title, region: region, budgetMax: budgetMax,
        budgetMin: budgetMin, month: month, category: category, sortBy: sortBy,
      ),
    ));
  }

  Future<void> _refresh() async {
    await Future.wait([_loadHot(), _loadFeatured(), _loadForYou()]);
    if (_selectedCategorySlug != null) await _loadCategoryDests(_selectedCategorySlug!);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().user;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _refresh,
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
              SliverToBoxAdapter(child: _buildQuickExplore()),
              SliverToBoxAdapter(child: _buildCategorySection()),
              SliverToBoxAdapter(child: _buildForYouSection()),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 26, 16, 10),
                child: SectionTitle(
                  title: 'Điểm đến nổi bật',
                  action: 'Xem tất cả',
                  onAction: () => _openList(title: 'Tất cả điểm đến'),
                ),
              )),
              _featuredLoading
                  ? const SliverToBoxAdapter(
                      child: Padding(padding: EdgeInsets.all(40),
                          child: Center(child: CircularProgressIndicator())))
                  : _featuredDests.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Padding(padding: EdgeInsets.all(32),
                              child: Center(child: Text('Không có điểm đến nào'))))
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, childAspectRatio: 0.72,
                              mainAxisSpacing: 14, crossAxisSpacing: 14,
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
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Xin chào, $name 👋',
                    style: const TextStyle(
                        fontSize: 21, fontWeight: FontWeight.bold, color: AppColors.dark),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                const Text('Hôm nay bạn muốn đi đâu?',
                    style: TextStyle(fontSize: 13.5, color: AppColors.muted)),
              ],
            ),
          ),
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(initial,
                style: const TextStyle(
                    color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Hero "Đang hot" ─────────────────────────────────────────────────────────
  Widget _buildHotBanner() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
          child: SectionTitle(
            title: '🔥 Đang hot',
            action: 'Xem tất cả',
            onAction: () => _openList(sortBy: 'popular', title: 'Địa điểm hot nhất'),
          ),
        ),
        if (_hotLoading)
          const SizedBox(height: 190, child: Center(child: CircularProgressIndicator()))
        else if (_hotDests.isEmpty)
          const SizedBox.shrink()
        else ...[
          SizedBox(
            height: 190,
            child: PageView.builder(
              controller: _bannerCtrl,
              itemCount: _hotDests.length,
              onPageChanged: (i) => setState(() => _bannerPage = i),
              itemBuilder: (_, i) => _HotBannerCard(
                dest: _hotDests[i], rank: i + 1, onTap: () => _openDetail(_hotDests[i])),
            ),
          ),
          if (_hotDests.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_hotDests.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _bannerPage == i ? 18 : 6, height: 6,
                  decoration: BoxDecoration(
                    color: _bannerPage == i ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                )),
              ),
            ),
        ],
      ],
    );
  }

  // ── Khám phá nhanh (gộp khu vực / ngân sách / mùa) ───────────────────────────
  Widget _buildQuickExplore() {
    final month = DateTime.now().month;
    final shortcuts = <_Shortcut>[
      _Shortcut('🧭', 'Miền Bắc', [Color(0xFF3B82F6), Color(0xFF2563EB)],
          () => _openList(region: 'Miền Bắc', title: 'Miền Bắc')),
      _Shortcut('🌊', 'Miền Trung', [Color(0xFF06B6D4), Color(0xFF0891B2)],
          () => _openList(region: 'Miền Trung', title: 'Miền Trung')),
      _Shortcut('🌴', 'Miền Nam', [Color(0xFF10B981), Color(0xFF059669)],
          () => _openList(region: 'Miền Nam', title: 'Miền Nam')),
      _Shortcut('💸', 'Tiết kiệm', [Color(0xFFF59E0B), Color(0xFFD97706)],
          () => _openList(budgetMax: 2000000, title: 'Dưới 2 triệu/ngày')),
      _Shortcut('☀️', 'Mùa này', [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          () => _openList(month: month, title: 'Đi tháng $month')),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: SectionTitle(title: 'Khám phá nhanh'),
        ),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: shortcuts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _ShortcutCard(shortcut: shortcuts[i]),
          ),
        ),
      ],
    );
  }

  // ── Theo sở thích (category interactive) ─────────────────────────────────────
  Widget _buildCategorySection() {
    if (_categories.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 26, 16, 12),
          child: SectionTitle(
            title: 'Theo sở thích',
            action: _selectedCategorySlug != null ? 'Xem tất cả' : null,
            onAction: _selectedCategorySlug != null
                ? () => _openList(category: _selectedCategorySlug, title: 'Theo sở thích')
                : null,
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final selected = cat.slug == _selectedCategorySlug;
              return GestureDetector(
                onTap: () => _loadCategoryDests(cat.slug),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                  ),
                  alignment: Alignment.center,
                  child: Text(cat.name,
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.dark,
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      )),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        _HorizontalDestList(dests: _categoryDests, loading: _catLoading, onTap: _openDetail),
      ],
    );
  }

  // ── Gợi ý cho bạn (personalized) ─────────────────────────────────────────────
  Widget _buildForYouSection() {
    if (!context.read<AppState>().isLoggedIn) return const SizedBox.shrink();
    if (!_forYouLoading && _forYou.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 26, 16, 12),
          child: SectionTitle(title: 'Gợi ý cho bạn'),
        ),
        _HorizontalDestList(dests: _forYou, loading: _forYouLoading, onTap: _openDetail),
      ],
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
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search_rounded, color: AppColors.muted, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Tìm địa điểm, tỉnh thành...',
                  style: TextStyle(fontSize: 14, color: AppColors.muted)),
            ),
            Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Tìm kiếm',
                  style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Shortcut card (Khám phá nhanh)
// ─────────────────────────────────────────────
class _Shortcut {
  final String emoji;
  final String label;
  final List<Color> colors;
  final VoidCallback onTap;
  const _Shortcut(this.emoji, this.label, this.colors, this.onTap);
}

class _ShortcutCard extends StatelessWidget {
  final _Shortcut shortcut;
  const _ShortcutCard({required this.shortcut});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: shortcut.onTap,
      child: Container(
        width: 92,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: shortcut.colors,
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: shortcut.colors.last.withValues(alpha: 0.28),
            blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(shortcut.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(shortcut.label,
                style: const TextStyle(
                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Hero banner card
// ─────────────────────────────────────────────
class _HotBannerCard extends StatelessWidget {
  final Destination dest;
  final int rank;
  final VoidCallback onTap;
  const _HotBannerCard({required this.dest, required this.rank, required this.onTap});

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
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                  stops: const [0.35, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 12, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('#$rank Hot',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
            Positioned(
              bottom: 14, left: 14, right: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dest.name,
                      style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
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

// ─────────────────────────────────────────────
//  Horizontal destination list
// ─────────────────────────────────────────────
class _HorizontalDestList extends StatelessWidget {
  final List<Destination> dests;
  final bool loading;
  final void Function(Destination) onTap;
  const _HorizontalDestList({required this.dests, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }
    if (dests.isEmpty) {
      return const SizedBox(
        height: 60,
        child: Center(child: Text('Không có địa điểm phù hợp',
            style: TextStyle(color: AppColors.muted, fontSize: 13))),
      );
    }
    return SizedBox(
      height: 180,
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
              width: 150,
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
