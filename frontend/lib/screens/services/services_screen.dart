// lib/screens/services/services_screen.dart
//
// ServicesScreen — Màn hình "Tra cứu dịch vụ" (Tab 3)
//
// API thực tế của backend:
//   GET /travel/destinations          → danh sách điểm đến (không cần auth)
//   GET /travel/destinations/:id/hotels → khách sạn theo điểm đến
//   GET /travel/destinations/:id/tours  → tour theo điểm đến
//
// Chiến lược:
//   - Tab "Tất cả"   → load destinations list (hiển thị dạng card với type='destination')
//   - Tab "Khách sạn" → load destinations rồi lấy hotels của từng dest (parallel, giới hạn 5 dest đầu)
//   - Tab "Tour"      → tương tự với tours
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/destination.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/loading_state_widgets.dart';
import 'saved_trips_screen.dart';
import 'favorites_screen.dart';
import '../chat/chat_history_screen.dart';
import '../chat/intent_setup_screen.dart';

// ─── Model nội bộ ────────────────────────────────────────────────────────────

class _ServiceItem {
  final String id;
  final String name;
  final String type;       // 'destination' | 'hotel' | 'tour'
  final String subtitle;   // tỉnh/mô tả ngắn
  final String description;
  final double rating;
  final String location;
  final double price;
  final String? imageUrl;

  const _ServiceItem({
    required this.id,
    required this.name,
    required this.type,
    required this.subtitle,
    required this.description,
    required this.rating,
    required this.location,
    required this.price,
    this.imageUrl,
  });

  factory _ServiceItem.fromDestination(Destination d) => _ServiceItem(
        id: d.id,
        name: d.name,
        type: 'destination',
        subtitle: d.province ?? d.region,
        description: d.description,
        rating: d.ratingAvg,
        location: d.province ?? d.region,
        price: d.budgetLow.toDouble(),
        imageUrl: d.imageUrl.isNotEmpty ? d.imageUrl : null,
      );

  factory _ServiceItem.fromHotel(Map<String, dynamic> j, String destName) {
    double parseDbl(dynamic v) =>
        v == null ? 0.0 : double.tryParse('$v') ?? 0.0;
    return _ServiceItem(
      id: j['id']?.toString() ?? '',
      name: j['name']?.toString() ?? '',
      type: 'hotel',
      subtitle: destName,
      description: j['address']?.toString() ?? j['type']?.toString() ?? '',
      rating: parseDbl(j['rating']),
      location: destName,
      price: parseDbl(j['price_per_night']),
      imageUrl: j['image_url']?.toString(),
    );
  }

  factory _ServiceItem.fromTour(Map<String, dynamic> j, String destName) {
    double parseDbl(dynamic v) =>
        v == null ? 0.0 : double.tryParse('$v') ?? 0.0;
    return _ServiceItem(
      id: j['id']?.toString() ?? '',
      name: j['name']?.toString() ?? '',
      type: 'tour',
      subtitle: destName,
      description: j['description']?.toString() ?? '',
      rating: parseDbl(j['rating']),
      location: destName,
      price: parseDbl(j['price']),
      imageUrl: j['image_url']?.toString(),
    );
  }
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _searchCtrl = TextEditingController();

  List<_ServiceItem> _all = [];
  List<_ServiceItem> _filtered = [];
  bool _loading = true;
  String? _error;
  int _selectedTab = 0;   // 0=Tất cả, 1=Khách sạn, 2=Tour

  // [P2] Bộ lọc nâng cao
  double _minRating = 0;  // 0 = không lọc
  double _maxPrice = 0;   // 0 = không lọc (VND)
  bool get _hasFilter => _minRating > 0 || _maxPrice > 0;

  static const _tabs = ['Tất cả', 'Khách sạn', 'Tour'];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load(tab: 0);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String get _baseUrl => ApiConfig.baseUrl;

  Future<List<Destination>> _fetchDestinations({int limit = 30}) async {
    final uri = Uri.parse('$_baseUrl/travel/destinations')
        .replace(queryParameters: {'limit': '$limit', 'sort_by': 'popular'});
    final res = await http.get(uri).timeout(ApiConfig.timeout);
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    if (body is! List) return [];
    return body
        .whereType<Map<String, dynamic>>()
        .map(Destination.fromJson)
        .toList();
  }

