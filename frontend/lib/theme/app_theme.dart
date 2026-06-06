import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';

// ─────────────────────────────────────────────
//  TEXT STYLES
// ─────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  // Display / Heading
  static TextStyle heading({
    double size = 16,
    Color color = AppColors.dark,
    FontWeight weight = FontWeight.w700,
    double? height,
  }) =>
      TextStyle(
        fontFamily: 'Nunito',
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height ?? 1.3,
        letterSpacing: -0.3,
      );

  // Body / Label
  static TextStyle body({
    double size = 14,
    Color color = AppColors.mid,
    FontWeight weight = FontWeight.w400,
    double? height,
  }) =>
      TextStyle(
        fontFamily: 'Nunito',
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height ?? 1.5,
      );

  // Caption
  static TextStyle caption({
    double size = 11,
    Color color = AppColors.muted,
    FontWeight weight = FontWeight.w500,
  }) =>
      TextStyle(
        fontFamily: 'Nunito',
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: 0.2,
      );

  // ─── ThemeData ───────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Nunito',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          error: AppColors.error,
          surface: AppColors.surface,
          onPrimary: AppColors.white,
          onSecondary: AppColors.white,
          onSurface: AppColors.dark,
        ),
        scaffoldBackgroundColor: AppColors.surface,

        // AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.dark,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          shadowColor: AppColors.border,
          centerTitle: false,
          titleTextStyle: heading(size: 18),
          iconTheme: const IconThemeData(color: AppColors.mid),
          actionsIconTheme: const IconThemeData(color: AppColors.mid),
          surfaceTintColor: Colors.transparent,
        ),

        // Card
        cardTheme: CardThemeData(
          color: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border),
          ),
          margin: EdgeInsets.zero,
        ),

        // FloatingActionButton
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 4,
          shape: CircleBorder(),
        ),

        // Chip / FilterChip
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.white,
          selectedColor: AppColors.primary.withValues(alpha: 0.12),
          side: const BorderSide(color: AppColors.border),
          labelStyle: body(size: 12, weight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          checkmarkColor: AppColors.primary,
        ),

        // Input / TextField
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          labelStyle: body(size: 13, color: AppColors.muted),
          hintStyle: body(size: 13, color: AppColors.muted),
          floatingLabelStyle: body(size: 12, color: AppColors.primary, weight: FontWeight.w600),
        ),

        // ElevatedButton
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: body(size: 15, weight: FontWeight.w700),
          ),
        ),

        // TextButton
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: body(size: 14, weight: FontWeight.w600),
          ),
        ),

        // OutlinedButton
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),

        // ListTile
        listTileTheme: ListTileThemeData(
          tileColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          titleTextStyle: body(size: 15, weight: FontWeight.w600, color: AppColors.dark),
          subtitleTextStyle: body(size: 12, color: AppColors.muted),
        ),

        // BottomSheet
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),

        // Dialog
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titleTextStyle: heading(size: 17),
          contentTextStyle: body(size: 14, color: AppColors.mid),
        ),

        // Snackbar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.dark,
          contentTextStyle: body(size: 13, color: AppColors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 1,
        ),

        // PopupMenu
        popupMenuTheme: PopupMenuThemeData(
          color: AppColors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          labelTextStyle: WidgetStateProperty.all(body(size: 14)),
        ),

        // Progress indicator
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
        ),
      );
}

// ─────────────────────────────────────────────
//  DECORATION HELPERS
// ─────────────────────────────────────────────
class AppDecorations {
  AppDecorations._();

  static BoxDecoration card({
    Color color = AppColors.white,
    double radius = 20,
    bool withShadow = true,
  }) =>
      BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border),
        boxShadow: withShadow
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 2))]
            : null,
      );

  static BoxDecoration iconBadge(Color color, {double radius = 12}) => BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius),
      );

  static BoxDecoration pill(Color color) => BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      );
}