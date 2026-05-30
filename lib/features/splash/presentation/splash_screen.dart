import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import 'splash_controller.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<SplashStatus>(splashControllerProvider, (previous, next) {
      if (next == SplashStatus.ready) context.go(Routes.homePath);
    });

    return const Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              _LogoMark(),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Songket Gen-AI',
                style: AppTypography.displayLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Generasi Motif Songket Berbasis cDCGAN',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              Spacer(),
              _InitIndicator(),
              SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: const Icon(Icons.auto_awesome, color: AppColors.white, size: 44),
    );
  }
}

class _InitIndicator extends StatelessWidget {
  const _InitIndicator();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 140,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.xs),
            child: const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: AppColors.borderGray,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.black),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'INITIALIZING MODEL',
          style: AppTypography.labelSmallCaps,
        ),
      ],
    );
  }
}
