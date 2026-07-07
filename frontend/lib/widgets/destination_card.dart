// lib/widgets/destination_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/destination.dart';
import '../providers/app_state.dart';
import '../providers/favorites_provider.dart';
import '../services/favorite_api_service.dart';
import 'common_widgets.dart';

class DestinationCard extends StatefulWidget {
  final Destination destination;
  final VoidCallback onTap;

  const DestinationCard({super.key, required this.destination, required this.onTap});

  @override
  State<DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard> {
  bool _isFav = false;
  bool _favLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavStatus();
  }

  Future<void> _loadFavStatus() async {
    final token = context.read<AppState>().token;
    if (token == null) return;
    try {
      final s = await FavoriteApiService(token: token).status(widget.destination.id);
      if (mounted) setState(() => _isFav = s);
    } catch (_) {}
  }

  Future<void> _toggleFav() async {
    final token = context.read<AppState>().token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập để lưu yêu thích')));
      return;
    }
    if (_favLoading) return;
    setState(() => _favLoading = true);
    try {
      final s = await FavoriteApiService(token: token).toggle(widget.destination.id);
      if (mounted) {
        setState(() { _isFav = s; _favLoading = false; });
        context.read<FavoritesProvider>().notifyChanged();
      }
    } catch (_) {
      if (mounted) setState(() => _favLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.destination;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section — flex 55
            Expanded(
              flex: 55,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: d.imageUrl.isNotEmpty
                        ? Image.network(d.imageUrl, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _ImagePlaceholder())
                        : _ImagePlaceholder(),
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.35)],
                          stops: const [0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Rating badge
                  Positioned(
                    top: 7, left: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 11, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 3),
                          Text(
                            d.ratingAvg > 0 ? d.ratingAvg.toStringAsFixed(1) : '–',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 5, right: 5,
                    child: GestureDetector(
                      onTap: _toggleFav,
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.88),
                          shape: BoxShape.circle,
                        ),
                        child: _favLoading
                            ? const Center(child: SizedBox(width: 13, height: 13,
                                child: CircularProgressIndicator(strokeWidth: 1.5)))
                            : Icon(
                                _isFav ? Icons.favorite : Icons.favorite_border,
                                size: 15,
                                color: _isFav ? AppColors.error : AppColors.muted,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info section — flex 45, dùng intrinsic để không overflow
            Expanded(
              flex: 45,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Name
                    Text(d.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),

                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 10, color: AppColors.muted),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            d.province ?? d.region,
                            style: const TextStyle(fontSize: 10.5, color: AppColors.muted),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Stats row
                    Row(
                      children: [
                        _Stat(icon: Icons.visibility_outlined, value: _fmt(d.viewCount)),
                        const SizedBox(width: 6),
                        _Stat(icon: Icons.favorite_border, value: _fmt(d.favoriteCount), color: AppColors.error),
                      ],
                    ),

                    // Budget — FIX: đảm bảo không overflow bằng FittedBox
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${formatCurrency(d.budgetLow)} – ${formatCurrency(d.budgetHigh)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
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

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  const _Stat({required this.icon, required this.value, this.color = AppColors.muted});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(value, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
        ],
      );
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.primary.withValues(alpha: 0.1),
        child: const Center(child: Icon(Icons.landscape_outlined, size: 36, color: AppColors.primary)),
      );
}
