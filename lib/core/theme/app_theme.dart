import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

// Builds the global monochrome ThemeData from design tokens.
ThemeData buildAppTheme() {
  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.black,
  ).copyWith(
    primary: AppColors.black,
    onPrimary: AppColors.white,
    secondary: AppColors.graphite,
    onSecondary: AppColors.white,
    surface: AppColors.white,
    onSurface: AppColors.black,
    background: AppColors.white,
    onBackground: AppColors.black,
    error: AppColors.danger,
    onError: AppColors.white,
    outline: AppColors.borderGray,
    surfaceTint: Colors.transparent,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.white,
    canvasColor: AppColors.white,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    textTheme: _buildTextTheme(),
    cardTheme: CardTheme(
      color: AppColors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: const BorderSide(color: AppColors.borderGray),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.black,
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
        foregroundColor: AppColors.black,
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
        foregroundColor: AppColors.graphite,
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
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
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.black,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.black),
      titleTextStyle: GoogleFonts.lora(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.borderGray,
      space: AppSpacing.borderWidth,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.white,
      selectedColor: AppColors.black,
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
        color: AppColors.black,
      ),
      secondaryLabelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
    ),
  );
}

// Serif headings (Lora) over a sans body base (Inter), aligned to tokens.
TextTheme _buildTextTheme() {
  final TextTheme inter = GoogleFonts.interTextTheme();
  final TextTheme lora = GoogleFonts.loraTextTheme();

  return inter.copyWith(
    displayLarge: lora.displayLarge?.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
      height: 1.2,
    ),
    displayMedium: lora.displayMedium
        ?.copyWith(color: AppColors.black, fontWeight: FontWeight.w600),
    displaySmall: lora.displaySmall
        ?.copyWith(color: AppColors.black, fontWeight: FontWeight.w600),
    headlineLarge: lora.headlineLarge
        ?.copyWith(color: AppColors.black, fontWeight: FontWeight.w600),
    headlineMedium: lora.headlineMedium?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
    headlineSmall: lora.headlineSmall
        ?.copyWith(color: AppColors.black, fontWeight: FontWeight.w600),
    bodyMedium: inter.bodyMedium?.copyWith(
      fontSize: 14,
      color: AppColors.graphite,
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
