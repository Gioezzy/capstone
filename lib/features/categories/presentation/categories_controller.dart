import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/models.dart';
import '../../../providers/repository_providers.dart';

// Categories loaded from the repository (UC-001).
final categoriesProvider =
    FutureProvider.autoDispose<List<MotifCategory>>((ref) {
  return ref.watch(motifRepositoryProvider).getCategories();
});

// Current search query for filtering categories by name.
final categorySearchProvider = StateProvider.autoDispose<String>((ref) => '');

// Categories filtered by name containing the search query.
final filteredCategoriesProvider =
    Provider.autoDispose<AsyncValue<List<MotifCategory>>>((ref) {
  final q = ref.watch(categorySearchProvider).toLowerCase();
  final async = ref.watch(categoriesProvider);
  return async.whenData(
    (list) => q.isEmpty
        ? list
        : list.where((c) => c.name.toLowerCase().contains(q)).toList(),
  );
});
