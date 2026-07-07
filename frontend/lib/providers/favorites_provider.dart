// lib/providers/favorites_provider.dart
//
// Thông báo toàn cục mỗi khi danh sách yêu thích thay đổi (thêm/xoá), để các
// màn khác (Yêu thích, Hồ sơ) biết cần tải lại — thay vì mỗi màn tự cache
// riêng và không bao giờ biết dữ liệu đã đổi ở nơi khác.
import 'package:flutter/foundation.dart';

class FavoritesProvider extends ChangeNotifier {
  int _version = 0;
  int get version => _version;

  /// Gọi mỗi khi thêm/xoá 1 yêu thích thành công ở bất kỳ đâu trong app.
  void notifyChanged() {
    _version++;
    notifyListeners();
  }
}
