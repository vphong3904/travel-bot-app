import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/admin_user.dart';
import '../providers/auth_provider.dart';

class _MenuItem {
  final String label;
  final String path;
  final IconData icon;
  final List<UserRole> allowedRoles;

  const _MenuItem(this.label, this.path, this.icon, this.allowedRoles);
}

const _menuItems = [
  _MenuItem('Dashboard',       '/admin',                 Icons.dashboard,       [UserRole.superAdmin, UserRole.admin, UserRole.contentManager, UserRole.moderator]),
  _MenuItem('Người dùng',      '/admin/users',           Icons.people,          [UserRole.superAdmin, UserRole.admin]),
  _MenuItem('Hội thoại',       '/admin/chat',            Icons.chat_bubble,     [UserRole.superAdmin, UserRole.admin, UserRole.moderator]),
  _MenuItem('Knowledge Base',  '/admin/knowledge',       Icons.library_books,   [UserRole.superAdmin, UserRole.admin, UserRole.contentManager]),
  _MenuItem('Nội dung',        '/admin/content',         Icons.article,         [UserRole.superAdmin, UserRole.admin, UserRole.contentManager]),
  _MenuItem('Feedback',        '/admin/feedback',        Icons.thumb_up,        [UserRole.superAdmin, UserRole.admin, UserRole.moderator]),
  _MenuItem('Media',           '/admin/media',           Icons.perm_media,      [UserRole.superAdmin, UserRole.admin, UserRole.contentManager]),
  _MenuItem('RAG Monitor',     '/admin/rag-monitoring',  Icons.monitor_heart,   [UserRole.superAdmin, UserRole.admin]),
  _MenuItem('City Mapping',    '/admin/city-mapping',    Icons.map,             [UserRole.superAdmin, UserRole.admin, UserRole.contentManager]),
  _MenuItem('Intent Patterns', '/admin/intent-patterns', Icons.psychology,      [UserRole.superAdmin, UserRole.admin, UserRole.contentManager]),
  _MenuItem('Hệ thống',        '/admin/system-config',   Icons.settings,        [UserRole.superAdmin]),
];

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AdminAuthProvider>();
    final currentRole = auth.user?.role;
    final location = GoRouterState.of(context).matchedLocation;

    final visibleItems = _menuItems
        .where((item) => currentRole != null && item.allowedRoles.contains(currentRole))
        .toList();

    return NavigationDrawer(
      selectedIndex: visibleItems.indexWhere((item) => location.startsWith(item.path) && item.path != '/admin'
          ? true
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
              Text('PDTrip Admin', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              if (auth.user != null) ...[
                const SizedBox(height: 4),
                Text(auth.user!.email, style: Theme.of(context).textTheme.bodySmall),
                Text(auth.user!.role.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
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
            auth.clearAuth();
            context.go('/admin/login');
          },
        ),
      ],
    );
  }
}
