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
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
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
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
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
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Kategori: ${motif.categoryId}',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.gray),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    IconButton(
                      onPressed: onLike,
                      color: feedback == 1 ? AppColors.black : AppColors.gray,
                      icon: Icon(
                        feedback == 1 ? Icons.thumb_up : Icons.thumb_up_outlined,
                      ),
                    ),
                    IconButton(
                      onPressed: onDislike,
                      color: feedback == -1 ? AppColors.black : AppColors.gray,
                      icon: Icon(
                        feedback == -1
                            ? Icons.thumb_down
                            : Icons.thumb_down_outlined,
                      ),
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
