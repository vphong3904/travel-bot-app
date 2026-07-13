// lib/screens/trip_detail/destination_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/destination.dart';
import '../../models/review.dart';
import '../../providers/app_state.dart';
import '../../services/destination_service.dart';
import '../../services/review_api_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/favorite_button.dart';
import '../../widgets/review_card.dart';
import '../auth/login_register_screen.dart';
import '../chat/chatbot_screen.dart';
import '../detail/entity_detail_screen.dart';
import '../detail/itinerary_detail_screen.dart';
import '../trip/ai_planner_screen.dart';

class DestinationDetailScreen extends StatefulWidget {
  final Destination destination;

  const DestinationDetailScreen({super.key, required this.destination});

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  late Destination _dest;
  List<Review> _reviews = [];
  Review? _myReview;
  bool _reviewLoading = true;
  bool _viewTracked = false;

  // Vé vào cổng (entry fee)
  List<Map<String, dynamic>> _tickets = [];

  // Gộp các loại của điểm đến (khách sạn/ẩm thực/nhà hàng/tour/mua sắm)
  Map<String, List<Map<String, dynamic>>> _overview = const {};

  // Gợi ý lịch trình + chi phí
  List<Map<String, dynamic>> _itineraries = [];

  int _draftRating = 5;
  final _draftCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _dest = widget.destination;
    _loadFullDetail();
    _trackView();
    _loadReviews();
    _loadTickets();
    _loadOverview();
    _loadItineraries();
  }

  // Object truyền vào có thể là bản rút gọn (từ list endpoint — thiếu mô tả,
  // thời tiết, best_months...). Tải bản đầy đủ để hiển thị đúng "Giới thiệu" &
  // "Thông tin hữu ích". Giữ nguyên object cũ để render ngay (ảnh/tên/stats).
  Future<void> _loadFullDetail() async {
    final full = await DestinationRepository.fetchDestination(_dest.id);
    if (full == null || !mounted) return;
    setState(() {
      _dest = full.copyWith(
        viewCount: _dest.viewCount > full.viewCount ? _dest.viewCount : full.viewCount,
      );
    });
  }

  Future<void> _loadItineraries() async {
    final data = await DestinationRepository.fetchItineraries(_dest.id);
    if (mounted) setState(() => _itineraries = data);
  }

  Future<void> _loadTickets() async {
    final data = await DestinationRepository.fetchTickets(_dest.id);
    if (mounted) setState(() => _tickets = data);
  }

  Future<void> _loadOverview() async {
    final data = await DestinationRepository.fetchOverview(_dest.id);
    if (mounted) setState(() => _overview = data);
  }

  void _openEntity(String type, String id) {
    if (id.isEmpty) return;
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => EntityDetailScreen(type: type, id: id)));
  }

  // Gợi ý lịch trình + chi phí (chỉ hiện khi có dữ liệu).
  List<Widget> _buildItinerarySection() {
    if (_itineraries.isEmpty) return const [];
    return [
      const SizedBox(height: 20),
      const _SectionLabel('Lịch trình & chi phí gợi ý'),
      const SizedBox(height: 10),
      SizedBox(
        height: 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: _itineraries.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => _ItineraryCard(
            data: _itineraries[i],
            onTap: () {
              final id = _itineraries[i]['id']?.toString() ?? '';
              if (id.isEmpty) return;
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ItineraryDetailScreen(id: id)));
            },
          ),
        ),
      ),
    ];
  }

  // Các mục "đầy đủ" của điểm đến — chỉ hiện nhóm có dữ liệu.
  List<Widget> _buildOverviewSections() {
    const groups = [
      ['hotels', 'hotel', 'Khách sạn'],
      ['foods', 'food', 'Ẩm thực đặc sản'],
      ['restaurants', 'restaurant', 'Nhà hàng & quán ăn'],
      ['tours', 'tour', 'Tour'],
      ['shopping', 'shopping', 'Mua sắm'],
    ];
    final widgets = <Widget>[];
    for (final g in groups) {
      final items = _overview[g[0]] ?? const [];
      if (items.isEmpty) continue;
      widgets.add(const SizedBox(height: 20));
      widgets.add(_SectionLabel(g[2]));
      widgets.add(const SizedBox(height: 10));
      widgets.add(SizedBox(
        height: 176,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => _OverviewCard(
            type: g[1],
            data: items[i],
            onTap: () => _openEntity(g[1], items[i]['id']?.toString() ?? ''),
          ),
        ),
      ));
    }
    return widgets;
  }

  @override
  void dispose() {
    _draftCtrl.dispose();
    super.dispose();
  }

  Future<void> _trackView() async {
    if (_viewTracked) return;
    _viewTracked = true;
    final token = context.read<AppState>().token;
    if (token == null) return;
    await DestinationRepository.trackView(_dest.id, token);
    if (mounted) setState(() => _dest = _dest.copyWith(viewCount: _dest.viewCount + 1));
  }

  // FIX: Guest cũng có thể xem reviews — chỉ skip _myReview khi chưa login
  Future<void> _loadReviews() async {
    setState(() => _reviewLoading = true);
    final token = context.read<AppState>().token;
    try {
      if (token != null) {
        // Đã đăng nhập: load reviews + review của mình song song
        final svc = ReviewApiService(token: token);
        final results = await Future.wait([
          svc.listReviews(_dest.id),
          svc.getMyReview(_dest.id),
        ]);
        if (!mounted) return;
        setState(() {
          _reviews = results[0] as List<Review>;
          _myReview = results[1] as Review?;
          _reviewLoading = false;
        });
      } else {
        // Guest: chỉ load public reviews, không load _myReview
        final svc = ReviewApiService(token: '');
        final reviews = await svc.listReviews(_dest.id);
        if (!mounted) return;
        setState(() {
          _reviews = reviews;
          _myReview = null;
          _reviewLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _reviewLoading = false);
    }
  }

  Future<void> _submitReview() async {
    final token = context.read<AppState>().token;
    // FIX: Chặn guest submit, hiển thị prompt đăng nhập
    if (token == null) {
      _showLoginPrompt();
      return;
    }
    setState(() => _submitting = true);
    try {
      final review = await ReviewApiService(token: token).createReview(
        _dest.id,
        rating: _draftRating,
        content: _draftCtrl.text.trim(),
      );
      _draftCtrl.clear();
      if (mounted) {
        setState(() {
          _myReview = review;
          _reviews.insert(0, review);
          _submitting = false;
          _dest = _dest.copyWith(reviewCount: _dest.reviewCount + 1);
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Đã gửi đánh giá!')));
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
    }
  }

  Future<void> _deleteReview(String reviewId) async {
    final token = context.read<AppState>().token;
    if (token == null) return;
    try {
      await ReviewApiService(token: token).deleteReview(_dest.id, reviewId);
      if (mounted) {
        setState(() {
          _reviews.removeWhere((r) => r.id == reviewId);
          _myReview = null;
          _dest = _dest.copyWith(reviewCount: (_dest.reviewCount - 1).clamp(0, 999999));
        });
      }
    } catch (_) {}
  }

  // Hiển thị dialog mời đăng nhập khi guest cố comment
  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đăng nhập để tiếp tục'),
        content: const Text('Bạn cần đăng nhập để viết đánh giá.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginRegisterScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _dest;
    final isLoggedIn = context.watch<AppState>().isLoggedIn;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.dark,
            leading: _CircleBarButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: FavoriteButton(
                    destinationId: d.id,
                    initialCount: d.favoriteCount,
                    showCount: false,
                    iconSize: 22,
                    activeColor: AppColors.error,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  d.imageUrl.isNotEmpty
                      ? Image.network(d.imageUrl, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: AppColors.primary.withValues(alpha: 0.3)))
                      : Container(color: AppColors.primary.withValues(alpha: 0.3)),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.black.withValues(alpha: 0.25), Colors.transparent, Colors.black.withValues(alpha: 0.65)],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16, left: 16, right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.name,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold,
                                shadows: [Shadow(blurRadius: 8, color: Colors.black45)]),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.location_on, size: 15, color: Colors.white),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text('${d.province ?? ''} • ${d.region}',
                                style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -18),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatsRow(dest: d),
                    const SizedBox(height: 18),

                    if (d.categories.isNotEmpty) ...[
                      Wrap(
                        spacing: 6, runSpacing: 6,
                        children: d.categories.map((c) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.09),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(c.name,
                              style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                        )).toList(),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // 2 hành động chính, tách biệt rõ ràng:
                    // - "Hỏi AI" → chat tự do, hỏi-đáp thông tin bình thường
                    //   (KHÔNG còn kèm "gợi ý lịch trình" trong tin nhắn mở đầu
                    //   — tránh kéo chat vào luồng lên lịch, đúng yêu cầu "màn
                    //   chatbot chỉ để nói chuyện bình thường").
                    // - "Gợi ý lịch trình" → gọi thẳng /trips/ai/plan (tái
                    //   dùng AiPlannerScreen có sẵn), ra ngay 1 lịch trình mẫu
                    //   kèm nút "Lưu chuyến đi", không hỏi từng bước trong chat.
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => AiPlannerScreen(initialDestination: d.name),
                        )),
                        icon: const Icon(Icons.map_outlined, size: 18),
                        label: const Text('Gợi ý lịch trình'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ChatBotScreen(initialMessage: 'Cho tôi biết thêm về ${d.name}'),
                        )),
                        icon: const Icon(Icons.smart_toy_outlined, size: 18),
                        label: const Text('Hỏi AI về địa điểm này'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (d.description.isNotEmpty) ...[
                      const _SectionLabel('Giới thiệu'),
                      const SizedBox(height: 8),
                      Text(d.description, style: const TextStyle(fontSize: 14.5, height: 1.65, color: AppColors.mid)),
                      const SizedBox(height: 22),
                    ],

                    if (d.bestSeason.isNotEmpty || d.bestMonths.isNotEmpty ||
                        d.weather.isNotEmpty || d.cuisine.isNotEmpty || d.special.isNotEmpty) ...[
                      const _SectionLabel('Thông tin hữu ích'),
                      const SizedBox(height: 10),
                      if (d.bestSeason.isNotEmpty || d.bestMonths.isNotEmpty)
                        _BestTimeCard(season: d.bestSeason, months: d.bestMonths),
                      if (d.weather.isNotEmpty)
                        _InfoCard(icon: Icons.wb_sunny_outlined, title: 'Thời tiết', content: d.weather),
                      if (d.cuisine.isNotEmpty)
                        _InfoCard(icon: Icons.restaurant_outlined, title: 'Ẩm thực đặc sắc', content: d.cuisine),
                      if (d.special.isNotEmpty)
                        _InfoCard(icon: Icons.star_outline_rounded, title: 'Điểm nổi bật', content: d.special),
                    ],

                    if (_tickets.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const _SectionLabel('Vé vào cổng'),
                      const SizedBox(height: 10),
                      ..._tickets.map((t) => _TicketCard(data: t)),
                    ],

                    ..._buildItinerarySection(),
                    ..._buildOverviewSections(),

                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Đánh giá (${d.reviewCount})',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.dark)),
                      const Spacer(),
                      Row(children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 17),
                        const SizedBox(width: 4),
                        Text(d.ratingAvg > 0 ? d.ratingAvg.toStringAsFixed(1) : '–',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const Text(' / 5', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // FIX: Guest thấy banner mời đăng nhập thay vì form bị chặn ngầm
                  if (!isLoggedIn)
                    _GuestReviewBanner(onLogin: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginRegisterScreen()),
                    ))
                  else if (_myReview == null)
                    _WriteReviewForm(
                      rating: _draftRating,
                      controller: _draftCtrl,
                      submitting: _submitting,
                      onRatingChanged: (r) => setState(() => _draftRating = r),
                      onSubmit: _submitReview,
                    ),
                  const SizedBox(height: 16),

                  if (_reviewLoading)
                    const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  else if (_reviews.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Chưa có đánh giá nào. Hãy là người đầu tiên!',
                            style: TextStyle(color: AppColors.muted), textAlign: TextAlign.center),
                      ),
                    )
                  else
                    ..._reviews.map((r) => ReviewCard(
                        review: r,
                        isOwn: r.id == _myReview?.id,
                        onDelete: r.id == _myReview?.id ? () => _deleteReview(r.id) : null,
                      )),
                ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ── Nút tròn mờ trên ảnh (back / actions) ──────────────────────────────────────
