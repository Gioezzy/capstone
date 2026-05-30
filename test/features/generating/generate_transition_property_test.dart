// Property 4: only allowed GenerateState transitions occur.
import 'dart:math';

import 'package:capstone/core/error/app_exception.dart';
import 'package:capstone/data/mock/mock_data.dart';
import 'package:capstone/domain/models/models.dart';
import 'package:capstone/domain/repositories/motif_repository.dart';
import 'package:capstone/features/generating/presentation/generating_controller.dart';
import 'package:flutter_test/flutter_test.dart';

const _iterations = 100;
const _seed = 246810;

// Configurable fake repo: succeeds or throws, with optional generate delay.
class _FakeMotifRepository implements MotifRepository {
  bool shouldThrow;
  AppException error;
  final Duration generateDelay;

  _FakeMotifRepository({
    this.shouldThrow = false,
    this.error = const GenerationFailedException(),
    this.generateDelay = Duration.zero,
  });

  @override
  Future<GenerateResult> generateMotif(GenerateRequest request) async {
    if (generateDelay > Duration.zero) await Future<void>.delayed(generateDelay);
    if (shouldThrow) throw error;
    final seed = request.noiseSeed ?? 0;
    return GenerateResult(
      motif: MockData.motifFor(request.categoryId, seed),
      usedSeed: seed,
      historyId: MockData.nextHistoryId(),
    );
  }

  // Unused by the generate flow under test.
  @override
  Future<List<MotifCategory>> getCategories() => throw UnimplementedError();
  @override
  Future<MotifCategory> getCategory(String id) => throw UnimplementedError();
  @override
  Future<List<GenerateHistory>> getHistories({
    int page = 1,
    int pageSize = 20,
    String? categoryId,
    HistorySort sort = HistorySort.newest,
  }) =>
      throw UnimplementedError();
  @override
  Future<GeneratedMotif> getMotif(String id) => throw UnimplementedError();
  @override
  Future<GenerateHistory> saveToHistory(String motifId) =>
      throw UnimplementedError();
  @override
  Future<MotifImage> getDownloadInfo(String motifId) =>
      throw UnimplementedError();
  @override
  Future<void> deleteHistory(String id) => throw UnimplementedError();
}

// Allowed transition table. Re-emitting the same state (e.g. Loading progress
// updates, or Cancelled emitted twice on cancel) is not a forbidden transition.
bool isValidTransition(GenerateState from, GenerateState to) {
  if (from.runtimeType == to.runtimeType) return true;
  return switch (from) {
    GenerateIdle() => to is GenerateLoading,
    GenerateLoading() =>
      to is GenerateSuccess || to is GenerateError || to is GenerateCancelled,
    GenerateError() => to is GenerateLoading,
    GenerateCancelled() => to is GenerateIdle,
    GenerateSuccess() => false, // terminal
  };
}

String _name(GenerateState s) => s.runtimeType.toString();

// Asserts every consecutive pair in a recorded run is an allowed transition.
void _assertValidRun(List<GenerateState> states, String label) {
  for (var i = 0; i + 1 < states.length; i++) {
    final from = states[i];
    final to = states[i + 1];
    expect(isValidTransition(from, to), isTrue,
        reason: '$label: forbidden transition ${_name(from)} -> ${_name(to)} '
            'at index $i; full=${states.map(_name).toList()}');
  }
}

GenerateRequest _request(Random r) => GenerateRequest(
      categoryId: 'cat-00${1 + r.nextInt(8)}',
      resolution: Resolution.values[r.nextInt(Resolution.values.length)],
      conditions:
          AttributeCondition.values.where((_) => r.nextBool()).toSet(),
      noiseSeed: r.nextBool() ? r.nextInt(1 << 31) : null,
    );

const _errors = <AppException>[
  NetworkException(),
  ServerUnavailableException(),
  GenerationFailedException(),
];

