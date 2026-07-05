import 'package:flutter/material.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

// About screen: research metadata and cDCGAN model architecture.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _researchTitle =
      'Pengembangan Model cDCGAN untuk Generasi Motif Songket Baru';
  static const String _coreTechnology =
      'cDCGAN (Conditional Deep Convolutional Generative Adversarial Networks)';
  static const String _architectureBody =
      'The model pairs two networks trained against each other. The Generator '
      'synthesizes a motif from a random noise vector conditioned on a chosen '
      'category label, while the Discriminator judges both authenticity and '
      'whether the result matches that label. This conditioning steers '
      'generation toward a specific motif type rather than arbitrary output. '
      'Through adversarial training the Generator learns to preserve the '
      'structural character of traditional songket while producing novel '
      'patterns.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: const [
          _Header(),
          SizedBox(height: AppSpacing.xl),
          _InfoCard(label: 'RESEARCH TITLE', value: _researchTitle),
          SizedBox(height: AppSpacing.md),
          _InfoCard(
            label: 'LEAD RESEARCHER',
            value: AppConstants.researcherName,
          ),
          SizedBox(height: AppSpacing.md),
          _InfoCard(label: 'CORE TECHNOLOGY', value: _coreTechnology),
          SizedBox(height: AppSpacing.xl),
          Text('Model Architecture', style: AppTypography.headingMedium),
          SizedBox(height: AppSpacing.sm),
          Text(_architectureBody, style: AppTypography.bodyMedium),
          SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: const Icon(
            Icons.auto_awesome_outlined,
            color: AppColors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'SongketAI Research Project',
          style: AppTypography.headingMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'v${AppConstants.appVersion}-beta',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.gray),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelSmallCaps),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}
