// lib/utils/time_ago.dart
// Trả về chuỗi "x phút trước" / "x giờ trước" / "x ngày trước" / "x tuần trước"
// giống cách Facebook hiển thị, tính từ created_at UTC.

String timeAgo(DateTime? dt) {
  if (dt == null) return '';
  final now = DateTime.now().toUtc();
  final diff = now.difference(dt.toUtc());

  if (diff.inSeconds < 60) return 'Vừa xong';
  if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
  if (diff.inHours < 24) return '${diff.inHours} giờ trước';
  if (diff.inDays < 7) return '${diff.inDays} ngày trước';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} tuần trước';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} tháng trước';
  return '${(diff.inDays / 365).floor()} năm trước';
}
