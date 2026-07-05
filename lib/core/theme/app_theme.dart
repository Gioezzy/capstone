import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

// Builds the global ThemeData from design tokens.
ThemeData buildAppTheme({bool isDarkMode = false}) {
  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.maroon,
    brightness: isDarkMode ? Brightness.dark : Brightness.light,
  ).copyWith(
    primary: AppColors.maroon,
    onPrimary: AppColors.white,
    secondary: AppColors.gold,
    onSecondary: AppColors.white,
    surface: isDarkMode ? AppColors.black : AppColors.white,
    onSurface: isDarkMode ? AppColors.white : AppColors.black,
    background: isDarkMode ? AppColors.nearBlack : AppColors.surfaceGray,
    onBackground: isDarkMode ? AppColors.white : AppColors.black,
    error: AppColors.danger,
    onError: AppColors.white,
    outline: AppColors.borderGray,
    surfaceTint: Colors.transparent,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.background,
    canvasColor: colorScheme.background,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    textTheme: _buildTextTheme(isDarkMode: isDarkMode),
    cardTheme: CardTheme(
      color: colorScheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: const BorderSide(color: AppColors.borderGray),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.maroon,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.gray,
        disabledForegroundColor: AppColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        ),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.maroon,
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        side: const BorderSide(color: AppColors.borderGray),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        ),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: isDarkMode ? AppColors.white : AppColors.graphite,
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      hintStyle: GoogleFonts.inter(color: AppColors.gray, fontSize: 14),
      border: _inputBorder(AppColors.borderGray),
      enabledBorder: _inputBorder(AppColors.borderGray),
      focusedBorder: _inputBorder(AppColors.black),
      errorBorder: _inputBorder(AppColors.danger),
      focusedErrorBorder: _inputBorder(AppColors.danger),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.background,
      foregroundColor: isDarkMode ? AppColors.white : AppColors.maroon,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: isDarkMode ? AppColors.white : AppColors.maroon),
      titleTextStyle: GoogleFonts.lora(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: isDarkMode ? AppColors.white : AppColors.maroon,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.borderGray,
      space: AppSpacing.borderWidth,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.surface,
      selectedColor: isDarkMode ? AppColors.white : AppColors.black,
      side: const BorderSide(color: AppColors.borderGray),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: isDarkMode ? AppColors.white : AppColors.black,
      ),
      secondaryLabelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: isDarkMode ? AppColors.black : AppColors.white,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

// Serif headings (Lora) over a sans body base (Inter), aligned to tokens.
TextTheme _buildTextTheme({required bool isDarkMode}) {
  final textColor = isDarkMode ? AppColors.white : AppColors.black;
  final bodyColor = isDarkMode ? AppColors.gray : AppColors.graphite;

  final TextTheme inter = GoogleFonts.interTextTheme().apply(
    bodyColor: textColor,
    displayColor: textColor,
  );
  final TextTheme lora = GoogleFonts.loraTextTheme().apply(
    bodyColor: textColor,
    displayColor: textColor,
  );

  return inter.copyWith(
    displayLarge: lora.displayLarge?.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      color: textColor,
      height: 1.2,
    ),
    displayMedium: lora.displayMedium
        ?.copyWith(color: textColor, fontWeight: FontWeight.w600),
    displaySmall: lora.displaySmall
        ?.copyWith(color: textColor, fontWeight: FontWeight.w600),
    headlineLarge: lora.headlineLarge
        ?.copyWith(color: textColor, fontWeight: FontWeight.w600),
    headlineMedium: lora.headlineMedium?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    headlineSmall: lora.headlineSmall
        ?.copyWith(color: textColor, fontWeight: FontWeight.w600),
    bodyMedium: inter.bodyMedium?.copyWith(
      fontSize: 14,
      color: bodyColor,
      height: 1.5,
    ),
    labelSmall: inter.labelSmall?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.gray,
      letterSpacing: 1.5,
    ),
  );
}

OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      borderSide: BorderSide(color: color),
    );
