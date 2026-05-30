// Property 3: isSeedValid IFF empty or non-negative integer.
import 'dart:math';

import 'package:capstone/domain/models/motif_category.dart';
import 'package:capstone/features/configure/presentation/configure_controller.dart';
import 'package:flutter_test/flutter_test.dart';

const _iterations = 500;
const _seed = 12345;

// Dummy category; seed validation is independent of category content.
final _dummyCategory = MotifCategory(
  id: 'cat-001',
  name: 'Pucuk Rebung',
  description: 'dummy',
  previewImage: 'dummy.png',
  createdAt: DateTime.utc(2023),
  updatedAt: DateTime.utc(2023),
);

ConfigureState _stateWithSeed(String seedInput) =>
    ConfigureState(category: _dummyCategory, seedInput: seedInput);

// Ground truth derived independently from the spec definition.
bool _expectedValid(String s) {
  if (s.isEmpty) return true;
  final parsed = int.tryParse(s);
  return parsed != null && parsed >= 0;
}

// Random string biased toward seed-relevant shapes (ints, signs, junk).
String _randomSeedInput(Random r) {
  switch (r.nextInt(6)) {
    case 0:
      return ''; // empty -> random seed
    case 1:
      return '${r.nextInt(1000000)}'; // non-negative int
    case 2:
      return '-${1 + r.nextInt(1000000)}'; // negative int
    case 3:
      return '${r.nextDouble() * 100}'; // decimal
    case 4:
      return '${r.nextBool() ? '+' : ''}${r.nextInt(1000)}'; // optional plus
    default:
      const chars = 'abcXYZ +-.0123456789 ';
      final len = r.nextInt(6);
      return String.fromCharCodes(
        List.generate(len, (_) => chars.codeUnitAt(r.nextInt(chars.length))),
      );
  }
}

void _check(String s) {
  final state = _stateWithSeed(s);
  final expectedValid = _expectedValid(s);

  expect(state.isSeedValid, expectedValid,
      reason: 'isSeedValid mismatch for "$s"');

  if (expectedValid) {
    final seed = state.toRequest().noiseSeed;
    if (s.isEmpty) {
      expect(seed, isNull, reason: 'empty seed -> null for "$s"');
    } else {
      expect(seed, int.parse(s), reason: 'noiseSeed parse mismatch for "$s"');
    }
  }
}

void main() {
  group('Property 3: Validasi Noise Seed', () {
    // Validates: Requirements 2.2
    test('isSeedValid IFF empty or non-negative integer (random samples)', () {
      final r = Random(_seed);
      for (var i = 0; i < _iterations; i++) {
        _check(_randomSeedInput(r));
      }
    });

    test('explicit edge cases', () {
      const validCases = ['', '0', '7', '12345', '+5', '00', '007'];
      const invalidCases = [
        '-1',
        '-42',
        '1.5',
        '0.0',
        'abc',
        '12a',
        ' ',
        '',
      ];
      for (final s in validCases) {
        expect(_stateWithSeed(s).isSeedValid, isTrue, reason: 'valid: "$s"');
        _check(s);
      }
      for (final s in invalidCases) {
        if (s.isEmpty) continue; // '' is valid; guard against typos
        expect(_stateWithSeed(s).isSeedValid, isFalse, reason: 'invalid: "$s"');
        _check(s);
      }
    });

    test('empty seed yields null noiseSeed', () {
      expect(_stateWithSeed('').toRequest().noiseSeed, isNull);
    });
  });
}
