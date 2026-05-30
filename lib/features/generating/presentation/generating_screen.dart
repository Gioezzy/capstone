import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      ref.read(generatingControllerProvider.notifier).start(widget.request);
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
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Memproses Noise Vector...',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.gray),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        const _GanDiagram(),
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

// Generator <-> Discriminator with "Data →" and "← Feedback" arrows.
class _GanDiagram extends StatelessWidget {
  const _GanDiagram();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _DiagramBox(label: 'Generator', icon: Icons.auto_awesome)),
        SizedBox(width: AppSpacing.sm),
        _DiagramArrows(),
        SizedBox(width: AppSpacing.sm),
        Expanded(child: _DiagramBox(label: 'Discriminator', icon: Icons.search)),
      ],
    );
  }
}

class _DiagramBox extends StatelessWidget {
  const _DiagramBox({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.graphite),
          const SizedBox(height: AppSpacing.sm),
          Text(label, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}

class _DiagramArrows extends StatelessWidget {
  const _DiagramArrows();

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.labelSmallCaps.copyWith(color: AppColors.graphite);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Data →', style: style),
        const SizedBox(height: AppSpacing.xs),
        Text('← Feedback', style: style),
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
              style: AppTypography.bodyMedium.copyWith(color: AppColors.black),
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
          const Icon(Icons.error_outline, size: 48, color: AppColors.graphite),
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
