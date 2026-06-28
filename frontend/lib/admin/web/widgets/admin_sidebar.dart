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

const _menuItems = [
  _MenuItem('Dashboard',       '/dashboard',             Icons.dashboard,       [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager, AdminRole.moderator]),
  _MenuItem('Người dùng',      '/users',                 Icons.people,          [AdminRole.superAdmin, AdminRole.admin]),
  _MenuItem('Hội thoại',       '/chat',                  Icons.chat_bubble,     [AdminRole.superAdmin, AdminRole.admin, AdminRole.moderator]),
  _MenuItem('Knowledge Base',  '/knowledge',             Icons.library_books,   [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager]),
  _MenuItem('Nội dung',        '/content',               Icons.article,         [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager]),
  _MenuItem('Feedback',        '/feedback',              Icons.thumb_up,        [AdminRole.superAdmin, AdminRole.admin, AdminRole.moderator]),
  _MenuItem('Media',           '/media',                 Icons.perm_media,      [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager]),
  _MenuItem('RAG Monitor',     '/rag-monitoring',        Icons.monitor_heart,   [AdminRole.superAdmin, AdminRole.admin]),
  _MenuItem('City Mapping',    '/city-mapping',          Icons.map,             [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager]),
  _MenuItem('Intent Patterns', '/intent-patterns',       Icons.psychology,      [AdminRole.superAdmin, AdminRole.admin, AdminRole.contentManager]),
  _MenuItem('Hệ thống',        '/system-config',         Icons.settings,        [AdminRole.superAdmin]),
];

class AdminSidebar extends ConsumerWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentRole = authState.user?.role;
    final location = GoRouterState.of(context).matchedLocation;

    final visibleItems = _menuItems
        .where((item) =>
            currentRole != null && item.allowedRoles.contains(currentRole))
        .toList();

    return NavigationDrawer(
      selectedIndex: visibleItems.indexWhere((item) =>
          item.path != '/dashboard'
              ? location.startsWith(item.path)
              : location == item.path),
      onDestinationSelected: (index) {
        context.go(visibleItems[index].path);
        if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ],
          ),
        ),
        const Divider(),
        ...visibleItems.map((item) => NavigationDrawerDestination(
              icon: Icon(item.icon),
              label: Text(item.label),
            )),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Đăng xuất'),
          onTap: () {
            ref.read(authProvider.notifier).logout();
            context.go('/login');
          },
        ),
      ],
    );
  }
}
