import 'package:flutter/foundation.dart';
import '../models/admin_user.dart';

class AdminAuthProvider extends ChangeNotifier {
  String? _accessToken;
  AdminUser? _user;

  String? get accessToken => _accessToken;
  AdminUser? get user => _user;
  bool get isLoggedIn => _accessToken != null && _user != null;

  void setAuth(String token, AdminUser user) {
    _accessToken = token;
    _user = user;
    notifyListeners();
  }

  void clearAuth() {
    _accessToken = null;
    _user = null;
    notifyListeners();
  }

  bool hasRole(List<UserRole> roles) => _user?.hasRole(roles) ?? false;
}
