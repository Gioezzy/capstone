import 'package:flutter/widgets.dart';

// Typography design tokens.
class AppTypography {
  AppTypography._();

  static const String serifFamily = 'Lora';
  static const String sansFamily = 'Inter';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: serifFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: serifFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: sansFamily,
    fontSize: 14,
    height: 1.5,
  );

  // Rendered uppercase with letter-spacing at call sites.
  static const TextStyle labelSmallCaps = TextStyle(
    fontFamily: sansFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontFamily: sansFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
}
