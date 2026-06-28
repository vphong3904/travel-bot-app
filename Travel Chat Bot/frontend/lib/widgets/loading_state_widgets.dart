import 'package:flutter/material.dart';

/// Hiển thị trạng thái loading toàn màn hình
class LoadingScreen extends StatelessWidget {
  final String? message;

  const LoadingScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(strokeWidth: 3),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: const TextStyle(fontSize: 14)),
          ],
        ],
      ),
    );
  }
}

/// Hiển thị trạng thái lỗi
class ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorScreen({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15)),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Hiển thị trạng thái trống (không có dữ liệu)
class EmptyScreen extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  const EmptyScreen({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Làm mới'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Hiển thị loading ở bottom sheet
class LoadingBottomSheet extends StatelessWidget {
  final String message;

  const LoadingBottomSheet({super.key, this.message = 'Đang tải...'});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        const SizedBox(width: 12),
        Text(message),
      ],
    );
  }
}

/// Hiển thị SnackBar lỗi
void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    ),
  );
}

/// Hiển thị SnackBar thành công
void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ),
  );
}
