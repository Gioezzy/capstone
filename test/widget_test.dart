import 'package:capstone/app.dart';
import 'package:capstone/features/home/presentation/home_screen.dart';
import 'package:capstone/features/splash/presentation/splash_screen.dart';
import 'package:capstone/providers/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App boots into splash then auto-navigates to Home',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const SongketApp(),
      ),
    );
    await tester.pump(); // build splash

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Songket Gen-AI'), findsOneWidget);

    // Fire the splash timer (2s) and resolve mock latency to land on Home.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
  });
}
