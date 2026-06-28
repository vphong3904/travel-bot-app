import 'package:flutter/material.dart';
import '../widgets/placeholder_page.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SizedBox(
        width: 400,
        child: PlaceholderPage(title: 'Đăng nhập Admin', taskRef: 'TA-004'),
      ),
    ),
  );
}
