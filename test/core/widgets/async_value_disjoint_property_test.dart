// Property 9: AsyncValueView renders exactly one of loading/success/empty/error.
import 'dart:math';

import 'package:capstone/core/error/app_exception.dart';
import 'package:capstone/core/widgets/async_value_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _iterations = 200;
const _seed = 13579;

// Unique markers per branch so detection never collides with defaults.
const _loadingMarker = 'LOADING-MARKER';
const _errorMarker = 'ERROR-MARKER';
const _emptyMarker = 'EMPTY-MARKER';
const _dataPrefix = 'DATA-';

// Pump AsyncValueView with custom markers for every branch.
Future<void> _pumpView(WidgetTester tester, AsyncValue<List<int>> value) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AsyncValueView<List<int>>(
          value: value,
          isEmpty: (l) => l.isEmpty,
          data: (l) => Text('$_dataPrefix${l.length}'),
          emptyBuilder: () => const Text(_emptyMarker),
          errorBuilder: (e) => const Text(_errorMarker),
          loading: const Text(_loadingMarker),
        ),
      ),
    ),
  );
}

// Assert that exactly `present` marker is shown and the other three are absent.
void _expectExactlyOne(String present) {
  const all = [_loadingMarker, _errorMarker, _emptyMarker, _dataPrefix];
  for (final marker in all) {
    final matcher = marker == _dataPrefix
        ? find.textContaining(_dataPrefix)
        : find.text(marker);
    expect(matcher, marker == present ? findsOneWidget : findsNothing,
        reason: 'expected exactly "$present"; marker "$marker" mismatched');
  }
}

void main() {
  group('Property 9: Empty vs Error Disjoint (AsyncValueView)', () {
    testWidgets('loading renders exactly the loading branch', (tester) async {
      await _pumpView(tester, const AsyncValue.loading());
      _expectExactlyOne(_loadingMarker);
    });

    testWidgets('error renders exactly the error branch', (tester) async {
      final errors = <AppException>[
        const NetworkException(),
        const ServerUnavailableException(),
        const GenerationFailedException(),
      ];
      for (final e in errors) {
        await _pumpView(tester, AsyncValue.error(e, StackTrace.empty));
        _expectExactlyOne(_errorMarker);
      }
    });

    testWidgets('empty data renders exactly the empty branch', (tester) async {
      await _pumpView(tester, const AsyncValue.data(<int>[]));
      _expectExactlyOne(_emptyMarker);
    });

    testWidgets('non-empty data renders exactly the data branch',
        (tester) async {
      await _pumpView(tester, const AsyncValue.data(<int>[1, 2, 3]));
      _expectExactlyOne(_dataPrefix);
    });

    // Property: across randomized conditions, exactly one branch is ever shown.
    testWidgets('exactly one branch for randomized load outcomes',
        (tester) async {
      final r = Random(_seed);
      for (var i = 0; i < _iterations; i++) {
        switch (r.nextInt(4)) {
          case 0:
            await _pumpView(tester, const AsyncValue.loading());
            _expectExactlyOne(_loadingMarker);
          case 1:
            await _pumpView(
                tester,
                const AsyncValue.error(NetworkException(), StackTrace.empty));
            _expectExactlyOne(_errorMarker);
          case 2:
            await _pumpView(tester, const AsyncValue.data(<int>[]));
            _expectExactlyOne(_emptyMarker);
          default:
            final len = 1 + r.nextInt(5); // 1..5
            await _pumpView(
                tester, AsyncValue.data(List<int>.generate(len, (j) => j)));
            _expectExactlyOne(_dataPrefix);
        }
      }
    });
  });
}
