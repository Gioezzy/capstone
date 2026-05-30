// Unit tests for MockMotifRepository behavior.
import 'package:capstone/core/error/app_exception.dart';
import 'package:capstone/data/repositories/mock_motif_repository.dart';
import 'package:capstone/domain/models/models.dart';
import 'package:capstone/domain/repositories/motif_repository.dart';
import 'package:flutter_test/flutter_test.dart';

// Zero latency keeps tests fast.
MockMotifRepository _repo({AppException? error, int? seed}) =>
    MockMotifRepository(
      simulatedError: error,
      latency: Duration.zero,
      randomSeed: seed,
    );

GenerateRequest _request({int? noiseSeed, String categoryId = 'cat-001'}) =>
    GenerateRequest(
      categoryId: categoryId,
      resolution: Resolution.px128,
      conditions: const {AttributeCondition.simetris},
      noiseSeed: noiseSeed,
    );

void main() {
  group('getCategories', () {
    test('success path returns all 8 categories', () async {
      final categories = await _repo().getCategories();
      expect(categories, isNotEmpty);
      expect(categories.length, 8);
    });
  });

  group('getHistories', () {
    test('default returns non-empty list', () async {
      final histories = await _repo().getHistories();
      expect(histories, isNotEmpty);
    });

    test('filters by existing categoryId', () async {
      final histories = await _repo().getHistories(categoryId: 'cat-001');
      expect(histories, isNotEmpty);
      expect(histories.every((h) => h.categoryId == 'cat-001'), isTrue);
    });

    test('default sort (newest) puts most recent first (descending createdAt)',
        () async {
      final histories = await _repo().getHistories();
      final first = histories.first.createdAt;
      final last = histories.last.createdAt;
      expect(first.isAfter(last) || first.isAtSameMomentAs(last), isTrue);
    });

    test('sort oldest puts earliest first (ascending createdAt)', () async {
      final histories = await _repo().getHistories(sort: HistorySort.oldest);
      final first = histories.first.createdAt;
      final last = histories.last.createdAt;
      expect(first.isBefore(last) || first.isAtSameMomentAs(last), isTrue);
    });

    test('newest vs oldest produce opposite first element', () async {
      final repo = _repo();
      final newest = await repo.getHistories();
      final oldest = await repo.getHistories(sort: HistorySort.oldest);
      expect(newest.first.createdAt, oldest.last.createdAt);
      expect(oldest.first.createdAt, newest.last.createdAt);
    });

    test('small pageSize limits result length', () async {
      final page = await _repo().getHistories(pageSize: 2);
      expect(page.length, lessThanOrEqualTo(2));
    });

    test('page beyond range returns empty list', () async {
      final page = await _repo().getHistories(page: 999);
      expect(page, isEmpty);
    });

    test('throws simulated error', () async {
      final repo = _repo(error: const NetworkException());
      await expectLater(
        repo.getHistories(),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('not found lookups', () {
    test('getCategory with unknown id throws NotFoundException', () async {
      await expectLater(
        _repo().getCategory('unknown'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('getMotif with unknown id throws NotFoundException', () async {
      await expectLater(
        _repo().getMotif('unknown'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('generateMotif success', () {
    test('uses provided non-null seed and returns non-empty historyId',
        () async {
      final result = await _repo().generateMotif(_request(noiseSeed: 42));
      expect(result.usedSeed, 42);
      expect(result.historyId, isNotEmpty);
    });

    test('picks a seed when noiseSeed is null', () async {
      final result = await _repo(seed: 7).generateMotif(_request());
      expect(result.historyId, isNotEmpty);
      expect(result.usedSeed, isNonNegative);
    });
  });

  group('generateMotif error paths', () {
    test('throws NetworkException', () async {
      final repo = _repo(error: const NetworkException());
      await expectLater(
        repo.generateMotif(_request()),
        throwsA(isA<NetworkException>()),
      );
    });

    test('throws ServerUnavailableException', () async {
      final repo = _repo(error: const ServerUnavailableException());
      await expectLater(
        repo.generateMotif(_request()),
        throwsA(isA<ServerUnavailableException>()),
      );
    });

    test('throws GenerationFailedException', () async {
      final repo = _repo(error: const GenerationFailedException());
      await expectLater(
        repo.generateMotif(_request()),
        throwsA(isA<GenerationFailedException>()),
      );
    });
  });

  group('saveToHistory & getDownloadInfo', () {
    test('saveToHistory with valid motif id returns GenerateHistory', () async {
      final history = await _repo().saveToHistory('mtf-101');
      expect(history, isA<GenerateHistory>());
      expect(history.id, isNotEmpty);
      expect(history.categoryId, isNotEmpty);
    });

    test('getDownloadInfo returns MotifImage with .png fileName', () async {
      final image = await _repo().getDownloadInfo('mtf-101');
      expect(image, isA<MotifImage>());
      expect(image.fileName, endsWith('.png'));
    });
  });
}
