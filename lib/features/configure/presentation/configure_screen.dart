import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/attribute_chip.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../domain/models/models.dart';
import '../../categories/presentation/categories_controller.dart';
import 'configure_controller.dart';

// Generate configuration screen (UC-002). Resolves category from a query
// param categoryId via categoriesProvider.
class ConfigureScreen extends ConsumerWidget {
  const ConfigureScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Konfigurasi Generasi')),
        body: Center(child: Text('Gagal memuat kategori: $err')),
      ),
      data: (list) {
        MotifCategory? category;
        for (final c in list) {
          if (c.id == categoryId) {
            category = c;
            break;
          }
        }

        if (category == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Konfigurasi Generasi')),
            body: const Center(child: Text('Kategori tidak tersedia')),
          );
        }

        final provider = configureControllerProvider(category);
        final state = ref.watch(provider);
        final controller = ref.read(provider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfigurasi Generasi'),
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
          _SelectedCategoryCard(name: category.name),
          const SizedBox(height: AppSpacing.lg),
          const _SectionHeader(title: 'Resolusi Output'),
          const SizedBox(height: AppSpacing.sm),
          _ResolutionCard(
            title: '64×64 px',
            subtitle: 'Cepat, draft',
            selected: state.resolution == Resolution.px64,
            onTap: () => controller.setResolution(Resolution.px64),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ResolutionCard(
            title: '128×128 px',
            subtitle: 'Detail, lambat',
            selected: state.resolution == Resolution.px128,
            onTap: () => controller.setResolution(Resolution.px128),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SectionHeader(
            title: 'Kondisi Atribut',
            trailing: 'Pilih kombinasi',
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final c in AttributeCondition.values)
                AttributeChip(
                  label: _conditionLabel(c),
                  selected: state.conditions.contains(c),
                  onTap: () => controller.toggle(c),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SectionHeader(title: 'Noise Seed', trailing: 'Opsional'),
          const SizedBox(height: AppSpacing.sm),
          _SeedField(category: category),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Gunakan seed yang sama untuk mereproduksi motif sebelumnya.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.gray),
          ),
          if (!state.isSeedValid) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Seed harus bilangan bulat ≥ 0',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.danger),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: PrimaryButton(
            label: 'Generate Motif',
            icon: Icons.auto_awesome,
            onPressed: state.isSeedValid
                ? () => context.push(
                      Routes.generatingPath,
                      extra: state.toRequest(),
                    )
                : null,
          ),
        ),
      ),
    );
      },
    );
  }

  String _conditionLabel(AttributeCondition c) =>
      c.name[0].toUpperCase() + c.name.substring(1);
}

class _SelectedCategoryCard extends StatelessWidget {
  const _SelectedCategoryCard({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceGray,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('KATEGORI TERPILIH', style: AppTypography.labelSmallCaps),
          const SizedBox(height: AppSpacing.xs),
          Text(name, style: AppTypography.headingMedium),
        ],
      ),
    );
  }
}

class _ResolutionCard extends StatelessWidget {
  const _ResolutionCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceGray : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: selected ? AppColors.black : AppColors.borderGray,
            width: selected ? 2 : AppSpacing.borderWidth,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.gray),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.black : AppColors.gray,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title.toUpperCase(), style: AppTypography.labelSmallCaps),
        if (trailing != null)
          Text(
            trailing!,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.gray),
          ),
      ],
    );
  }
}

// Owns a TextEditingController so "Acak" (clear) reflects in the field.
class _SeedField extends ConsumerStatefulWidget {
  const _SeedField({required this.category});

  final MotifCategory category;

  @override
  ConsumerState<_SeedField> createState() => _SeedFieldState();
}

class _SeedFieldState extends ConsumerState<_SeedField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final seed =
        ref.read(configureControllerProvider(widget.category)).seedInput;
    _controller = TextEditingController(text: seed);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = configureControllerProvider(widget.category);
    final controller = ref.read(provider.notifier);

    // Sync field when seed changes externally (e.g. randomize/clear).
    ref.listen(provider.select((s) => s.seedInput), (_, next) {
      if (_controller.text != next) {
        _controller.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      }
    });

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Kosongkan untuk acak'),
            onChanged: controller.setSeedInput,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        TextButton(
          onPressed: controller.randomizeSeed,
          child: const Text('Acak'),
        ),
      ],
    );
  }
}
