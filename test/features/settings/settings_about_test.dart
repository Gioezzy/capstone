import 'package:capstone/core/config/app_constants.dart';
import 'package:capstone/domain/models/enums.dart';
import 'package:capstone/features/about/presentation/about_screen.dart';
import 'package:capstone/features/settings/presentation/settings_screen.dart';
import 'package:capstone/providers/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  // Overrides sharedPreferencesProvider so appSettingsProvider does not throw.
  Widget wrap(Widget child) => ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(home: child),
      );

  // Reads the settings provider via the widget's element.
  bool monochromeOf(WidgetTester tester) {
    final container =
        ProviderScope.containerOf(tester.element(find.byType(SettingsScreen)));
    return container.read(appSettingsProvider).monochromeTheme;
  }

  Resolution resolutionOf(WidgetTester tester) {
    final container =
        ProviderScope.containerOf(tester.element(find.byType(SettingsScreen)));
    return container.read(appSettingsProvider).defaultResolution;
  }

  group('SettingsScreen', () {
    testWidgets('renders url label, resolution dropdown, theme switch, version',
        (tester) async {
      await tester.pumpWidget(wrap(const SettingsScreen()));

      expect(find.text('BACKEND API URL'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(DropdownButton<Resolution>), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
      expect(find.text('v${AppConstants.appVersion}'), findsOneWidget);
    });

    testWidgets('tapping theme switch toggles and persists in provider',
        (tester) async {
      await tester.pumpWidget(wrap(const SettingsScreen()));

      final before = monochromeOf(tester); // defaults to true
      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();

      expect(monochromeOf(tester), !before);
      expect(tester.widget<Switch>(find.byType(Switch)).value, !before);
    });

    testWidgets('selecting 64x64 updates default resolution in provider',
        (tester) async {
      await tester.pumpWidget(wrap(const SettingsScreen()));

      expect(resolutionOf(tester), Resolution.px128); // default

      await tester.tap(find.byType(DropdownButton<Resolution>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('64×64').last);
      await tester.pumpAndSettle();

      expect(resolutionOf(tester), Resolution.px64);
    });
  });

  group('AboutScreen', () {
    testWidgets('renders researcher, core technology, title, architecture',
        (tester) async {
      await tester.pumpWidget(wrap(const AboutScreen()));

      expect(find.text(AppConstants.researcherName), findsOneWidget);
      expect(find.textContaining('cDCGAN'), findsWidgets);
      expect(find.textContaining('Generasi Motif Songket'), findsOneWidget);
      expect(find.text('Model Architecture'), findsOneWidget);
    });
  });
}
