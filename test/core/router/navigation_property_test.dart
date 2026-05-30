import 'package:capstone/core/router/app_router.dart';
import 'package:capstone/core/router/routes.dart';
import 'package:capstone/core/widgets/app_bottom_nav.dart';
import 'package:capstone/providers/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Routes that land inside the shell (3-tab bottom nav). '/result' has no extra
// when reached directly, so it redirects to '/home' (also a shell route).
final _bottomNavPaths = <String>[
  Routes.homePath,
  Routes.historyPath,
  Routes.settingsPath,
  Routes.resultPath,
];

// Non-shell screens pushed full with an AppBar back affordance. '/generating'
// has no extra when reached directly, so it redirects to '/categories'.
final _nonShellPaths = <String>[
  Routes.categoriesPath,
  Routes.configurePath,
  Routes.generatingPath,
  Routes.aboutPath,
  Routes.historyDetailPathFor('gen-042'),
];

// Every defined route in routes.dart (concrete instance for the :id path).
final _definedPaths = <String>[
  Routes.splashPath,
  Routes.homePath,
  Routes.categoriesPath,
  Routes.configurePath,
  Routes.generatingPath,
  Routes.resultPath,
  Routes.historyPath,
  Routes.historyDetailPathFor('gen-042'),
  Routes.settingsPath,
  Routes.aboutPath,
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  // Mounts a fresh router and navigates to [path]. Overrides SharedPreferences
  // so settings-backed screens do not throw. Pumps fixed durations (never
  // pumpAndSettle) so indeterminate spinners don't hang, and drains the splash
  // auto-redirect timer plus the 800ms mock latency so no timer leaks.
  Future<void> pumpAt(WidgetTester tester, String path) async {
    await tester.binding.setSurfaceSize(const Size(1080, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final router = createAppRouter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump(); // build initial splash
    router.go(path);
    await tester.pump(); // apply navigation / redirect
    if (path == Routes.splashPath) {
      await tester.pump(const Duration(seconds: 2)); // fire splash redirect
    }
    await tester.pump(const Duration(seconds: 1)); // resolve mock futures
  }

  // Property 7: every defined route resolves to exactly one screen.
  // Validates: Requirements 1.2, 3.2, 5.2
  group('Property 7: Konsistensi Navigasi', () {
    test('all defined routes are distinct and fully enumerated (no orphans)',
        () {
      expect(_definedPaths.length, 10);
      expect(_definedPaths.toSet().length, 10);
    });

    for (final path in _definedPaths) {
      testWidgets('resolves "$path" to a screen, no route error',
          (tester) async {
        await pumpAt(tester, path);

        // Resolves to a rendered screen.
        expect(
          find.byType(Scaffold),
          findsWidgets,
          reason: '"$path" did not resolve to a screen',
        );

        // No go_router error page for a defined route.
        expect(
          find.textContaining('no routes for location'),
          findsNothing,
          reason: '"$path" surfaced a go_router error page',
        );
      });
    }

    for (final path in _bottomNavPaths) {
      testWidgets('shell route "$path" exposes bottom navigation',
          (tester) async {
        await pumpAt(tester, path);
        expect(find.byType(AppBottomNav), findsOneWidget);
      });
    }

    for (final path in _nonShellPaths) {
      testWidgets('non-shell route "$path" has an AppBar back path',
          (tester) async {
        await pumpAt(tester, path);
        expect(
          find.byType(AppBar),
          findsOneWidget,
          reason: 'non-shell "$path" lacks a back affordance',
        );
      });
    }
  });
}
