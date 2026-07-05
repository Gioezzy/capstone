import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/motif_card.dart';
import '../../../domain/models/models.dart';
import 'categories_controller.dart';

// Category selection screen (UC-001): search + 2-column grid.
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motif Categories'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.homePath);
            }
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: TextField(
              onChanged: (v) =>
                  ref.read(categorySearchProvider.notifier).state = v,
              decoration: const InputDecoration(
                hintText: 'Search motifs...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: AsyncValueView<List<MotifCategory>>(
              value: ref.watch(filteredCategoriesProvider),
              isEmpty: (l) => l.isEmpty,
              emptyBuilder: () =>
                  const EmptyState(message: 'Motif tidak ditemukan'),
              onRetry: () => ref.invalidate(categoriesProvider),
              data: (list) => _CategoryGrid(categories: list),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories});

  final List<MotifCategory> categories;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.8,
      ),
      itemCount: categories.length,
      itemBuilder: (context, i) {
        final category = categories[i];
        return MotifCard.grid(
          title: category.name,
          imageUrl: category.previewImage,
          onTap: () => context.push(
            '${Routes.configurePath}?categoryId=${category.id}',
          ),
        );
      },
    );
  }
}
