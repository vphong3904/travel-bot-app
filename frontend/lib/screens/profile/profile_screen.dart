// lib/screens/profile/profile_screen.dart
//
// ProfileScreen — Tab "Hồ sơ" (Tab 4)
//
// FIX: Sau logout → navigate về LoginRegisterScreen
//      (không dùng Navigator.pop vì ProfileScreen nằm trong IndexedStack,
//       không có màn hình nào phía sau để pop về)
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/destination.dart';
import '../../providers/app_state.dart';
import '../../providers/favorites_provider.dart';
import '../../services/favorite_api_service.dart';
import '../../services/review_api_service.dart';
import '../../services/trip_api_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/destination_card.dart';
import '../../widgets/user_profile_card.dart';
import '../auth/login_register_screen.dart';
import '../chat/chatbot_screen.dart';
import '../chat/chat_history_screen.dart';
import '../trip_detail/destination_detail_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Destination> _favorites = [];
  bool _favLoading = true;
  bool _loggingOut = false;
  int? _tripCount;     // null = đang tải
  int? _reviewCount;
  // Theo dõi version của FavoritesProvider để tải lại đúng lúc dữ liệu thực
  // sự thay đổi ở nơi khác (thêm/xoá yêu thích), không gọi API thừa.
  int _lastSeenFavVersion = -1;

  @override
  void initState() {
    super.initState();
    _lastSeenFavVersion = context.read<FavoritesProvider>().version;
    _loadFavorites();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final s = context.read<AppState>();
    if (!s.isLoggedIn) return;
    try {
      final trips = await TripApiService(
        tokenProvider: () => s.token,
        tokenRefresher: () => s.refreshAccessToken(),
      ).listTrips();
      if (mounted) setState(() => _tripCount = trips.length);
    } catch (_) {
      if (mounted) setState(() => _tripCount = 0);
    }
    try {
      final n = await ReviewApiService(token: s.token ?? '').myReviewCount();
      if (mounted) setState(() => _reviewCount = n);
    } catch (_) {
      if (mounted) setState(() => _reviewCount = 0);
    }
  }

  Future<void> _loadFavorites() async {
    final token = context.read<AppState>().token;
    if (token == null) {
      setState(() => _favLoading = false);
      return;
    }
    try {
      final data = await FavoriteApiService(token: token).listMyFavorites();
      if (mounted) setState(() { _favorites = data; _favLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _favLoading = false);
    }
  }

  Future<void> _doLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn sẽ cần đăng nhập lại để tiếp tục.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _loggingOut = true);
    try {
      // Xóa token + user khỏi SharedPreferences + revoke trên server
      await context.read<AppState>().logout();

      if (!mounted) return;
      // Navigate về LoginRegisterScreen, xóa toàn bộ stack
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginRegisterScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 350),
        ),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _loggingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Đăng xuất thất bại: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.user;

    final favVersion = context.watch<FavoritesProvider>().version;
    if (!_favLoading && favVersion != _lastSeenFavVersion) {
      _lastSeenFavVersion = favVersion;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadFavorites();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Thẻ thông tin user — dùng chung với SettingsScreen (UserProfileCard)
              if (user != null)
                UserProfileCard(user: user)
              else
                Column(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.14),
                      child: _avatarInitial('K'),
                    ),
                    const SizedBox(height: 10),
                    const Text('Khách',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.dark)),
                    const SizedBox(height: 2),
                    const Text('Chưa đăng nhập',
                        style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  ],
                ),
              const SizedBox(height: 20),

              // Stats row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(
                      label: 'Chuyến đi',
                      value: !appState.isLoggedIn
                          ? '–'
                          : _tripCount == null ? '…' : '$_tripCount',
                    ),
                    Container(width: 1, height: 30, color: AppColors.border),
                    _StatItem(
                      label: 'Yêu thích',
                      value: _favLoading ? '…' : '${_favorites.length}',
                    ),
                    Container(width: 1, height: 30, color: AppColors.border),
                    _StatItem(
                      label: 'Đánh giá',
                      value: !appState.isLoggedIn
                          ? '–'
                          : _reviewCount == null ? '…' : '$_reviewCount',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Yêu thích — chỉ hiện khi đã đăng nhập
              if (appState.isLoggedIn) ...[
                const SectionTitle(title: '❤️ Yêu thích của tôi'),
                const SizedBox(height: 12),
                if (_favLoading)
                  const Center(child: CircularProgressIndicator(strokeWidth: 2))
                else if (_favorites.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Column(children: [
                      Icon(Icons.favorite_border, size: 32, color: AppColors.muted),
                      SizedBox(height: 8),
                      Text('Chưa có địa điểm yêu thích',
                          style: TextStyle(color: AppColors.muted)),
                      SizedBox(height: 4),
                      Text('Nhấn ❤️ trên bất kỳ địa điểm nào để lưu',
                          style: TextStyle(color: AppColors.muted, fontSize: 12),
                          textAlign: TextAlign.center),
                    ]),
                  )
                else
                  SizedBox(
                    height: 240,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _favorites.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => SizedBox(
                        width: 160,
                        child: DestinationCard(
                          destination: _favorites[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DestinationDetailScreen(
                                  destination: _favorites[i]),
                            ),
                          ).then((_) => _loadFavorites()),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
              ],

              // Menu hoạt động — chỉ hiện khi đã đăng nhập
              if (appState.isLoggedIn) ...[
                const _SectionHeader(title: 'Hoạt động'),
                _MenuTile(
                    icon: Icons.smart_toy,
                    title: 'Chat với AI',
                    subtitle: 'Hỏi đáp và lên lịch trình',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ChatBotScreen()))),
                _MenuTile(
                    icon: Icons.history,
                    title: 'Lịch sử hội thoại',
                    subtitle: 'Xem lại các cuộc trò chuyện',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ChatHistoryScreen()))),
                const SizedBox(height: 16),
              ],
              const _SectionHeader(title: 'Hệ thống'),
              _MenuTile(
                  icon: Icons.settings_outlined,
                  title: 'Cài đặt',
                  subtitle: 'Ngôn ngữ, thông báo, giao diện',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()))),
              _MenuTile(
                  icon: Icons.info_outline,
                  title: 'Về ứng dụng',
                  subtitle: 'PDTrip AI v1.0',
                  onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'PDTrip AI',
                      applicationVersion: '1.0.0')),
              const SizedBox(height: 24),

              // Nút đăng nhập / đăng xuất tuỳ trạng thái
              if (appState.isLoggedIn)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _loggingOut ? null : _doLogout,
                    icon: _loggingOut
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.error),
                          )
                        : const Icon(Icons.logout, color: AppColors.error),
                    label: Text(
                      _loggingOut ? 'Đang đăng xuất...' : 'Đăng xuất',
                      style: const TextStyle(
                          color: AppColors.error, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const LoginRegisterScreen(),
                        transitionsBuilder: (_, anim, __, child) =>
                            FadeTransition(opacity: anim, child: child),
                        transitionDuration: const Duration(milliseconds: 350),
                      ),
                      (route) => false,
                    ),
                    icon: const Icon(Icons.login, color: Colors.white),
                    label: const Text(
                      'Đăng nhập',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarInitial(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Text(initial,
        style: const TextStyle(
            fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.primary));
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 10),
          child: Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.muted,
                  letterSpacing: 1.1)),
        ),
      );
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary)),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ],
      );
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _MenuTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      this.onTap});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          title: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(subtitle,
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
          onTap: onTap,
        ),
      );
}