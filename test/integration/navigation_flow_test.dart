import 'package:capstone/app.dart';
import 'package:capstone/core/widgets/app_bottom_nav.dart';
import 'package:capstone/core/widgets/motif_card.dart';
import 'package:capstone/data/repositories/mock_motif_repository.dart';
import 'package:capstone/features/categories/presentation/categories_screen.dart';
import 'package:capstone/features/configure/presentation/configure_screen.dart';
import 'package:capstone/features/generating/presentation/generating_controller.dart';
import 'package:capstone/features/home/presentation/home_screen.dart';
import 'package:capstone/features/result/presentation/result_screen.dart';
import 'package:capstone/features/settings/presentation/settings_screen.dart';
import 'package:capstone/providers/repository_providers.dart';
import 'package:capstone/providers/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Valid 1x1 transparent PNG.
final Uint8List _tinyPng = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

// Serves a valid PNG for image assets; delegates everything else (e.g. the
// asset manifest) to the real bundle so MockData's placeholder paths don't
// raise image-load exceptions during the flow.
class _ImageStubBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) {
    if (key.endsWith('.png') || key.endsWith('.jpg') || key.endsWith('.jpeg')) {
      return Future.value(ByteData.view(_tinyPng.buffer));
    }
    return rootBundle.load(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  // Real router (SongketApp) with fast, deterministic, non-throwing providers.
  Widget app() => ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          motifRepositoryProvider
              .overrideWithValue(MockMotifRepository(latency: Duration.zero)),
          generatingControllerProvider.overrideWith(
            (ref) => GeneratingController(
              repo: ref.watch(motifRepositoryProvider),
              stepDelay: Duration.zero,
            ),
          ),
        ],
        child: DefaultAssetBundle(
          bundle: _ImageStubBundle(),
          child: const SongketApp(),
        ),
      );

  // Large surface so every tappable element is laid out and hit-testable.
  void useLargeSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // Boot the app and wait out the splash timer to land on Home.
  Future<void> bootToHome(WidgetTester tester) async {
    await tester.pumpWidget(app());
    await tester.pump(const Duration(seconds: 2)); // fire splash delay
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  }

  group('navigation integration', () {
    testWidgets('category -> configure -> generate -> result', (tester) async {
      useLargeSurface(tester);
      await bootToHome(tester);

      // Home -> Categories.
      await tester.tap(find.text('Mulai Generate'));
      await tester.pumpAndSettle();
      expect(find.byType(CategoriesScreen), findsOneWidget);
      expect(find.text('Motif Categories'), findsOneWidget);

      // Pick first category -> Configure (Req 1.2).
      await tester.tap(find.byType(MotifCard).first);
      await tester.pumpAndSettle();
      expect(find.byType(ConfigureScreen), findsOneWidget);
      expect(find.text('Konfigurasi Generasi'), findsOneWidget);

      // Generate -> Generating -> Result (Req 3.2).
      await tester.tap(find.text('Generate Motif'));
      await tester.pumpAndSettle();
      expect(find.byType(ResultScreen), findsOneWidget);
      expect(find.text('Hasil Generasi'), findsOneWidget);
    });

    testWidgets('bottom nav switches tabs and preserves Home state (Req 8.3)',
        (tester) async {
      useLargeSurface(tester);
      await bootToHome(tester);

      expect(find.byType(AppBottomNav), findsOneWidget);
      expect(find.text('Selamat Datang'), findsOneWidget);

      // Generate -> History tab.
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.text('Generated Motifs'), findsOneWidget);

      // History -> Settings tab.
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Back to Generate tab: Home state preserved (banner still shown).
      await tester.tap(find.text('Generate'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Selamat Datang'), findsOneWidget);
    });
  });
}
