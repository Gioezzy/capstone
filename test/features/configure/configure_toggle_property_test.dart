// Property 8: toggling an attribute twice is the identity.
import 'dart:math';

import 'package:capstone/domain/models/enums.dart';
import 'package:capstone/domain/models/motif_category.dart';
import 'package:capstone/features/configure/presentation/configure_controller.dart';
import 'package:flutter_test/flutter_test.dart';

const _iterations = 500;
const _seed = 98765;

// Dummy category; conditions are the only field under test.
final _dummyCategory = MotifCategory(
  id: 'cat-test',
  name: 'Test',
  description: '',
  previewImage: '',
  createdAt: DateTime.utc(2024),
  updatedAt: DateTime.utc(2024),
);

ConfigureState _stateWith(Set<AttributeCondition> conditions) =>
    ConfigureState(category: _dummyCategory, conditions: conditions);

bool _setEqual(Set<AttributeCondition> a, Set<AttributeCondition> b) =>
    a.length == b.length && a.containsAll(b);

// Random subset of all attribute values (includes empty & full).
Set<AttributeCondition> _randomSubset(Random r) =>
    AttributeCondition.values.where((_) => r.nextBool()).toSet();

void main() {
  group('Property 8: Idempotensi Pemilihan Atribut', () {
    test('toggle(toggle(S, a), a) == S for random subsets', () {
      final r = Random(_seed);
      for (var i = 0; i < _iterations; i++) {
        final s = _randomSubset(r);
        final a = AttributeCondition.values[
            r.nextInt(AttributeCondition.values.length)];

        final result = _stateWith(s).toggleCondition(a).toggleCondition(a);

        expect(_setEqual(result.conditions, s), isTrue,
            reason: 'double toggle changed set on sample $i: S=$s a=$a '
                '-> ${result.conditions}');
      }
    });

    test('single toggle flips membership of a (not a no-op)', () {
      final r = Random(_seed + 1);
      for (var i = 0; i < _iterations; i++) {
        final s = _randomSubset(r);
        final a = AttributeCondition.values[
            r.nextInt(AttributeCondition.values.length)];
        final wasPresent = s.contains(a);

        final once = _stateWith(s).toggleCondition(a).conditions;

        expect(once.contains(a), equals(!wasPresent),
            reason: 'toggle did not flip membership on sample $i: S=$s a=$a');
      }
    });

    // Explicit edge cases.
    test('empty set: toggle twice returns empty', () {
      for (final a in AttributeCondition.values) {
        final result =
            _stateWith(<AttributeCondition>{}).toggleCondition(a).toggleCondition(a);
        expect(result.conditions, isEmpty);
      }
    });

    test('full set: toggle twice returns full set', () {
      final full = AttributeCondition.values.toSet();
      for (final a in AttributeCondition.values) {
        final result = _stateWith(full).toggleCondition(a).toggleCondition(a);
        expect(_setEqual(result.conditions, full), isTrue);
      }
    });
  });
}
