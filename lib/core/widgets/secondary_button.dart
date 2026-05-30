import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

// Outline button with transparent background; danger variant uses red accent.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = true,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final Color foreground = danger ? AppColors.danger : AppColors.black;
    final Color border = danger ? AppColors.danger : AppColors.borderGray;

    final ButtonStyle style = OutlinedButton.styleFrom(
      foregroundColor: foreground,
      backgroundColor: Colors.transparent,
      disabledForegroundColor: AppColors.gray,
      textStyle: AppTypography.buttonLabel,
      side: BorderSide(color: border),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      ),
    );

    final Widget button = OutlinedButton(
      onPressed: onPressed,
      style: style,
      child: _buildContent(),
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
