import 'package:flutter/material.dart';
import 'admin_sidebar.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;

  const AdminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1024;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            SizedBox(width: 280, child: Drawer(child: AdminSidebar())),
            const VerticalDivider(width: 1),
            Expanded(child: _Content(child: child)),
          ],
        ),
      );
    }

    return Scaffold(
      drawer: const Drawer(child: AdminSidebar()),
      appBar: AppBar(title: const Text('PDTrip Admin')),
      body: _Content(child: child),
    );
  }
}

class _Content extends StatelessWidget {
  final Widget child;
  const _Content({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: child,
      ),
    );
  }
}