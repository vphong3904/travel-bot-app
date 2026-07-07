// lib/widgets/google_web_button.dart
// Entry point — tự chọn implementation đúng theo platform lúc compile.
export 'google_web_button_stub.dart'
    if (dart.library.html) 'google_web_button_web.dart';
