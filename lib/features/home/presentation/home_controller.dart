import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/models.dart';
import '../../../providers/repository_providers.dart';

// Latest histories shown on Home (newest first).
final recentHistoriesProvider =
    FutureProvider.autoDispose<List<GenerateHistory>>((ref) {
  return ref.watch(motifRepositoryProvider).getHistories(pageSize: 4);
});