class _CircleBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBarButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => Center(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    ),
  );
}

// ── Nhãn mục ────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.dark));
}

// ── Thẻ "Thời điểm nên đi" (mùa + dải 12 tháng) ─────────────────────────────────
class _BestTimeCard extends StatelessWidget {
  final String season;
  final List<int> months;
  const _BestTimeCard({required this.season, required this.months});

  @override
  Widget build(BuildContext context) {
    final best = months.toSet();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.calendar_month_outlined, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            const Text('Thời điểm nên đi',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.dark)),
          ]),
          if (season.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(season, style: const TextStyle(fontSize: 13, color: AppColors.mid, height: 1.5)),
          ],
          if (best.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: List.generate(12, (i) {
                final m = i + 1;
                final on = best.contains(m);
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    height: 30,
                    decoration: BoxDecoration(
                      color: on ? AppColors.primary : AppColors.bg,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: on ? AppColors.primary : AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text('$m',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                          color: on ? Colors.white : AppColors.muted,
                        )),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            Row(children: [
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: 5),
              const Text('Tháng lý tưởng để đi',
                  style: TextStyle(fontSize: 11, color: AppColors.muted)),
            ]),
          ],
        ],
      ),
    );
  }
}

// ── Thẻ vé vào cổng (entry fee) ─────────────────────────────────────────────────
class _TicketCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _TicketCard({required this.data});

  String get _name => data['name']?.toString() ?? 'Vé';
  int? _int(String k) {
    final v = data[k];
    if (v == null) return null;
    return v is int ? v : int.tryParse('$v');
  }
  String get _hours => data['hours']?.toString() ?? '';
  String get _desc => data['description']?.toString() ?? '';

  String _price(int? v) => v == null ? '—' : formatCurrency(v);

  @override
  Widget build(BuildContext context) {
    final adult = _int('price_adult');
    final child = _int('price_child');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.confirmation_number_outlined, color: AppColors.secondary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(_name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.dark)),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _priceCol('Người lớn', _price(adult))),
            Container(width: 1, height: 34, color: AppColors.border),
            Expanded(child: _priceCol('Trẻ em', _price(child))),
          ]),
          if (_hours.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.access_time_outlined, size: 14, color: AppColors.muted),
              const SizedBox(width: 6),
              Expanded(child: Text(_hours, style: const TextStyle(fontSize: 12.5, color: AppColors.mid))),
            ]),
          ],
          if (_desc.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(_desc, style: const TextStyle(fontSize: 12.5, color: AppColors.mid, height: 1.5)),
          ],
        ],
      ),
    );
  }

  Widget _priceCol(String label, String value) => Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.secondary)),
        ],
      );
}

