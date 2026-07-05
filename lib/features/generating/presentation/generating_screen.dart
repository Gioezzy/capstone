import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/text_button_link.dart';
import '../../../domain/models/generate_request.dart';
import 'generating_controller.dart';

// Screen 5: drives the generate state machine and renders progress/error.
// Pushed from Configure with the GenerateRequest to run.
class GeneratingScreen extends ConsumerStatefulWidget {
  const GeneratingScreen({super.key, required this.request});

  final GenerateRequest request;

  @override
  ConsumerState<GeneratingScreen> createState() => _GeneratingScreenState();
}

class _GeneratingScreenState extends ConsumerState<GeneratingScreen> {
  @override
  void initState() {
    super.initState();
    
    
    // Start once after first frame to avoid mutating providers during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ref.read(generatingControllerProvider.notifier).start(widget.request);
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  void _cancel() {
    ref.read(generatingControllerProvider.notifier).cancel();
    if (context.canPop()) context.pop();
  }

  void _retry() =>
      ref.read(generatingControllerProvider.notifier).retry(widget.request);

  @override
  Widget build(BuildContext context) {
    // Success replaces this screen so back does not return to loading.
    ref.listen<GenerateState>(generatingControllerProvider, (_, next) {
      if (next is GenerateSuccess) {
        context.pushReplacement(Routes.resultPath, extra: next.result);
      }
    });

    final state = ref.watch(generatingControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: switch (state) {
            GenerateError(:final error) =>
              _ErrorView(message: error.message, onRetry: _retry),
            GenerateLoading(:final progress, :final logs) =>
              _LoadingView(progress: progress, logs: logs, onCancel: _cancel),
            _ => const _LoadingView(progress: 0, logs: [], onCancel: null),
          },
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({
    required this.progress,
    required this.logs,
    required this.onCancel,
  });

  final double progress;
  final List<String> logs;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'Sedang Menghasilkan Motif Baru',
          style: AppTypography.headingMedium,
          textAlign: TextAlign.center,
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 2.seconds, color: AppColors.gold.withOpacity(0.8)),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Memproses Noise Vector...',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.gray),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: Lottie.network(
            'https://assets3.lottiefiles.com/packages/lf20_t2xkxb22.json', // Aesthetic abstract loader
            height: 150,
            width: 150,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.auto_awesome,
              size: 64,
              color: AppColors.gold,
            )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 2.seconds),
          ),
        )
        .animate()
        .fade(duration: 500.ms)
        .scaleXY(begin: 0.8, end: 1.0, duration: 500.ms, curve: Curves.easeOutBack),
        const SizedBox(height: AppSpacing.xl),
        Expanded(child: _SystemLogPanel(logs: logs)),
        const SizedBox(height: AppSpacing.lg),
        _ProgressSection(progress: progress),
        const SizedBox(height: AppSpacing.sm),
        TextButtonLink(label: 'Batalkan Proses', onPressed: onCancel),
      ],
    );
  }
}



// "PROSES SYSTEM" terminal-style scrolling log panel.
class _SystemLogPanel extends StatelessWidget {
  const _SystemLogPanel({required this.logs});

  final List<String> logs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.nearBlack,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROSES SYSTEM',
            style: AppTypography.labelSmallCaps.copyWith(color: AppColors.gray),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: logs.length,
              itemBuilder: (context, i) {
                final index = logs.length - 1 - i;
                final isLast = index == logs.length - 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text(
                    '> ${logs[index]}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.4,
                      color: isLast ? AppColors.white : AppColors.gray,
                      fontWeight: isLast ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Generasi Motif', style: AppTypography.bodyMedium),
            Text(
              '${(progress * 100).round()}%',
              style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.borderGray,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.black),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.onSurface),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Generasi Gagal',
            style: AppTypography.headingMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.gray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Coba Lagi',
            icon: Icons.refresh,
            expand: false,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
