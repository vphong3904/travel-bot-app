import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AppUser {
  final int id;
  final String name;
  final String email;
  final String role;

  AppUser({required this.id, required this.name, required this.email, required this.role});
  bool get isAdmin => role == 'admin';

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        role: json['role'] ?? 'user',
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email, 'role': role};
}

class AppState extends ChangeNotifier {
  AppUser? user;
  String? token;

  bool get isLoggedIn => user != null;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    ApiClient.token = token;
    final userJson = prefs.getString('user');
    if (userJson != null) {
      user = AppUser.fromJson(jsonDecode(userJson));
    }
    notifyListeners();
  }

  Future<void> setSession(String newToken, AppUser newUser) async {
    token = newToken;
    ApiClient.token = newToken;
    user = newUser;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', newToken);
    await prefs.setString('user', jsonEncode(newUser.toJson()));
    notifyListeners();
  }

  Future<void> logout() async {
    user = null;
    token = null;
    ApiClient.token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    notifyListeners();
  }
}