// ── Thẻ ngang cho mục overview (khách sạn/ẩm thực/…) ─────────────────────────────
class _OvMeta {
  final IconData icon;
  final Color color;
  const _OvMeta(this.icon, this.color);
}

const Map<String, _OvMeta> _kOvMeta = {
  'hotel': _OvMeta(Icons.hotel_rounded, Color(0xFF7C3AED)),
  'food': _OvMeta(Icons.ramen_dining_rounded, Color(0xFFEA580C)),
  'restaurant': _OvMeta(Icons.restaurant_rounded, Color(0xFFDC2626)),
  'tour': _OvMeta(Icons.tour_rounded, Color(0xFFD97706)),
  'shopping': _OvMeta(Icons.shopping_bag_rounded, Color(0xFF059669)),
};

class _OverviewCard extends StatelessWidget {
  final String type;
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  const _OverviewCard({required this.type, required this.data, required this.onTap});

  _OvMeta get _meta => _kOvMeta[type] ?? _kOvMeta['hotel']!;

  int? _int(String k) {
    final v = data[k];
    if (v == null) return null;
    return v is int ? v : int.tryParse('$v');
  }

  String _sub() {
    switch (type) {
      case 'hotel':
        final stars = _int('stars');
        final p = _int('price_per_night');
        final parts = <String>[];
        if (stars != null) parts.add('$stars★');
        if (p != null && p > 0) parts.add(formatCurrency(p));
        return parts.join('  •  ');
      case 'tour':
        final d = data['duration']?.toString() ?? '';
        final p = _int('price');
        final parts = <String>[];
        if (d.isNotEmpty) parts.add(d);
        if (p != null && p > 0) parts.add(formatCurrency(p));
        return parts.join('  •  ');
      default: // food / restaurant / shopping
        return data['price_range']?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final img = data['image_url']?.toString() ?? '';
    final mustTry = data['must_try'] == true;
    final sub = _sub();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 148,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Stack(fit: StackFit.expand, children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: img.isNotEmpty
                      ? Image.network(img, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _ph())
                      : _ph(),
                ),
                Positioned(
                  top: 7, left: 7,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                    child: Icon(_meta.icon, size: 13, color: _meta.color),
                  ),
                ),
                if (mustTry)
                  Positioned(
                    top: 7, right: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(6)),
                      child: const Text('Nên thử', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ]),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data['name']?.toString() ?? '',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.dark, height: 1.2),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (sub.isNotEmpty)
                      Text(sub,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _meta.color),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ph() => Container(
        color: _meta.color.withValues(alpha: 0.10),
        child: Center(child: Icon(_meta.icon, size: 34, color: _meta.color.withValues(alpha: 0.55))),
      );
}

