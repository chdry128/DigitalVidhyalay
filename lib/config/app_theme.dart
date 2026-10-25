// ============================================================
//  APP THEME — Font, text sizes, button aur input box ka style
//
//  • Font badalna ho      → _fontFamily line badlein
//  • Text ka size badalna → niche AppText class me
//  • Button ka style      → elevatedButtonTheme
//  • Rang badalna ho      → app_colors.dart (yahan nahi)
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Corner (gol kona) aur spacing ke fixed numbers
class AppSizes {
  AppSizes._();
  static const double radiusCard = 12; // Cards ka gol kona
  static const double radiusButton = 10; // Buttons / input ka gol kona
  static const double screenPadding = 16; // Screen ke left-right ki jagah
  static const double gap = 12; // Do cards ke beech ki jagah
}

/// Text styles — poori app me yahi sizes use hote hain
class AppText {
  AppText._();
  static const TextStyle h1 = TextStyle(
      fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.25);
  static const TextStyle h2 = TextStyle(
      fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark, height: 1.3);
  static const TextStyle title = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark, height: 1.3);
  static const TextStyle cardTitle = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark, height: 1.35);
  static const TextStyle body = TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.5);
  static const TextStyle muted = TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.45);
  static const TextStyle small = TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.35);
  static const TextStyle tiny = TextStyle(fontSize: 11, color: AppColors.textMuted);
  static const TextStyle price = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark);
}

ThemeData buildAppTheme() {
  // Font yahan se badlein, e.g. GoogleFonts.poppins().fontFamily
  final String? fontFamily = GoogleFonts.plusJakartaSans().fontFamily;

  final OutlineInputBorder inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppSizes.radiusButton),
    borderSide: const BorderSide(color: AppColors.border),
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,

    // ---------- Top bar (AppBar) ----------
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    ),

    // ---------- Orange (main) button ----------
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.disabled,
        disabledForegroundColor: const Color(0xFFA8A29E),
        elevation: 0,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        ),
        textStyle: TextStyle(fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    // ---------- White (border wala) button ----------
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: Color(0xFFF3B795)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        ),
        textStyle: TextStyle(fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    // ---------- Text link button ----------
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: TextStyle(fontFamily: fontFamily, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ),

    // ---------- Input box (TextField) ----------
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: const TextStyle(color: Color(0xFFA8A29E), fontSize: 14),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: inputBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: inputBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    ),

    // ---------- Neeche ka menu (Bottom navigation) ----------
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primaryLight,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final bool selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontFamily: fontFamily,
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? AppColors.primary : AppColors.textMuted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final bool selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 23,
          color: selected ? AppColors.primary : AppColors.textMuted,
        );
      }),
    ),

    // ---------- Neeche aane wala chhota message (SnackBar) ----------
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF292524),
      contentTextStyle: TextStyle(fontFamily: fontFamily, fontSize: 13, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),

    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
  );
}
