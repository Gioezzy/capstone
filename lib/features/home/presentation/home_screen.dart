import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/motif_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../domain/models/models.dart';
import 'home_controller.dart';

// Home tab (Beranda): welcome banner + recent histories grid.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SongketAI'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => context.push(Routes.aboutPath),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          const _WelcomeBanner(),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(
            title: 'Riwayat Terakhir',
            actionLabel: 'Lihat Semua',
            onActionTap: () => context.go(Routes.historyPath),
          ),
          const SizedBox(height: AppSpacing.md),
          AsyncValueView<List<GenerateHistory>>(
            value: ref.watch(recentHistoriesProvider),
            isEmpty: (l) => l.isEmpty,
            onRetry: () => ref.invalidate(recentHistoriesProvider),
            emptyBuilder: () => EmptyState(
              message: 'Belum ada motif',
              icon: Icons.grid_view_outlined,
              actionLabel: 'Mulai Generate',
              onAction: () => context.push(Routes.categoriesPath),
            ),
            data: (list) => _HistoryGrid(histories: list),
          ),
        ],
      ),
    );
  }
}

// Welcome card with description and a primary CTA.
class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceGray,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Selamat Datang', style: AppTypography.displayLarge),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Sistem pembuat motif songket generatif siap digunakan. '
            'Pilih kategori dan hasilkan motif baru.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Mulai Generate',
            icon: Icons.auto_awesome,
            onPressed: () => context.push(Routes.categoriesPath),
          ),
        ],
      ),
    );
  }
}

// Non-scrolling 2-column grid of recent history cards.
class _HistoryGrid extends StatelessWidget {
  const _HistoryGrid({required this.histories});

  final List<GenerateHistory> histories;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy');
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.78,
      ),
      itemCount: histories.length,
      itemBuilder: (context, i) {
        final h = histories[i];
        return MotifCard.grid(
          title: h.categoryName ?? '-',
          imageUrl: h.generatedImage,
          code: h.id,
          dateText: dateFormat.format(h.createdAt),
          onTap: () => context.push(Routes.historyDetailPathFor(h.id)),
        );
      },
    );
  }
}
