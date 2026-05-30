import 'dart:async';

import 'package:capstone/core/router/routes.dart';
import 'package:capstone/core/widgets/motif_card.dart';
import 'package:capstone/domain/models/models.dart';
import 'package:capstone/domain/repositories/motif_repository.dart';
import 'package:capstone/features/home/presentation/home_screen.dart';
import 'package:capstone/features/splash/presentation/splash_controller.dart';
import 'package:capstone/features/splash/presentation/splash_screen.dart';
import 'package:capstone/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// Minimal router: splash -> home destination ('HOME-OK' marker).
GoRouter _splashRouter() => GoRouter(
      initialLocation: Routes.splashPath,
      routes: [
        GoRoute(
          path: Routes.splashPath,
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: Routes.homePath,
          builder: (_, __) => const Text(
            'HOME-OK',
            textDirection: TextDirection.ltr,
          ),
        ),
      ],
    );

// Deterministic repo: controlled getHistories (list / pending future).
class _FakeRepo implements MotifRepository {
  _FakeRepo({this.histories, this.historiesFuture});

  final List<GenerateHistory>? histories;
  final Future<List<GenerateHistory>>? historiesFuture;

  @override
  Future<List<GenerateHistory>> getHistories({
    int page = 1,
    int pageSize = 20,
    String? categoryId,
    HistorySort sort = HistorySort.newest,
  }) {
    if (historiesFuture != null) return historiesFuture!;
    return Future.value(histories ?? const []);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not used in test');
}

// History with asset image to avoid any network fetch.
GenerateHistory _history(String id, String categoryName) => GenerateHistory(
      id: id,
      categoryId: 'cat-001',
      generatedImage: 'assets/$id.png',
      createdAt: DateTime(2023, 10, 24),
      categoryName: categoryName,
    );

Widget _wrapHome(_FakeRepo repo) => ProviderScope(
      overrides: [motifRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: HomeScreen()),
    );

void main() {
  group('SplashScreen', () {
    testWidgets('shows title and "INITIALIZING MODEL" while initializing',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            splashControllerProvider.overrideWith(
              (ref) => SplashController(delay: const Duration(milliseconds: 10)),
            ),
          ],
          child: MaterialApp.router(routerConfig: _splashRouter()),
        ),
      );
      await tester.pump(); // build splash, timer not yet fired

      expect(find.text('Songket Gen-AI'), findsOneWidget);
      expect(find.text('INITIALIZING MODEL'), findsOneWidget);
      expect(find.text('HOME-OK'), findsNothing);

      // Drain the timer so no pending timer remains.
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pumpAndSettle();
    });

    testWidgets('auto-navigates to Home when status becomes ready',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            splashControllerProvider.overrideWith(
              (ref) => SplashController(delay: const Duration(milliseconds: 10)),
            ),
          ],
          child: MaterialApp.router(routerConfig: _splashRouter()),
        ),
      );
      await tester.pump(); // splash shown
      expect(find.text('Songket Gen-AI'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 20)); // fire timer -> ready
      await tester.pumpAndSettle(); // complete navigation

      expect(find.text('HOME-OK'), findsOneWidget);
      expect(find.text('Songket Gen-AI'), findsNothing);
    });
  });

  group('HomeScreen', () {
    testWidgets('success: shows banner, CTA, and recent history cards',
        (tester) async {
      // Tall surface so the grid lays its rows out.
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = _FakeRepo(histories: [
        _history('gen-042', 'Pucuk Rebung'),
        _history('gen-043', 'Bunga Cina'),
      ]);
      await tester.pumpWidget(_wrapHome(repo));
      await tester.pumpAndSettle();

      expect(find.text('Selamat Datang'), findsOneWidget);
      expect(find.text('Mulai Generate'), findsOneWidget);
      expect(find.text('Pucuk Rebung'), findsOneWidget);
      expect(find.text('Bunga Cina'), findsOneWidget);
      expect(find.byType(MotifCard), findsNWidgets(2));
    });

    testWidgets('empty: shows "Belum ada motif" with "Mulai Generate" CTA',
        (tester) async {
      final repo = _FakeRepo(histories: const []);
      await tester.pumpWidget(_wrapHome(repo));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada motif'), findsOneWidget);
      expect(find.text('Mulai Generate'), findsWidgets);
      expect(find.byType(MotifCard), findsNothing);
    });

    testWidgets('loading: shows a progress indicator before data resolves',
        (tester) async {
      // Never-completing future keeps the provider in the loading state.
      final repo = _FakeRepo(
        historiesFuture: Completer<List<GenerateHistory>>().future,
      );
      await tester.pumpWidget(_wrapHome(repo));
      await tester.pump(); // first frame: still loading

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(MotifCard), findsNothing);
    });
  });
}
