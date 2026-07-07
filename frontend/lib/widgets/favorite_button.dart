// lib/widgets/favorite_button.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../providers/favorites_provider.dart';
import '../services/favorite_api_service.dart';
import 'common_widgets.dart';

/// Nút tim có thể toggle yêu thích — tự load trạng thái ban đầu + hiển thị count
class FavoriteButton extends StatefulWidget {
  final String destinationId;
  final int initialCount;
  final bool showCount;
  final double iconSize;
  final Color? activeColor;

  const FavoriteButton({
    super.key,
    required this.destinationId,
    this.initialCount = 0,
    this.showCount = true,
    this.iconSize = 22,
    this.activeColor,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> with SingleTickerProviderStateMixin {
  bool _isFav = false;
  bool _loading = true;
  late int _count;
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _loadStatus();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    final token = context.read<AppState>().token;
    if (token == null) { setState(() => _loading = false); return; }
    try {
      final s = await FavoriteApiService(token: token).status(widget.destinationId);
      if (mounted) setState(() { _isFav = s; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle() async {
    final token = context.read<AppState>().token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để lưu yêu thích')));
      return;
    }
    try {
      final newState = await FavoriteApiService(token: token).toggle(widget.destinationId);
      if (mounted) {
        setState(() {
          _isFav = newState;
          _count = newState ? _count + 1 : (_count - 1).clamp(0, 999999);
        });
        _animCtrl.forward(from: 0);
        context.read<FavoritesProvider>().notifyChanged();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.activeColor ?? AppColors.error;
    return GestureDetector(
      onTap: _loading ? null : _toggle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scaleAnim,
            child: _loading
                ? SizedBox(
                    width: widget.iconSize, height: widget.iconSize,
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: color))
                : Icon(
                    _isFav ? Icons.favorite : Icons.favorite_border,
                    color: _isFav ? color : AppColors.muted,
                    size: widget.iconSize,
                  ),
          ),
          if (widget.showCount) ...[
            const SizedBox(width: 4),
            Text(
              _formatCount(_count),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _isFav ? color : AppColors.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}
