import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../error/failure.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'empty_state.dart';

// Renders exactly one of loading/error/empty/data from an AsyncValue<T>.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.isEmpty,
    this.emptyBuilder,
    this.errorBuilder,
    this.loading,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final bool Function(T data)? isEmpty;
  final Widget Function()? emptyBuilder;
  final Widget Function(Object error)? errorBuilder;
  final Widget? loading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    // Exclusive branches: loading XOR error XOR empty XOR data.
    if (value.isLoading) {
      return loading ?? _defaultLoading();
    }
    if (value.hasError) {
      return errorBuilder?.call(value.error!) ?? _defaultError(value.error!);
    }
    final T d = value.requireValue;
    if (isEmpty?.call(d) ?? false) {
      return emptyBuilder?.call() ?? const EmptyState(message: 'Data tidak tersedia');
    }
    return data(d);
  }

  Widget _defaultLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.black),
      ),
    );
  }

  Widget _defaultError(Object error) {
    final String message = Failure.from(error).message;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.black,
                  side: const BorderSide(color: AppColors.black),
                  textStyle: AppTypography.buttonLabel,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.buttonRadius),
                  ),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
