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

  int _draftRating = 5;
  final _draftCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _dest = widget.destination;
    _trackView();
    _loadReviews();
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.dark,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(d.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 8)])),
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
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: FavoriteButton(
                  destinationId: d.id,
                  initialCount: d.favoriteCount,
                  showCount: false,
                  iconSize: 24,
                  activeColor: AppColors.error,
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatsRow(dest: d),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 15, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Text('${d.province ?? ''} • ${d.region}',
                          style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (d.categories.isNotEmpty) ...[
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: d.categories.map((c) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(c.name,
                            style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      )).toList(),
                    ),
                    const SizedBox(height: 14),
                  ],

                  Text(d.description, style: const TextStyle(fontSize: 14.5, height: 1.65, color: AppColors.mid)),
                  const SizedBox(height: 20),

                  if (d.weather.isNotEmpty)
                    _InfoCard(icon: Icons.wb_sunny_outlined, title: 'Thời tiết', content: d.weather),
                  if (d.bestSeason.isNotEmpty)
                    _InfoCard(icon: Icons.calendar_month_outlined, title: 'Mùa du lịch lý tưởng', content: d.bestSeason),
                  if (d.cuisine.isNotEmpty)
                    _InfoCard(icon: Icons.restaurant_outlined, title: 'Ẩm thực đặc sắc', content: d.cuisine),
                  if (d.special.isNotEmpty)
                    _InfoCard(icon: Icons.star_outline_rounded, title: 'Điểm nổi bật', content: d.special),
                  _InfoCard(
                    icon: Icons.payments_outlined,
                    title: 'Chi phí tham khảo/người',
                    content: '${formatCurrency(d.budgetLow)} – ${formatCurrency(d.budgetHigh)}',
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => ChatBotScreen(initialMessage: 'Cho tôi biết thêm về ${d.name} và gợi ý lịch trình'),
                      )),
                      icon: const Icon(Icons.smart_toy_outlined, size: 18),
                      label: const Text('Hỏi AI về địa điểm này'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
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
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
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