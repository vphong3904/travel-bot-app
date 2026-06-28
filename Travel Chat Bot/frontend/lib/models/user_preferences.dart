class UserPreferences {
  final String language;
  final String theme;
  final bool notifications;
  final bool darkMode;

  UserPreferences({
    this.language = 'vi',
    this.theme = 'light',
    this.notifications = true,
    this.darkMode = false,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      language: json['language']?.toString() ?? 'vi',
      theme: json['theme']?.toString() ?? 'light',
      notifications: json['notifications'] as bool? ?? true,
      darkMode: json['dark_mode'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'theme': theme,
      'notifications': notifications,
      'dark_mode': darkMode,
    };
  }
}
