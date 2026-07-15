import 'package:capstone/core/widgets/attribute_chip.dart';
import 'package:capstone/core/widgets/primary_button.dart';
import 'package:capstone/data/mock/mock_data.dart';
import 'package:capstone/domain/models/models.dart';
import 'package:capstone/features/configure/presentation/configure_controller.dart';
import 'package:capstone/features/configure/presentation/configure_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _categoryId = 'cat-001';

Widget _wrap() => const ProviderScope(
      child: MaterialApp(home: ConfigureScreen(categoryId: _categoryId)),
    );

// Reads controller state via the screen's ProviderScope container.
ConfigureState _state(WidgetTester tester) {
  final category = MockData.categoryById(_categoryId)!;
  final container =
      ProviderScope.containerOf(tester.element(find.byType(ConfigureScreen)));
  return container.read(configureControllerProvider(category));
}

// Resolves the ElevatedButton wrapped by the Generate PrimaryButton.
ElevatedButton _generateButton(WidgetTester tester) {
  return tester.widget<ElevatedButton>(
    find.descendant(
      of: find.byType(PrimaryButton),
      matching: find.byType(ElevatedButton),
    ),
  );
}

void main() {
  group('ConfigureScreen', () {
    testWidgets('renders title, category, chips, resolutions and button',
        (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Konfigurasi Generasi'), findsOneWidget);
      expect(find.text('Apel'), findsOneWidget);

      expect(find.byType(AttributeChip), findsNWidgets(4));
      for (final label in ['Simetris', 'Padat', 'Minimalis', 'Geometris']) {
        expect(find.text(label), findsOneWidget);
      }

      expect(find.text('64×64 px'), findsOneWidget);
      expect(find.text('128×128 px'), findsOneWidget);
      expect(find.text('Generate Motif'), findsOneWidget);
    });

    testWidgets('tapping a chip selects its condition', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(_state(tester).conditions, isEmpty);

      await tester.tap(find.text('Simetris'));
      await tester.pump();

      expect(
        _state(tester).conditions,
        contains(AttributeCondition.simetris),
      );
    });

    testWidgets('selecting 64x64 updates resolution from default px128',
        (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(_state(tester).resolution, Resolution.px128);

      await tester.tap(find.text('64×64 px'));
      await tester.pump();

      expect(_state(tester).resolution, Resolution.px64);
    });

    testWidgets('invalid seed disables Generate, valid seed enables it',
        (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      // Empty seed is valid -> enabled.
      expect(_generateButton(tester).onPressed, isNotNull);

      // Negative seed is invalid -> disabled.
      await tester.enterText(find.byType(TextField), '-1');
      await tester.pump();
      expect(_generateButton(tester).onPressed, isNull);

      // Non-negative integer -> enabled.
      await tester.enterText(find.byType(TextField), '7');
      await tester.pump();
      expect(_generateButton(tester).onPressed, isNotNull);

      // Cleared field -> valid -> enabled.
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(_generateButton(tester).onPressed, isNotNull);
    });
  });
}
