import 'package:flutter/widgets.dart';

import 'app_colors.dart';

// Typography design tokens.
class AppTypography {
  AppTypography._();

  static const String serifFamily = 'Lora';
  static const String sansFamily = 'Inter';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: serifFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: serifFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: sansFamily,
    fontSize: 14,
    color: AppColors.graphite,
    height: 1.5,
  );

  // Rendered uppercase with letter-spacing at call sites.
  static const TextStyle labelSmallCaps = TextStyle(
    fontFamily: sansFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.gray,
    letterSpacing: 1.5,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontFamily: sansFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
}
