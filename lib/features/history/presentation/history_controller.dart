import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/models.dart';
import '../../../domain/repositories/motif_repository.dart';
import '../../../providers/repository_providers.dart';

// Current sort order for the history list.
final historySortProvider =
    StateProvider.autoDispose<HistorySort>((ref) => HistorySort.newest);

// Optional category filter (null = all categories).
final historyFilterProvider = StateProvider.autoDispose<String?>((ref) => null);

// History list driven by the current sort and filter (UC-005).
final historyListProvider =
    FutureProvider.autoDispose<List<GenerateHistory>>((ref) {
  final sort = ref.watch(historySortProvider);
  final filter = ref.watch(historyFilterProvider);
  return ref.watch(motifRepositoryProvider).getHistories(
        sort: sort,
        categoryId: filter,
        pageSize: 50,
      );
});
