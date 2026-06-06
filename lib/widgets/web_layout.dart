import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

// ─────────────────────────────────────────────
//  BREAKPOINTS
// ─────────────────────────────────────────────
class WebBreakpoints {
  static const double mobile  = 600;
  static const double tablet  = 900;
  static const double desktop = 1200;
}

bool isDesktop(BuildContext ctx)  => MediaQuery.of(ctx).size.width >= WebBreakpoints.tablet;
bool isTablet(BuildContext ctx)   => MediaQuery.of(ctx).size.width >= WebBreakpoints.mobile;
bool isMobile(BuildContext ctx)   => MediaQuery.of(ctx).size.width < WebBreakpoints.mobile;

// ─────────────────────────────────────────────
//  WEB COLORS (overrides / extras for web UI)
// ─────────────────────────────────────────────
class WebColors {
  WebColors._();

  static const Color sidebarBg   = Color(0xFF0F172A); // slate-900
  static const Color sidebarHover = Color(0xFF1E293B); // slate-800
  static const Color sidebarActive = Color(0xFF334155); // slate-700
  static const Color topbarBg    = Color(0xFFFFFFFF);
  static const Color topbarBorder = Color(0xFFF1F5F9);
  static const Color contentBg   = Color(0xFFF8FAFC);
  static const Color cardBg      = Color(0xFFFFFFFF);
}

// ─────────────────────────────────────────────
//  SIDEBAR NAV ITEM MODEL
// ─────────────────────────────────────────────
class SidebarItem {
  final IconData icon;
  final String label;
  final Widget? screen;
  final VoidCallback? onTap;

  const SidebarItem({
    required this.icon,
    required this.label,
    this.screen,
    this.onTap,
  });
}

// ─────────────────────────────────────────────
//  ADMIN SHELL — responsive sidebar + topbar
// ─────────────────────────────────────────────
class WebAdminShell extends StatelessWidget {
  final Widget child;
  final String? pageTitle;

  const WebAdminShell({
    super.key,
    required this.child,
    this.pageTitle,
  });

  @override
  Widget build(BuildContext context) {
    // On mobile: just return the child unchanged (scaffold handles it).
    if (!isDesktop(context)) return child;

    // On desktop: wrap in sidebar + topbar layout.
    return Scaffold(
      backgroundColor: WebColors.contentBg,
      body: Row(
        children: [
          const _Sidebar(),
          Expanded(
            child: Column(
              children: [
                if (pageTitle != null) _Topbar(title: pageTitle!),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SIDEBAR
// ─────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  const _Sidebar();

  static const _navItems = <SidebarItem>[
    SidebarItem(icon: Icons.dashboard_rounded,       label: 'Dashboard'),
    SidebarItem(icon: Icons.library_books_outlined,  label: 'Knowledge Base'),
    SidebarItem(icon: Icons.people_outline_rounded,  label: 'Người dùng'),
    SidebarItem(icon: Icons.history_rounded,         label: 'Log hội thoại'),
    SidebarItem(icon: Icons.bar_chart_rounded,       label: 'Thống kê'),
    SidebarItem(icon: Icons.settings_outlined,       label: 'Cài đặt'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: WebColors.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo area
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  'TravelBot',
                  style: AppTheme.heading(size: 17, color: Colors.white),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: _SidebarSection(label: 'QUẢN TRỊ'),
          ),

          ..._navItems.map((item) => _SidebarNavItem(item: item)),

          const Spacer(),

          // Footer / logout
          const Divider(color: WebColors.sidebarActive, height: 1),
          const _SidebarUserTile(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _SidebarSection extends StatelessWidget {
  final String label;
  const _SidebarSection({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTheme.caption(color: const Color(0xFF475569), weight: FontWeight.w700),
    );
  }
}

class _SidebarNavItem extends StatefulWidget {
  final SidebarItem item;
  const _SidebarNavItem({required this.item});

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool active = false; // TODO: connect route-aware active state

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.item.onTap ??
            () {
              if (widget.item.screen != null) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => widget.item.screen!));
              }
            },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? WebColors.sidebarActive
                : _hovered
                    ? WebColors.sidebarHover
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                widget.item.icon,
                size: 18,
                color: active ? AppColors.primary : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 10),
              Text(
                widget.item.label,
                style: AppTheme.body(
                  size: 13,
                  color: active ? Colors.white : const Color(0xFFCBD5E1),
                  weight: active ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarUserTile extends StatelessWidget {
  const _SidebarUserTile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: const Icon(Icons.person_rounded, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin', style: AppTheme.body(size: 13, color: Colors.white, weight: FontWeight.w600)),
                Text('admin@system.vn', style: AppTheme.caption(color: const Color(0xFF64748B))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFF64748B)),
            onPressed: () {},
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TOP BAR  (optional title bar for web pages)
// ─────────────────────────────────────────────
class _Topbar extends StatelessWidget {
  final String title;
  const _Topbar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: WebColors.topbarBg,
        border: Border(bottom: BorderSide(color: WebColors.topbarBorder)),
      ),
      child: Row(
        children: [
          Text(title, style: AppTheme.heading(size: 17)),
          const Spacer(),
          // Breadcrumb placeholder
          Text('Trang chủ / $title', style: AppTheme.caption()),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WEB-SPECIFIC CARD VARIANTS
// ─────────────────────────────────────────────
class WebCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;

  const WebCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WebColors.cardBg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────
//  RESPONSIVE GRID HELPER
// ─────────────────────────────────────────────
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns  = 1,
    this.tabletColumns  = 2,
    this.desktopColumns = 3,
    this.spacing        = 16,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cols = w >= WebBreakpoints.desktop
        ? desktopColumns
        : w >= WebBreakpoints.mobile
            ? tabletColumns
            : mobileColumns;

    return GridView.count(
      crossAxisCount: cols,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}