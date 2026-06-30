import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/models/auth_user.dart';
import '../../shared/providers/auth_provider.dart';

class _MenuItem {
  final String label;
  final String path;
  final IconData icon;
  final List<AdminRole> allowedRoles;

  const _MenuItem(this.label, this.path, this.icon, this.allowedRoles);
}

const _contentItems = [
  _MenuItem('Địa điểm',    '/content/destinations', Icons.place,             [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager]),
  _MenuItem('Khách sạn',   '/content/hotels',       Icons.hotel,             [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager]),
  _MenuItem('Tour',        '/content/tours',        Icons.tour,              [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager]),
  _MenuItem('Ẩm thực',    '/content/foods',        Icons.restaurant,        [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager]),
  _MenuItem('Nhà hàng',    '/content/restaurants',  Icons.restaurant_menu,   [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager]),
  _MenuItem('Mua sắm',     '/content/shopping',     Icons.shopping_bag,      [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager]),
  _MenuItem('Lịch trình',  '/content/itineraries',  Icons.map,               [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager]),
  _MenuItem('Sự kiện',     '/content/events',       Icons.event,             [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager]),
  _MenuItem('Di chuyển',   '/content/transport',    Icons.directions_bus,    [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager]),
  _MenuItem('FAQ',         '/content/faq',          Icons.quiz,              [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager]),
  _MenuItem('Trải nghiệm', '/content/experiences',  Icons.explore,           [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager]),
  _MenuItem('Quản lý ảnh', '/media',                Icons.photo_library,     [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager]),
];

const _topItems = [
  _MenuItem('Dashboard',       '/dashboard',       Icons.dashboard,     [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager, AdminRole.moderator]),
  _MenuItem('Người dùng',      '/users',           Icons.people,        [AdminRole.superAdmin, AdminRole.admin]),
  _MenuItem('Hội thoại',       '/chat',            Icons.chat_bubble,   [AdminRole.superAdmin, AdminRole.admin, AdminRole.moderator]),
  _MenuItem('Knowledge Base',  '/knowledge',       Icons.library_books, [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager]),
  _MenuItem('Feedback',        '/feedback',        Icons.thumb_up,      [AdminRole.superAdmin, AdminRole.admin, AdminRole.moderator]),
  _MenuItem('Media',           '/media',           Icons.perm_media,    [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager]),
  _MenuItem('RAG Monitor',     '/rag-monitoring',  Icons.monitor_heart, [AdminRole.superAdmin, AdminRole.admin]),
  _MenuItem('City Mapping',    '/city-mapping',    Icons.map_outlined,  [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager]),
  _MenuItem('Intent Patterns', '/intent-patterns', Icons.psychology,    [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager]),
  _MenuItem('Hệ thống',        '/system-config',   Icons.settings,      [AdminRole.superAdmin]),
];

class AdminSidebar extends ConsumerWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentRole = authState.user?.role;
    final location = GoRouterState.of(context).matchedLocation;

    bool canSee(_MenuItem item) =>
        currentRole != null &&
        item.allowedRoles.contains(currentRole);

    final visibleTop = _topItems.where(canSee).toList();
    final visibleContent =
        _contentItems.where(canSee).toList();

    final isContentRoute =
        location.startsWith('/content/');

    return ListView(
      children: [
        // Branding
        Padding(
          padding:
              const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PDTrip Admin',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (authState.user != null) ...[
                const SizedBox(height: 4),
                Text(
                  authState.user!.email,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  authState.user!.role.displayName,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1),

        // Top items
        ...visibleTop.map((item) => _NavTile(
              item: item,
              isSelected: item.path != '/dashboard'
                  ? location.startsWith(item.path)
                  : location == item.path,
            )),

        // Content group
        if (visibleContent.isNotEmpty) ...[
          ExpansionTile(
            leading: const Icon(Icons.article),
            title: const Text('Nội dung'),
            initiallyExpanded: isContentRoute,
            children: visibleContent
                .map((item) => _NavTile(
                      item: item,
                      isSelected:
                          location.startsWith(item.path),
                      indent: 16,
                    ))
                .toList(),
          ),
        ],

        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Đăng xuất'),
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Đăng xuất'),
                content: const Text('Bạn có chắc muốn đăng xuất không?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Huỷ'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.red),
                    child: const Text('Đăng xuất'),
                  ),
                ],
              ),
            );
            if (confirmed == true && context.mounted) {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            }
          },
        ),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  final _MenuItem item;
  final bool isSelected;
  final double indent;

  const _NavTile({
    required this.item,
    required this.isSelected,
    this.indent = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(
          left: 16 + indent, right: 16),
      leading: Icon(
        item.icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : null,
        size: 20,
      ),
      title: Text(
        item.label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected
              ? FontWeight.w600
              : FontWeight.normal,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(context)
          .colorScheme
          .primary
          .withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)),
      onTap: () {
        context.go(item.path);
        if (Scaffold.of(context).isDrawerOpen) {
          Navigator.pop(context);
        }
      },
    );
  }
}