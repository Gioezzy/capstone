import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

// Solid black button with optional leading icon and loading state.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    // Disable interaction while loading.
    final VoidCallback? effectiveOnPressed = isLoading ? null : onPressed;

    final isEnabled = effectiveOnPressed != null;

    final Widget button = Container(
      decoration: BoxDecoration(
        gradient: isEnabled
            ? const LinearGradient(
                colors: [AppColors.maroon, AppColors.black],
              )
            : null,
        color: isEnabled ? null : AppColors.gray,
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppColors.maroon.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: AppColors.white.withOpacity(0.6),
          textStyle: AppTypography.buttonLabel,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : _buildContent(),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _buildContent() {
    if (icon == null) {
      return Text(label);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Text(label),
      ],
    );
  }
}