  Future<List<Map<String, dynamic>>> _fetchHotelsForDest(String destId) async {
    final uri = Uri.parse('$_baseUrl/travel/destinations/$destId/hotels')
        .replace(queryParameters: {'limit': '10'});
    final res = await http.get(uri).timeout(ApiConfig.timeout);
    if (res.statusCode != 200) return [];
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    if (body is! List) return [];
    return body.whereType<Map<String, dynamic>>().toList();
  }

  Future<List<Map<String, dynamic>>> _fetchToursForDest(String destId) async {
    final uri = Uri.parse('$_baseUrl/travel/destinations/$destId/tours')
        .replace(queryParameters: {'limit': '10'});
    final res = await http.get(uri).timeout(ApiConfig.timeout);
    if (res.statusCode != 200) return [];
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    if (body is! List) return [];
    return body.whereType<Map<String, dynamic>>().toList();
  }

  // ── Load ───────────────────────────────────────────────────────────────────

  Future<void> _load({required int tab}) async {
    setState(() {
      _loading = true;
      _error = null;
      _selectedTab = tab;
    });

    try {
      List<_ServiceItem> items = [];

      if (tab == 0) {
        // Tab Tất cả → destinations list
        final dests = await _fetchDestinations(limit: 40);
        items = dests.map(_ServiceItem.fromDestination).toList();
      } else if (tab == 1) {
        // Tab Khách sạn → lấy hotels từ 8 destination đầu song song
        final dests = await _fetchDestinations(limit: 8);
        final futures = dests.map((d) => _fetchHotelsForDest(d.id)
            .then((hotels) => hotels
                .map((h) => _ServiceItem.fromHotel(h, d.name))
                .toList()));
        final results = await Future.wait(futures);
        for (final list in results) {
          items.addAll(list);
        }
      } else {
        // Tab Tour → lấy tours từ 8 destination đầu song song
        final dests = await _fetchDestinations(limit: 8);
        final futures = dests.map((d) => _fetchToursForDest(d.id)
            .then((tours) => tours
                .map((t) => _ServiceItem.fromTour(t, d.name))
                .toList()));
        final results = await Future.wait(futures);
        for (final list in results) {
          items.addAll(list);
        }
      }

      if (!mounted) return;
      setState(() {
        _all = items;
        _loading = false;
      });
      _applyFilter();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Không tải được dữ liệu: ${e.toString().replaceAll('Exception: ', '')}';
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      _filtered = _all.where((s) {
        if (q.isNotEmpty &&
            !'${s.name} ${s.description} ${s.location}'.toLowerCase().contains(q)) {
          return false;
        }
        if (_minRating > 0 && s.rating < _minRating) return false;
        if (_maxPrice > 0 && s.price > 0 && s.price > _maxPrice) return false;
        return true;
      }).toList();
    });
  }

  // [P2] Bottom sheet bộ lọc (rating + giá tối đa)
  void _openFilterSheet() {
    double tmpRating = _minRating;
    double tmpPrice = _maxPrice;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bộ lọc',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Đánh giá tối thiểu',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [0.0, 3.0, 3.5, 4.0, 4.5].map((r) {
                  final sel = tmpRating == r;
                  return ChoiceChip(
                    label: Text(r == 0 ? 'Tất cả' : '${r.toStringAsFixed(1)}★'),
                    selected: sel,
                    onSelected: (_) => setSheet(() => tmpRating = r),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Giá tối đa',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [0.0, 500000.0, 1000000.0, 2000000.0, 5000000.0].map((p) {
                  final sel = tmpPrice == p;
                  return ChoiceChip(
                    label: Text(p == 0
                        ? 'Tất cả'
                        : p >= 1000000
                            ? '${(p / 1000000).toStringAsFixed(0)}M'
                            : '${(p / 1000).toStringAsFixed(0)}K'),
                    selected: sel,
                    onSelected: (_) => setSheet(() => tmpPrice = p),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() { _minRating = 0; _maxPrice = 0; });
                      _applyFilter();
                      Navigator.pop(ctx);
                    },
                    child: const Text('Xóa lọc'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() { _minRating = tmpRating; _maxPrice = tmpPrice; });
                      _applyFilter();
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    child: const Text('Áp dụng'),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // [P2] Hàng truy cập nhanh 4 khu
  Widget _buildShortcuts() {
    final items = [
      (Icons.favorite_border, 'Yêu thích', const FavoritesScreen()),
      (Icons.luggage_outlined, 'Chuyến đi', const SavedTripsScreen()),
      (Icons.history, 'Lịch sử chat', const ChatHistoryScreen()),
      (Icons.auto_awesome_outlined, 'Thiết kế AI', const IntentSetupScreen()),
    ];
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final (icon, label, screen) = items[i];
          return GestureDetector(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => screen)),
            child: Container(
              width: 84,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: AppColors.primary, size: 24),
                  const SizedBox(height: 6),
                  Text(label,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Tra cứu dịch vụ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Bộ lọc',
            icon: Icon(_hasFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
                color: _hasFilter ? AppColors.primary : AppColors.dark),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // [P2] Truy cập nhanh 4 khu
            _buildShortcuts(),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Tìm kiếm dịch vụ',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: AppSearchBar(
                controller: _searchCtrl,
                hint: 'Tìm khách sạn, tour, điểm đến...',
              ),
            ),
            const SizedBox(height: 10),

            // Tabs
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final sel = _selectedTab == i;
                  return ChoiceChip(
                    label: Text(_tabs[i]),
                    selected: sel,
                    onSelected: (_) => _load(tab: i),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                        color: sel ? AppColors.primary : Colors.grey.shade300),
                    labelStyle: TextStyle(
                      color: sel ? AppColors.primary : AppColors.dark,
                      fontWeight:
                          sel ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Content
            Expanded(
              child: _loading
                  ? const LoadingScreen(message: 'Đang tải...')
                  : _error != null
                      ? ErrorScreen(
                          message: _error!,
                          onRetry: () => _load(tab: _selectedTab),
                        )
                      : _filtered.isEmpty
                          ? EmptyScreen(
                              title: 'Không có kết quả',
                              message: _searchCtrl.text.isNotEmpty
                                  ? 'Không tìm thấy "${_searchCtrl.text}"'
                                  : 'Chưa có dữ liệu',
                              icon: Icons.search_off_outlined,
                              onRetry: () => _load(tab: _selectedTab),
                            )
                          : RefreshIndicator(
                              color: AppColors.primary,
                              onRefresh: () => _load(tab: _selectedTab),
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                itemCount: _filtered.length,
                                itemBuilder: (_, i) =>
                                    _ServiceCard(item: _filtered[i]),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Service Card ─────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final _ServiceItem item;

  const _ServiceCard({required this.item});

  IconData get _icon {
    switch (item.type) {
      case 'hotel':
        return Icons.hotel_outlined;
      case 'tour':
        return Icons.tour_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  Color get _typeColor {
    switch (item.type) {
      case 'hotel':
        return const Color(0xFF7C3AED);
      case 'tour':
        return const Color(0xFFD97706);
      default:
        return AppColors.primary;
    }
  }

  String get _typeLabel {
    switch (item.type) {
      case 'hotel':
        return 'Khách sạn';
      case 'tour':
        return 'Tour';
      default:
        return 'Điểm đến';
    }
  }

  String _formatPrice(double price) {
    if (price <= 0) return 'Liên hệ';
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M₫';
    }
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K₫';
    }
    return '${price.toStringAsFixed(0)}₫';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
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
          // Thumbnail
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(16)),
            child: SizedBox(
              width: 100,
              height: 100,
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _Placeholder(color: _typeColor, icon: _icon))
                  : _Placeholder(color: _typeColor, icon: _icon),
            ),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(_typeLabel,
                        style: TextStyle(
                            fontSize: 10,
                            color: _typeColor,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 5),

                  // Name
                  Text(item.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),

                  // Location
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: AppColors.muted),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(item.location,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.muted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                  const SizedBox(height: 6),

                  // Rating + Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating
                      Row(children: [
                        const Icon(Icons.star_rounded,
                            size: 13, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 3),
                        Text(
                          item.rating > 0
                              ? item.rating.toStringAsFixed(1)
                              : '–',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dark),
                        ),
                      ]),

                      // Price
                      Text(
                        _formatPrice(item.price),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _typeColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _Placeholder({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        color: color.withValues(alpha: 0.08),
        child: Icon(icon, color: color.withValues(alpha: 0.5), size: 32),
      );
}