// Property 6: same non-null seed reproduces the same motif imageUrl.
import 'dart:math';

import 'package:capstone/data/mock/mock_data.dart';
import 'package:capstone/data/repositories/mock_motif_repository.dart';
import 'package:capstone/domain/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

const _iterations = 100;
const _seed = 6006; // fixed -> deterministic, reproducible runs

final _categoryIds = MockData.categories.map((c) => c.id).toList();

GenerateRequest _request(Random r, {int? noiseSeed}) => GenerateRequest(
      categoryId: _categoryIds[r.nextInt(_categoryIds.length)],
      resolution: Resolution.values[r.nextInt(Resolution.values.length)],
      conditions:
          AttributeCondition.values.where((_) => r.nextBool()).toSet(),
      noiseSeed: noiseSeed ?? r.nextInt(0x7fffffff), // non-null, >= 0
    );

void main() {
  group('Property 6: Reproduksi Seed (Validates: Requirements 2.5)', () {
    test('same non-null seed -> identical imageUrl and usedSeed', () async {
      final r = Random(_seed);
      final repo = MockMotifRepository(latency: Duration.zero);

      for (var i = 0; i < _iterations; i++) {
        final request = _request(r);

        final result1 = await repo.generateMotif(request);
        final result2 = await repo.generateMotif(request);

        expect(result1.motif.imageUrl, equals(result2.motif.imageUrl),
            reason: 'imageUrl not reproduced on sample $i: $request');
        expect(result1.usedSeed, equals(request.noiseSeed),
            reason: 'usedSeed != request seed on sample $i: $request');
        expect(result2.usedSeed, equals(request.noiseSeed),
            reason: 'usedSeed != request seed on sample $i: $request');
      }
    });

    // Example: a different seed yields a different motif for one known case.
    test('different seed -> different imageUrl (known case)', () async {
      final repo = MockMotifRepository(latency: Duration.zero);
      const conditions = <AttributeCondition>{AttributeCondition.simetris};

      final a = await repo.generateMotif(const GenerateRequest(
        categoryId: 'cat-001',
        resolution: Resolution.px128,
        conditions: conditions,
        noiseSeed: 1,
      ));
      final b = await repo.generateMotif(const GenerateRequest(
        categoryId: 'cat-001',
        resolution: Resolution.px128,
        conditions: conditions,
        noiseSeed: 2,
      ));

      expect(a.motif.imageUrl, isNot(equals(b.motif.imageUrl)));
    });
  });
}