// ── Thẻ gợi ý lịch trình + chi phí ──────────────────────────────────────────────
class _ItineraryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  const _ItineraryCard({required this.data, required this.onTap});

  int get _total {
    final c = data['cost'];
    if (c is Map) return c['total'] is int ? c['total'] : int.tryParse('${c['total']}') ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final days = int.tryParse('${data['duration_days']}') ?? 1;
    final durLabel = itineraryDurationLabel(days);
    final group = data['group_label']?.toString() ?? '';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 214,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(children: [
                const Icon(Icons.event_note_outlined, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(durLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                const Spacer(),
                Flexible(
                  child: Text(group,
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ]),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Chi phí ước tính / người',
                          style: TextStyle(fontSize: 11, color: AppColors.muted)),
                      const SizedBox(height: 3),
                      Text(formatCurrency(_total),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ]),
                    Row(children: const [
                      Icon(Icons.hotel_outlined, size: 13, color: AppColors.muted),
                      SizedBox(width: 4),
                      Icon(Icons.restaurant_outlined, size: 13, color: AppColors.muted),
                      SizedBox(width: 4),
                      Icon(Icons.directions_bus_outlined, size: 13, color: AppColors.muted),
                      SizedBox(width: 4),
                      Icon(Icons.confirmation_number_outlined, size: 13, color: AppColors.muted),
                      Spacer(),
                      Text('Chi tiết', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
                      Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
                    ]),
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

// ── Guest banner mời đăng nhập ─────────────────────────────────────────────────
class _GuestReviewBanner extends StatelessWidget {
  final VoidCallback onLogin;
  const _GuestReviewBanner({required this.onLogin});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
    ),
    child: Row(
      children: [
        const Icon(Icons.lock_outline, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Đăng nhập để viết đánh giá',
            style: TextStyle(fontSize: 13, color: AppColors.mid),
          ),
        ),
        TextButton(
          onPressed: onLogin,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Đăng nhập', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
}

class _StatsRow extends StatelessWidget {
  final Destination dest;
  const _StatsRow({required this.dest});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatCol(icon: Icons.star_rounded, iconColor: const Color(0xFFF59E0B),
            value: dest.ratingAvg > 0 ? dest.ratingAvg.toStringAsFixed(1) : '–', label: 'Đánh giá'),
        _Divider(),
        _StatCol(icon: Icons.rate_review_outlined, iconColor: AppColors.primary,
            value: '${dest.reviewCount}', label: 'Review'),
        _Divider(),
        _StatCol(icon: Icons.favorite, iconColor: AppColors.error,
            value: _fmt(dest.favoriteCount), label: 'Yêu thích'),
        _Divider(),
        _StatCol(icon: Icons.visibility_outlined, iconColor: AppColors.muted,
            value: _fmt(dest.viewCount), label: 'Lượt xem'),
      ],
    ),
  );

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

class _StatCol extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  const _StatCol({required this.icon, required this.iconColor, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: iconColor, size: 22),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.dark)),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
    ],
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: AppColors.border);
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  const _InfoCard({required this.icon, required this.title, required this.content});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.dark)),
            const SizedBox(height: 4),
            Text(content, style: const TextStyle(fontSize: 13, color: AppColors.mid, height: 1.5)),
          ],
        )),
      ],
    ),
  );
}

class _WriteReviewForm extends StatelessWidget {
  final int rating;
  final TextEditingController controller;
  final bool submitting;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;

  const _WriteReviewForm({
    required this.rating, required this.controller,
    required this.submitting, required this.onRatingChanged, required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Viết đánh giá của bạn',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.dark)),
        const SizedBox(height: 12),
        Row(children: List.generate(5, (i) => GestureDetector(
          onTap: () => onRatingChanged(i + 1),
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 28,
              color: i < rating ? const Color(0xFFF59E0B) : AppColors.muted,
            ),
          ),
        ))),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Chia sẻ trải nghiệm của bạn...',
            hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: submitting ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: submitting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Gửi đánh giá', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    ),
  );
}