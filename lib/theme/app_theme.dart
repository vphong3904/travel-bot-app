import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/common_widgets.dart';

/// Font có subset Vietnamese trên Google Fonts.
class AppFonts {
  static TextStyle heading({
    double size = 22,
    Color color = AppColors.dark,
    FontWeight weight = FontWeight.w700,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.25,
      );

  static TextStyle body({
    double size = 14,
    Color color = AppColors.dark,
    FontWeight weight = FontWeight.w500,
    double? height,
  }) =>
      GoogleFonts.beVietnamPro(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height ?? 1.45,
      );

  static TextStyle label({Color color = AppColors.muted}) => GoogleFonts.beVietnamPro(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.2,
        height: 1.3,
      );
}

class AppTheme {
  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: GoogleFonts.beVietnamPro().fontFamily,
    );

    final bodyTheme = GoogleFonts.beVietnamProTextTheme(base.textTheme).apply(
      bodyColor: AppColors.dark,
      displayColor: AppColors.dark,
    );

    final textTheme = bodyTheme.copyWith(
      headlineLarge: AppFonts.heading(size: 28, weight: FontWeight.w800),
      headlineMedium: AppFonts.heading(size: 24, weight: FontWeight.w700),
      headlineSmall: AppFonts.heading(size: 20, weight: FontWeight.w700),
      titleLarge: AppFonts.heading(size: 18, weight: FontWeight.w700),
      titleMedium: AppFonts.heading(size: 16, weight: FontWeight.w700),
      titleSmall: AppFonts.body(size: 14, weight: FontWeight.w600),
      bodyLarge: AppFonts.body(size: 16),
      bodyMedium: AppFonts.body(size: 14),
      bodySmall: AppFonts.body(size: 12, color: AppColors.muted),
      labelLarge: AppFonts.body(size: 14, weight: FontWeight.w600),
      labelMedium: AppFonts.label(),
      labelSmall: AppFonts.label(color: AppColors.muted),
    );

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.dark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppFonts.heading(size: 18),
        toolbarTextStyle: AppFonts.body(size: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppFonts.body(
            size: 10,
            weight: FontWeight.w600,
            color: selected ? AppColors.primary : AppColors.muted,
          );
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: AppFonts.heading(size: 15, weight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: AppFonts.body(size: 14, color: const Color(0xFF94A3B8)),
        labelStyle: AppFonts.label(color: const Color(0xFF475569)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        labelStyle: AppFonts.body(size: 13, weight: FontWeight.w500),
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: AppFonts.body(size: 13, weight: FontWeight.w600),
        unselectedLabelStyle: AppFonts.body(size: 13, weight: FontWeight.w500, color: AppColors.muted),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: AppFonts.body(size: 15, weight: FontWeight.w600),
        subtitleTextStyle: AppFonts.body(size: 12, color: AppColors.muted),
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: AppFonts.body(size: 14, color: Colors.white),
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: AppFonts.heading(size: 18),
        contentTextStyle: AppFonts.body(size: 14, color: AppColors.mid),
      ),
    );
  }

  static TextStyle heading({double size = 22, Color color = AppColors.dark, FontWeight weight = FontWeight.w700}) =>
      AppFonts.heading(size: size, color: color, weight: weight);

  static TextStyle body({double size = 14, Color color = AppColors.dark, FontWeight weight = FontWeight.w500}) =>
      AppFonts.body(size: size, color: color, weight: weight);

  static TextStyle label({Color color = AppColors.muted}) => AppFonts.label(color: color);
}
