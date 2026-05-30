import 'package:capstone/domain/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Property 10: Resolution apiValue <-> fromApi round-trip.
  group('Property 10: Round-Trip Resolusi Enum', () {
    // fromApi(r.apiValue) == r for every enum value (exhaustive over a small domain).
    test('fromApi(apiValue) round-trips to the same Resolution for all values',
        () {
      for (final r in Resolution.values) {
        expect(Resolution.fromApi(r.apiValue), equals(r),
            reason: 'round-trip failed for $r (apiValue="${r.apiValue}")');
      }
    });

    // pixels is always within {64, 128}, with the expected per-value correlation.
    test('pixels is in {64, 128} and correlates with each value', () {
      for (final r in Resolution.values) {
        expect(r.pixels == 64 || r.pixels == 128, isTrue,
            reason: 'pixels out of allowed set for $r: ${r.pixels}');
      }
      expect(Resolution.px64.pixels, 64);
      expect(Resolution.px128.pixels, 128);
    });

    // fromApi rejects unknown inputs with ArgumentError.
    test('fromApi throws ArgumentError for unknown inputs', () {
      const unknown = <String>['', '32x32', '256', '64', '128', '128X128'];
      for (final value in unknown) {
        expect(() => Resolution.fromApi(value), throwsArgumentError,
            reason: 'expected ArgumentError for "$value"');
      }
    });
  });
}
