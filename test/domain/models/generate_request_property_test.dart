import 'dart:math';

import 'package:capstone/domain/models/enums.dart';
import 'package:capstone/domain/models/generate_request.dart';
import 'package:flutter_test/flutter_test.dart';

// Valid attribute names allowed in the conditions payload.
final Set<String> _validConditionNames =
    AttributeCondition.values.map((c) => c.name).toSet();

// Build a deterministic random GenerateRequest.
// forceNullSeed/forceEmptyConditions cover null-seed and empty-set branches.
GenerateRequest _randomRequest(
  Random rng, {
  bool forceNullSeed = false,
  bool forceEmptyConditions = false,
}) {
  final categoryId = 'cat-${rng.nextInt(100000)}';
  final resolution = Resolution.values[rng.nextInt(Resolution.values.length)];

  final conditions = <AttributeCondition>{};
  if (!forceEmptyConditions) {
    for (final c in AttributeCondition.values) {
      if (rng.nextBool()) conditions.add(c);
    }
  }

  final int? noiseSeed =
      forceNullSeed ? null : (rng.nextBool() ? null : rng.nextInt(1 << 31));

  return GenerateRequest(
    categoryId: categoryId,
    resolution: resolution,
    conditions: conditions,
    noiseSeed: noiseSeed,
  );
}

void main() {
  // Property 2: GenerateRequest.toJson() invariants.
  group('Property 2: GenerateRequest Serialization', () {
    const iterations = 200;

    test('toJson() invariants hold over many random requests', () {
      final rng = Random(20240526); // fixed seed for determinism

      for (var i = 0; i < iterations; i++) {
        // Force null seed and empty conditions on some samples for coverage.
        final r = _randomRequest(
          rng,
          forceNullSeed: i % 7 == 0,
          forceEmptyConditions: i % 11 == 0,
        );
        final json = r.toJson();

        // resolution in {'64x64','128x128'}.
        expect(json['resolution'], anyOf('64x64', '128x128'),
            reason: 'unexpected resolution at i=$i: ${json['resolution']}');

        // conditions: List<String>, valid subset, no duplicates, same length.
        final conditions = json['conditions'];
        expect(conditions, isA<List<String>>(),
            reason: 'conditions not List<String> at i=$i');
        final list = (conditions as List).cast<String>();
        for (final name in list) {
          expect(_validConditionNames.contains(name), isTrue,
              reason: 'invalid condition "$name" at i=$i');
        }
        expect(list.toSet().length, list.length,
            reason: 'duplicate conditions at i=$i: $list');
        expect(list.length, r.conditions.length,
            reason: 'conditions length mismatch at i=$i');

        // noise_seed: null or non-negative int equal to r.noiseSeed.
        final seed = json['noise_seed'];
        if (r.noiseSeed == null) {
          expect(seed, isNull, reason: 'expected null seed at i=$i');
        } else {
          expect(seed, isA<int>(), reason: 'seed not int at i=$i');
          expect(seed, greaterThanOrEqualTo(0),
              reason: 'negative seed at i=$i');
          expect(seed, r.noiseSeed, reason: 'seed mismatch at i=$i');
        }

        // Round-trip: fromJson(toJson()) == r.
        expect(GenerateRequest.fromJson(json), equals(r),
            reason: 'round-trip failed at i=$i');
      }
    });

    test('explicit null seed serializes to null and round-trips', () {
      // noiseSeed omitted -> defaults to null.
      const r = GenerateRequest(
        categoryId: 'cat-1',
        resolution: Resolution.px64,
        conditions: {AttributeCondition.simetris},
      );
      final json = r.toJson();
      expect(json['noise_seed'], isNull);
      expect(GenerateRequest.fromJson(json), equals(r));
    });

    test('empty conditions serialize to empty list and round-trip', () {
      const r = GenerateRequest(
        categoryId: 'cat-2',
        resolution: Resolution.px128,
        conditions: {},
        noiseSeed: 0,
      );
      final json = r.toJson();
      expect(json['conditions'], isEmpty);
      expect(GenerateRequest.fromJson(json), equals(r));
    });
  });
}
