// lib/screens/services/favorites_screen.dart
// [P2] Yêu thích của tôi — nhóm theo danh mục, lọc theo từng danh mục.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/destination.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../services/favorite_api_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/loading_state_widgets.dart';
import '../auth/login_register_screen.dart';
import '../trip_detail/destination_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _loading = true;
  String? _error;
  List<Destination> _favorites = [];
  String _selectedCat = 'Tất cả';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) _load();
  }

  Future<void> _load() async {
    final s = context.read<AppState>();
    if (!s.isLoggedIn) {
      setState(() { _loading = false; _error = 'login'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final favs = await FavoriteApiService(token: s.token ?? '').listMyFavorites();
      if (!mounted) return;
      setState(() { _favorites = favs; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = friendlyError(e); _loading = false; });
    }
  }

  // Danh sách danh mục có trong favorites
  List<String> get _categories {
    final set = <String>{};
    for (final d in _favorites) {
      for (final c in d.categories) {
        if (c.name.isNotEmpty) set.add(c.name);
      }
    }
    return ['Tất cả', ...set.toList()..sort()];
  }

  List<Destination> get _filtered {
    if (_selectedCat == 'Tất cả') return _favorites;
    return _favorites
        .where((d) => d.categories.any((c) => c.name == _selectedCat))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Yêu thích của tôi',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: _loading
          ? const LoadingScreen(message: 'Đang tải...')
          : _error == 'login'
              ? _loginPrompt()
              : _error != null
                  ? ErrorScreen(message: _error!, onRetry: _load)
                  : _favorites.isEmpty
                      ? EmptyScreen(
                          title: 'Chưa có yêu thích',
                          message: 'Nhấn ♥ ở điểm đến để lưu vào đây.',
                          icon: Icons.favorite_border,
                          onRetry: _load,
                        )
                      : Column(
                          children: [
                            _categoryFilter(),
                            Expanded(
                              child: RefreshIndicator(
                                color: AppColors.primary,
                                onRefresh: _load,
                                child: ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                                  itemCount: _filtered.length,
                                  itemBuilder: (_, i) => _favCard(_filtered[i]),
                                ),
                              ),
                            ),
                          ],
                        ),
    );
  }

  Widget _categoryFilter() {
    final cats = _categories;
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = cats[i];
          final sel = c == _selectedCat;
          return ChoiceChip(
            label: Text(c),
            selected: sel,
            onSelected: (_) => setState(() => _selectedCat = c),
            selectedColor: AppColors.primary.withValues(alpha: 0.15),
            backgroundColor: Colors.white,
            side: BorderSide(color: sel ? AppColors.primary : Colors.grey.shade300),
            labelStyle: TextStyle(
              color: sel ? AppColors.primary : AppColors.dark,
              fontWeight: sel ? FontWeight.bold : FontWeight.w500,
              fontSize: 12.5,
            ),
          );
        },
      ),
    );
  }

  Widget _favCard(Destination d) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => DestinationDetailScreen(destination: d))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
              child: SizedBox(
                width: 90, height: 90,
                child: d.imageUrl.isNotEmpty
                    ? Image.network(d.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _ph())
                    : _ph(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(d.province ?? d.region,
                        style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 5, runSpacing: 4,
                      children: d.categories.take(3).map((c) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(c.name,
                            style: const TextStyle(fontSize: 10, color: AppColors.secondary)),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.favorite, color: AppColors.error, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ph() => Container(
        color: AppColors.primary.withValues(alpha: 0.08),
        child: const Icon(Icons.place_outlined, color: AppColors.primary, size: 28),
      );

  Widget _loginPrompt() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: AppColors.muted),
              const SizedBox(height: 14),
              const Text('Đăng nhập để xem danh sách yêu thích',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: AppColors.dark)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LoginRegisterScreen())),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: const Text('Đăng nhập'),
              ),
            ],
          ),
        ),
      );
}
