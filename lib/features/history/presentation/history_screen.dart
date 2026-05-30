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
import '../../../domain/models/models.dart';
import '../../../domain/repositories/motif_repository.dart';
import '../../categories/presentation/categories_controller.dart';
import 'history_controller.dart';

// History tab (Riwayat): list of generated motifs with sort & filter (UC-005).
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SongketAI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => context.push(Routes.aboutPath),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _HistoryHeader(),
          Expanded(
            child: AsyncValueView<List<GenerateHistory>>(
              value: ref.watch(historyListProvider),
              isEmpty: (l) => l.isEmpty,
              onRetry: () => ref.invalidate(historyListProvider),
              emptyBuilder: () => EmptyState(
                message: 'Belum ada motif',
                icon: Icons.grid_view_outlined,
                actionLabel: 'Mulai Generate',
                onAction: () => context.go(Routes.categoriesPath),
              ),
              errorBuilder: (error) => _HistoryError(
                onRetry: () => ref.invalidate(historyListProvider),
              ),
              data: (list) => _HistoryList(histories: list),
            ),
          ),
        ],
      ),
    );
  }
}

// "Generated Motifs" title with Sort and Filter controls.
class _HistoryHeader extends ConsumerWidget {
  const _HistoryHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(historySortProvider);
    final isNewest = sort == HistorySort.newest;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Row(
        children: [
          const Expanded(
            child: Text('Generated Motifs', style: AppTypography.headingMedium),
          ),
          TextButton.icon(
            onPressed: () =>
                ref.read(historySortProvider.notifier).state =
                    isNewest ? HistorySort.oldest : HistorySort.newest,
            icon: Icon(
              isNewest ? Icons.arrow_downward : Icons.arrow_upward,
              size: 18,
            ),
            label: const Text('Sort'),
            style: TextButton.styleFrom(foregroundColor: AppColors.black),
          ),
          const _FilterButton(),
        ],
      ),
    );
  }
}

// Category filter as a popup menu ("Semua" + each category).
class _FilterButton extends ConsumerWidget {
  const _FilterButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const [];
    final selected = ref.watch(historyFilterProvider);
    return PopupMenuButton<String?>(
      tooltip: 'Filter',
      onSelected: (value) =>
          ref.read(historyFilterProvider.notifier).state = value,
      itemBuilder: (context) => [
        CheckedPopupMenuItem<String?>(
          checked: selected == null,
          child: const Text('Semua'),
        ),
        for (final c in categories)
          CheckedPopupMenuItem<String?>(
            value: c.id,
            checked: selected == c.id,
            child: Text(c.name),
          ),
      ],
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list, size: 18, color: AppColors.black),
            SizedBox(width: AppSpacing.xs),
            Text(
              'Filter',
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Scrollable list of history cards.
class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.histories});

  final List<GenerateHistory> histories;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        0,
        AppSpacing.pagePadding,
        AppSpacing.pagePadding,
      ),
      itemCount: histories.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, i) {
        final h = histories[i];
        return MotifCard.list(
          imageUrl: h.generatedImage,
          code: h.id,
          title: h.categoryName ?? '-',
          tagLabel: h.tag?.name,
          dateText: _formatDate(h.createdAt),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
          onTap: () => context.push(Routes.historyDetailPathFor(h.id)),
        );
      },
    );
  }
}

// "Today, 14:30" for today, otherwise "Oct 24, 16:45".
String _formatDate(DateTime date) {
  final now = DateTime.now();
  final isToday =
      date.year == now.year && date.month == now.month && date.day == now.day;
  if (isToday) return 'Today, ${DateFormat('HH:mm').format(date)}';
  return DateFormat('MMM d, HH:mm').format(date);
}

// Error view with a "Muat Ulang" retry action.
class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Gagal memuat riwayat',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.black,
                side: const BorderSide(color: AppColors.black),
                textStyle: AppTypography.buttonLabel,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                ),
              ),
              child: const Text('Muat Ulang'),
            ),
          ],
        ),
      ),
    );
  }
}
