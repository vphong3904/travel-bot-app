// lib/widgets/google_web_button_web.dart
// Chỉ compile trên Web (import qua conditional export ở google_web_button.dart).
// Google bắt buộc dùng nút Sign-In native render qua GIS/FedCM trên Web,
// không thể tự vẽ nút custom rồi gọi authenticate() như Android/iOS.
import 'package:flutter/material.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';

Widget buildGoogleWebButton() {
  final instance = GoogleSignInPlatform.instance;
  // Nếu plugin web chưa được đăng ký (thường do Windows chưa bật Developer
  // Mode → Flutter không sinh được web_plugin_registrant), instance sẽ là
  // placeholder chứ không phải GoogleSignInPlugin. Tránh cast crash cả app.
  if (instance is! GoogleSignInPlugin) {
    return const SizedBox.shrink();
  }
  return instance.renderButton();
}
