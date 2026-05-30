import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

// Borderless text link for low-emphasis actions.
class TextButtonLink extends StatelessWidget {
  const TextButtonLink({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.graphite,
        disabledForegroundColor: AppColors.gray,
        textStyle: AppTypography.buttonLabel,
      ),
      child: Text(
        label,
        style: const TextStyle(decoration: TextDecoration.underline),
      ),
    );
  }
}
