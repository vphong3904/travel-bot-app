import 'package:flutter/material.dart';
import '../widgets/placeholder_page.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PlaceholderPage(title: 'Dashboard', taskRef: 'TA-005');
}
