import 'package:flutter/material.dart';

/// Tạo Snackbar thông báo
void showInfoSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.blue,
      duration: const Duration(seconds: 2),
    ),
  );
}

/// Hiển thị dialog tương tác với 2 button
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  String confirmText = 'Xác nhận',
  String cancelText = 'Hủy',
  bool isDanger = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(cancelText)),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: isDanger ? Colors.red : Colors.blue),
          child: Text(confirmText, style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

/// Hiển thị bottom sheet loading
void showLoadingBottomSheet(BuildContext context, String message) {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 16),
          Text(message, style: const TextStyle(fontSize: 14)),
        ],
      ),
    ),
  );
}
