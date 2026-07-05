import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/widgets/text_button_link.dart';
import '../../../domain/models/generate_result.dart';
import '../../../domain/models/generated_motif.dart';
import 'result_controller.dart';

// Result screen (UC-003/004/006). Receives GenerateResult via router extra.
class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key, required this.result});

  final GenerateResult result;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  int _feedback = 0; // 0 none, 1 like, -1 dislike

  GeneratedMotif get _motif => widget.result.motif;

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    final controller = ref.read(resultControllerProvider.notifier);
    final ok = await controller.saveToHistory(_motif.id);
    if (!mounted) return;
    final message = ref.read(resultControllerProvider).message ??
        (ok ? 'Tersimpan ke riwayat' : 'Gagal menyimpan');
    _showSnack(message);
    if (ok) context.go(Routes.historyPath);
  }

  Future<void> _download() async {
    final controller = ref.read(resultControllerProvider.notifier);
    final ok = await controller.download(_motif.id);
    if (!mounted) return;
    final message = ref.read(resultControllerProvider).message ??
        (ok ? 'Unduhan dimulai' : 'Unduhan gagal');
    _showSnack(message);
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(resultControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('SongketAI')),
      body: _motif.imageUrl.isEmpty
          ? const EmptyState(
              icon: Icons.image_not_supported_outlined,
              message: 'Data tidak tersedia',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                AppSpacing.pagePadding,
                AppSpacing.pagePadding,
                120.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hasil Generasi', style: AppTypography.displayLarge),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Motif songket baru Anda telah berhasil dibuat. '
                    'Tinjau hasilnya lalu simpan atau unduh.',
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _MotifCardView(
                    motif: _motif,
                    feedback: _feedback,
                    onLike: () => setState(() => _feedback = _feedback == 1 ? 0 : 1),
                    onDislike: () =>
                        setState(() => _feedback = _feedback == -1 ? 0 : -1),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: 'Simpan ke Riwayat',
                    isLoading: actionState.isSaving,
                    onPressed: _save,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SecondaryButton(
                    label: 'Unduh Motif (PNG)',
                    icon: Icons.download,
                    onPressed: actionState.isDownloading ? null : _download,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: TextButtonLink(
                      label: 'Generate Lagi',
                      onPressed: () => context.go(Routes.categoriesPath),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Motif image card with title, category tag, and like/dislike actions.
class _MotifCardView extends StatelessWidget {
  const _MotifCardView({
    required this.motif,
    required this.feedback,
    required this.onLike,
    required this.onDislike,
  });

  final GeneratedMotif motif;
  final int feedback;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.borderGray.withOpacity(0.8)),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: _MotifImage(imageUrl: motif.imageUrl),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(motif.title ?? 'Motif Baru', style: AppTypography.headingMedium),
                const SizedBox(height: AppSpacing.sm),
                
                // Indah Category Badge/Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.maroon.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.maroon.withOpacity(0.12)),
                  ),
                  child: Text(
                    'Kategori: ${motif.categoryId}',
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 12,
                      color: AppColors.maroon,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Modern Like/Dislike Action Chips
                Row(
                  children: [
                    _FeedbackButton(
                      icon: Icons.thumb_up_outlined,
                      activeIcon: Icons.thumb_up_rounded,
                      isActive: feedback == 1,
                      activeColor: AppColors.gold,
                      onTap: onLike,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _FeedbackButton(
                      icon: Icons.thumb_down_outlined,
                      activeIcon: Icons.thumb_down_rounded,
                      isActive: feedback == -1,
                      activeColor: AppColors.danger,
                      onTap: onDislike,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Loads network or asset image; falls back to a placeholder on error.
class _MotifImage extends StatelessWidget {
  const _MotifImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final isNetwork = imageUrl.startsWith('http');
    final image = isNetwork
        ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: _onError)
        : Image.asset(imageUrl, fit: BoxFit.cover, errorBuilder: _onError);
    return image;
  }

  Widget _onError(BuildContext context, Object error, StackTrace? stack) {
    return Container(
      color: AppColors.surfaceGray,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, size: 48, color: AppColors.gray),
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  const _FeedbackButton({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive 
              ? activeColor.withOpacity(0.12) 
              : AppColors.surfaceGray,
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive 
                ? activeColor.withOpacity(0.4) 
                : AppColors.borderGray.withOpacity(0.6),
            width: 1.5,
          ),
        ),
        child: Icon(
          isActive ? activeIcon : icon,
          size: 20,
          color: isActive ? activeColor : AppColors.gray,
        ),
      ),
    );
  }
}
