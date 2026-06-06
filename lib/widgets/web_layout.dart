import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Admin: giới hạn chiều rộng trên màn desktop để dễ đọc.
class WebAdminShell extends StatelessWidget {
  final Widget child;

  const WebAdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: child,
      ),
    );
  }
}
