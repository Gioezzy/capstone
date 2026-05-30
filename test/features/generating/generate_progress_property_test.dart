// Property 5: loading progress is monotonic in [0,1] and reaches 1.0 on success.
import 'dart:math';

import 'package:capstone/data/mock/mock_data.dart';
import 'package:capstone/domain/models/models.dart';
import 'package:capstone/domain/repositories/motif_repository.dart';
import 'package:capstone/features/generating/presentation/generating_controller.dart';
import 'package:flutter_test/flutter_test.dart';

const _iterations = 50;
const _seed = 5005; // fixed -> deterministic, reproducible runs

final _categoryIds = MockData.categories.map((c) => c.id).toList();

// Fake repo: generate always succeeds with a deterministic MockData motif.
class _FakeSuccessRepository implements MotifRepository {
  @override
  Future<GenerateResult> generateMotif(GenerateRequest request) async {
    final seed = request.noiseSeed ?? 0;
    return GenerateResult(
      motif: MockData.motifFor(request.categoryId, seed),
      usedSeed: seed,
      historyId: 'gen-test',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('not needed for Property 5');
}

GenerateRequest _request(Random r) => GenerateRequest(
      categoryId: _categoryIds[r.nextInt(_categoryIds.length)],
      resolution: Resolution.values[r.nextInt(Resolution.values.length)],
      conditions: AttributeCondition.values.where((_) => r.nextBool()).toSet(),
      noiseSeed: r.nextBool() ? r.nextInt(0x7fffffff) : null,
    );

// Runs one generate flow and returns all observed states in order.
Future<List<GenerateState>> _runFlow(GenerateRequest request) async {
  final controller = GeneratingController(
    repo: _FakeSuccessRepository(),
    stepDelay: const Duration(milliseconds: 1),
  );
  final states = <GenerateState>[];
  final remove = controller.addListener(states.add, fireImmediately: true);
  await controller.start(request);
  remove();
  controller.dispose();
  return states;
}

void main() {
  group('Property 5: Monotonisitas Progress (Validates: Requirements 2.4)', () {
    test('progress in [0,1], non-decreasing, reaches 1.0 on success', () async {
      final r = Random(_seed);

      for (var i = 0; i < _iterations; i++) {
        final request = _request(r);
        final states = await _runFlow(request);

        final progresses = states
            .whereType<GenerateLoading>()
            .map((s) => s.progress)
            .toList();

        expect(progresses, isNotEmpty,
            reason: 'no loading states observed on sample $i: $request');

        // Each progress within [0.0, 1.0].
        for (final p in progresses) {
          expect(p, inInclusiveRange(0.0, 1.0),
              reason: 'progress out of range on sample $i: $p ($request)');
        }

        // Non-decreasing order.
        for (var j = 0; j + 1 < progresses.length; j++) {
          expect(progresses[j] <= progresses[j + 1], isTrue,
              reason: 'progress decreased on sample $i at $j: '
                  '${progresses[j]} -> ${progresses[j + 1]} ($request)');
        }

        // Reaches 1.0 and ends in success.
        expect(progresses.reduce(max), equals(1.0),
            reason: 'max progress != 1.0 on sample $i: $request');
        expect(states.last, isA<GenerateSuccess>(),
            reason: 'final state not success on sample $i: $request');
      }
    });

    // Example: explicit known case, no pending timers.
    test('known request emits 0.0..1.0 then success', () async {
      const request = GenerateRequest(
        categoryId: 'cat-001',
        resolution: Resolution.px128,
        conditions: {AttributeCondition.simetris, AttributeCondition.geometris},
        noiseSeed: 42,
      );

      final states = await _runFlow(request);
      final progresses =
          states.whereType<GenerateLoading>().map((s) => s.progress).toList();

      expect(progresses.first, equals(0.0));
      expect(progresses.last, equals(1.0));
      expect(states.last, isA<GenerateSuccess>());
    });
  });
}
