import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../data/mock/mock_data.dart';
import '../../../domain/models/models.dart';
import '../../../providers/repository_providers.dart';

// Detail motif by id. Route param is a history id, but getMotif looks up by
// motif id; on NotFound, fall back to resolving via historyId (mock stage).
final motifDetailProvider =
    FutureProvider.autoDispose.family<GeneratedMotif, String>((ref, id) async {
  final repo = ref.watch(motifRepositoryProvider);
  try {
    return await repo.getMotif(id);
  } on NotFoundException {
    final byHistory = MockData.motifs.where((m) => m.historyId == id);
    if (byHistory.isNotEmpty) return byHistory.first;
    rethrow;
  }
});
