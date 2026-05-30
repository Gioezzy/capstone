import 'dart:math';

import '../../core/error/app_exception.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/motif_repository.dart';
import '../mock/mock_data.dart';

// In-memory implementation: simulates latency and optional errors. No HTTP.
class MockMotifRepository implements MotifRepository {
  // Non-null simulatedError forces failure-path methods to throw (for state
  // testing). Default null keeps the success path.
  final AppException? simulatedError;
  final Duration latency;
  final Random _random;

  MockMotifRepository({
    this.simulatedError,
    this.latency = const Duration(milliseconds: 800),
    int? randomSeed,
  }) : _random = Random(randomSeed);

  @override
  Future<List<MotifCategory>> getCategories() async {
    await Future.delayed(latency);
    if (simulatedError != null) throw simulatedError!;
    return List.of(MockData.categories);
  }

  @override
  Future<MotifCategory> getCategory(String id) async {
    await Future.delayed(latency);
    final category = MockData.categoryById(id);
    if (category == null) throw const NotFoundException();
    return category;
  }

  @override
  Future<GenerateResult> generateMotif(GenerateRequest request) async {
    await Future.delayed(latency * 2); // generation takes longer
    if (simulatedError != null) throw simulatedError!;
    // Deterministic for a fixed non-null seed (Property 6); random otherwise.
    final seed = request.noiseSeed ?? _random.nextInt(0x7fffffff);
    return GenerateResult(
      motif: MockData.motifFor(request.categoryId, seed),
      usedSeed: seed,
      historyId: MockData.nextHistoryId(),
    );
  }

  @override
  Future<List<GenerateHistory>> getHistories({
    int page = 1,
    int pageSize = 20,
    String? categoryId,
    HistorySort sort = HistorySort.newest,
  }) async {
    await Future.delayed(latency);
    if (simulatedError != null) throw simulatedError!;

    final items = MockData.histories
        .where((h) => categoryId == null || h.categoryId == categoryId)
        .toList()
      ..sort((a, b) => sort == HistorySort.newest
          ? b.createdAt.compareTo(a.createdAt)
          : a.createdAt.compareTo(b.createdAt));

    final start = (page - 1) * pageSize;
    if (start >= items.length) return [];
    final end = min(start + pageSize, items.length);
    return items.sublist(start, end);
  }

  @override
  Future<GeneratedMotif> getMotif(String id) async {
    await Future.delayed(latency);
    final motif = MockData.motifById(id);
    if (motif == null) throw const NotFoundException();
    return motif;
  }

  @override
  Future<GenerateHistory> saveToHistory(String motifId) async {
    await Future.delayed(latency);
    final motif = MockData.motifById(motifId);
    if (motif == null) throw const NotFoundException();
    final category = MockData.categoryById(motif.categoryId);
    return GenerateHistory(
      id: MockData.nextHistoryId(),
      categoryId: motif.categoryId,
      generatedImage: motif.imageUrl,
      createdAt: DateTime.now(),
      categoryName: category?.name,
    );
  }

  @override
  Future<MotifImage> getDownloadInfo(String motifId) async {
    await Future.delayed(latency);
    final motif = MockData.motifById(motifId);
    if (motif == null) throw const NotFoundException();
    return MotifImage(
      id: 'img-$motifId',
      generatedMotifId: motifId,
      url: motif.imageUrl,
      fileName: '$motifId.png',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteHistory(String id) async {
    await Future.delayed(latency);
    if (simulatedError != null) throw simulatedError!;
    // In-memory no-op: the mock list is constant.
  }
}
