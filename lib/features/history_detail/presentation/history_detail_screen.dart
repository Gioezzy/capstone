import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/failure.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../domain/models/models.dart';
import '../../../providers/repository_providers.dart';
import '../../history/presentation/history_controller.dart';
import 'history_detail_controller.dart';

// Detail Riwayat (UC-003): big image, metadata, download and delete actions.
class HistoryDetailScreen extends ConsumerWidget {
  const HistoryDetailScreen({super.key, required this.motifId});

  final String motifId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(motifDetailProvider(motifId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Motif'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Menu',
            onSelected: (v) {
              if (v == 'delete') {
                final motif = value.valueOrNull;
                if (motif != null) _confirmDelete(context, ref, motif);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(value: 'delete', child: Text('Hapus')),
            ],
          ),
        ],
      ),
      body: AsyncValueView<GeneratedMotif>(
        value: value,
        onRetry: () => ref.invalidate(motifDetailProvider(motifId)),
        emptyBuilder: () => const EmptyState(
          message: 'Data tidak tersedia',
          icon: Icons.image_not_supported_outlined,
        ),
        errorBuilder: (error) => error is NotFoundException
            ? const EmptyState(message: 'Data tidak tersedia')
            : EmptyState(
                message: Failure.from(error).message,
                icon: Icons.error_outline,
              ),
        data: (motif) => _DetailContent(motif: motif),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.motif});

  final GeneratedMotif motif;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MotifImage(imageUrl: motif.imageUrl),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  motif.title ?? 'Motif',
                  style: AppTypography.headingMedium,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const _Tag(label: 'Songket'),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Dibuat pada: ${_formatDate(motif.createdAt)}',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.gray),
          ),
          const SizedBox(height: AppSpacing.lg),
          _MetadataGrid(motif: motif),
          const SizedBox(height: AppSpacing.lg),
          _DetailActions(motif: motif),
        ],
      ),
    );
  }
}

class _MotifImage extends StatelessWidget {
  const _MotifImage({required this.imageUrl});

  final String imageUrl;

  bool get _isNetwork => imageUrl.startsWith('http');

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: AspectRatio(
        aspectRatio: 1,
        child: _isNetwork
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => const _ImagePlaceholder(),
                errorWidget: (_, __, ___) =>
                    const _ImagePlaceholder(broken: true),
              )
            : Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const _ImagePlaceholder(broken: true),
              ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({this.broken = false});

  final bool broken;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.nearBlack,
      alignment: Alignment.center,
      child: Icon(
        broken ? Icons.broken_image_outlined : Icons.image_outlined,
        color: AppColors.gray,
        size: 48,
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmallCaps.copyWith(color: AppColors.white),
      ),
    );
  }
}

class _MetadataGrid extends StatelessWidget {
  const _MetadataGrid({required this.motif});

  final GeneratedMotif motif;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MetaItem(
                label: 'Model Dasar',
                value: motif.baseModel ?? '-',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _MetaItem(
                label: 'Kompleksitas',
                value: _formatComplexity(motif.complexity),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MetaItem(
                label: 'Warna Utama',
                value: motif.primaryColor ?? 'Monochrome',
                showDot: true,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _MetaItem(
                label: 'Iterasi',
                value: '${motif.iterations ?? '-'} Langkah',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.label,
    required this.value,
    this.showDot = false,
  });

  final String label;
  final String value;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceGray,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTypography.labelSmallCaps),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              if (showDot) ...[
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailActions extends ConsumerStatefulWidget {
  const _DetailActions({required this.motif});

  final GeneratedMotif motif;

  @override
  ConsumerState<_DetailActions> createState() => _DetailActionsState();
}

class _DetailActionsState extends ConsumerState<_DetailActions> {
  bool _downloading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          label: 'Unduh Lagi (PNG)',
          icon: Icons.download,
          isLoading: _downloading,
          onPressed: _download,
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          label: 'Hapus dari Riwayat',
          icon: Icons.delete_outline,
          danger: true,
          onPressed: () => _confirmDelete(context, ref, widget.motif),
        ),
      ],
    );
  }

  Future<void> _download() async {
    setState(() => _downloading = true);
    try {
      await ref.read(motifRepositoryProvider).getDownloadInfo(widget.motif.id);
      if (!mounted) return;
      _showSnack('Unduhan berhasil');
    } catch (e) {
      if (!mounted) return;
      _showSnack(Failure.from(e).message);
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

// Confirm then delete the history item and refresh the list view.
Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  GeneratedMotif motif,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hapus dari Riwayat?'),
      content: const Text('Motif ini akan dihapus dari riwayat.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.danger),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  if (!context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  try {
    await ref.read(motifRepositoryProvider).deleteHistory(motif.historyId);
    ref.invalidate(historyListProvider);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Dihapus dari riwayat')));
    router.go(Routes.historyPath);
  } catch (e) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(Failure.from(e).message)));
  }
}

// "24 Oktober 2023, 14:30" (id locale when available, else default).
String _formatDate(DateTime date) {
  try {
    return DateFormat('d MMMM yyyy, HH:mm', 'id').format(date);
  } catch (_) {
    return DateFormat('d MMMM yyyy, HH:mm').format(date);
  }
}

// "Tinggi (0.85)" style label derived from a 0..1 complexity score.
String _formatComplexity(double? complexity) {
  if (complexity == null) return '-';
  final label = complexity >= 0.8
      ? 'Tinggi'
      : complexity >= 0.5
          ? 'Sedang'
          : 'Rendah';
  return '$label (${complexity.toStringAsFixed(2)})';
}