void main() {
  group('Property 4: Transisi State Generate Valid', () {
    test('success path over random requests', () async {
      final r = Random(_seed);
      for (var i = 0; i < _iterations; i++) {
        final repo = _FakeMotifRepository();
        final controller =
            GeneratingController(repo: repo, stepDelay: Duration.zero);
        final states = <GenerateState>[];
        controller.addListener(states.add, fireImmediately: true);
        await controller.start(_request(r));

        _assertValidRun(states, 'success#$i');
        expect(states.first, isA<GenerateIdle>());
        expect(states.last, isA<GenerateSuccess>());
        // No direct Idle -> Success without Loading in between.
        expect(states[1], isA<GenerateLoading>(),
            reason: 'success#$i: first transition must be Idle -> Loading');
        controller.dispose();
      }
    });

    test('error then retry path: Error -> Loading -> Success', () async {
      final r = Random(_seed + 1);
      for (var i = 0; i < _iterations; i++) {
        final repo = _FakeMotifRepository(
          shouldThrow: true,
          error: _errors[r.nextInt(_errors.length)],
        );
        final controller =
            GeneratingController(repo: repo, stepDelay: Duration.zero);
        final states = <GenerateState>[];
        controller.addListener(states.add, fireImmediately: true);

        final req = _request(r);
        await controller.start(req); // -> Error

        expect(states.last, isA<GenerateError>());

        repo.shouldThrow = false; // make retry succeed
        await controller.retry(req); // Error -> Loading -> Success

        _assertValidRun(states, 'retry#$i');
        expect(states.last, isA<GenerateSuccess>());
        // Error must be followed by Loading (Error -> Loading), never Success.
        final errIndex = states.indexWhere((s) => s is GenerateError);
        expect(states[errIndex + 1], isA<GenerateLoading>(),
            reason: 'retry#$i: Error must transition to Loading');
        controller.dispose();
      }
    });

    test('cancel during loading then reset: Loading -> Cancelled -> Idle',
        () async {
      final r = Random(_seed + 2);
      for (var i = 0; i < 25; i++) {
        final repo = _FakeMotifRepository(
          generateDelay: const Duration(milliseconds: 200),
        );
        final controller =
            GeneratingController(repo: repo, stepDelay: Duration.zero);
        final states = <GenerateState>[];
        controller.addListener(states.add, fireImmediately: true);

        final future = controller.start(_request(r)); // do not await yet
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(states.last, isA<GenerateLoading>(),
            reason: 'cancel#$i: expected Loading before cancel');

        controller.cancel(); // Loading -> Cancelled
        await future; // let start() finish (no pending timers)

        expect(states.last, isA<GenerateCancelled>());

        controller.reset(); // Cancelled -> Idle
        expect(states.last, isA<GenerateIdle>());

        _assertValidRun(states, 'cancel#$i');
        // A Cancelled state is reached only from Loading.
        final cancelIndex = states.indexWhere((s) => s is GenerateCancelled);
        expect(states[cancelIndex - 1], isA<GenerateLoading>(),
            reason: 'cancel#$i: Cancelled must come from Loading');
        controller.dispose();
      }
    });

    test('forbidden transitions are rejected by isValidTransition', () {
      const idle = GenerateIdle();
      const loading = GenerateLoading();
      final success = GenerateSuccess(GenerateResult(
        motif: MockData.motifs.first,
        usedSeed: 1,
        historyId: 'gen-1',
      ));
      const error = GenerateError(GenerationFailedException());
      const cancelled = GenerateCancelled();

      // Explicitly forbidden direct transitions.
      expect(isValidTransition(idle, success), isFalse);
      expect(isValidTransition(idle, error), isFalse);
      expect(isValidTransition(idle, cancelled), isFalse);
      expect(isValidTransition(success, loading), isFalse);
      expect(isValidTransition(success, idle), isFalse);
      expect(isValidTransition(error, success), isFalse);
      expect(isValidTransition(error, cancelled), isFalse);
      expect(isValidTransition(cancelled, loading), isFalse);
      expect(isValidTransition(cancelled, success), isFalse);

      // Allowed transitions.
      expect(isValidTransition(idle, loading), isTrue);
      expect(isValidTransition(loading, success), isTrue);
      expect(isValidTransition(loading, error), isTrue);
      expect(isValidTransition(loading, cancelled), isTrue);
      expect(isValidTransition(error, loading), isTrue);
      expect(isValidTransition(cancelled, idle), isTrue);
    });
  });
}
