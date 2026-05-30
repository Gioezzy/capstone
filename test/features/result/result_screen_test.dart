import 'package:capstone/core/error/app_exception.dart';
import 'package:capstone/core/router/routes.dart';
import 'package:capstone/domain/models/models.dart';
import 'package:capstone/domain/repositories/motif_repository.dart';
import 'package:capstone/features/result/presentation/result_screen.dart';
import 'package:capstone/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// Deterministic repo: controlled save/download success or error.
class _FakeRepo implements MotifRepository {
  _FakeRepo({this.saveError, this.downloadError});

  final Object? saveError;
  final Object? downloadError;

  @override
  Future<GenerateHistory> saveToHistory(String motifId) async {
    if (saveError != null) throw saveError!;
    return GenerateHistory(
      id: 'gen-1',
      categoryId: 'cat-001',
      generatedImage: 'assets/x.png',
      createdAt: DateTime(2023, 10, 24),
    );
  }

  @override
  Future<MotifImage> getDownloadInfo(String motifId) async {
    if (downloadError != null) throw downloadError!;
    return MotifImage(
      id: 'img-1',
      generatedMotifId: motifId,
      url: 'assets/x.png',
      fileName: 'x.png',
      createdAt: DateTime(2023, 10, 24),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not used in test');
}

// Asset imageUrl forces Image.asset (no network); '' triggers empty state.
GenerateResult _result({String imageUrl = 'assets/x.png'}) {
  final motif = GeneratedMotif(
    id: 'mtf-1',
    historyId: 'gen-1',
    imageUrl: imageUrl,
    categoryId: 'cat-001',
    createdAt: DateTime(2023, 10, 24),
    title: 'Motif Baru 01',
  );
  return GenerateResult(motif: motif, usedSeed: 42, historyId: 'gen-1');
}

// Minimal router: '/result' hosts the screen, '/history' marks navigation.
GoRouter _router(GenerateResult result) => GoRouter(
      initialLocation: Routes.resultPath,
      routes: [
        GoRoute(
          path: Routes.resultPath,
          builder: (_, __) => ResultScreen(result: result),
        ),
        GoRoute(
          path: Routes.historyPath,
          builder: (_, __) =>
              const Text('HISTORY-OK', textDirection: TextDirection.ltr),
        ),
        GoRoute(
          path: Routes.categoriesPath,
          builder: (_, __) =>
              const Text('CATEGORIES-OK', textDirection: TextDirection.ltr),
        ),
      ],
    );

Widget _wrap(_FakeRepo repo, GenerateResult result) => ProviderScope(
      overrides: [motifRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp.router(routerConfig: _router(result)),
    );

// Tall surface so off-screen buttons become hit-testable for taps.
void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('ResultScreen', () {
    testWidgets('success: renders title, motif title, category and actions',
        (tester) async {
      await tester.pumpWidget(_wrap(_FakeRepo(), _result()));
      await tester.pumpAndSettle();

      expect(find.text('Hasil Generasi'), findsOneWidget);
      expect(find.text('Motif Baru 01'), findsOneWidget);
      expect(find.text('Kategori: cat-001'), findsOneWidget);

      expect(find.text('Simpan ke Riwayat'), findsOneWidget);
      expect(find.text('Unduh Motif (PNG)'), findsOneWidget);
      expect(find.text('Generate Lagi'), findsOneWidget);

      expect(find.byIcon(Icons.thumb_up_outlined), findsOneWidget);
      expect(find.byIcon(Icons.thumb_down_outlined), findsOneWidget);
    });

    testWidgets('save: shows confirmation snackbar then navigates to history',
        (tester) async {
      _useTallSurface(tester);

      await tester.pumpWidget(_wrap(_FakeRepo(), _result()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan ke Riwayat'));
      await tester.pump(); // run save future, show snackbar, start navigation

      expect(find.text('Tersimpan ke riwayat'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('HISTORY-OK'), findsOneWidget);

      // Drain the snackbar auto-dismiss timer to avoid a pending timer.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('save failure: shows error message and stays on result',
        (tester) async {
      _useTallSurface(tester);

      final repo = _FakeRepo(saveError: const StorageException());
      await tester.pumpWidget(_wrap(repo, _result()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan ke Riwayat'));
      await tester.pump();

      expect(find.text('Penyimpanan penuh'), findsOneWidget);
      expect(find.text('HISTORY-OK'), findsNothing);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('download failure: shows error message snackbar',
        (tester) async {
      _useTallSurface(tester);

      final repo = _FakeRepo(downloadError: const DownloadFailedException());
      await tester.pumpWidget(_wrap(repo, _result()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unduh Motif (PNG)'));
      await tester.pump();

      expect(find.text('Unduhan gagal'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('image failure: shows broken_image placeholder',
        (tester) async {
      await tester.pumpWidget(_wrap(_FakeRepo(), _result()));
      await tester.pumpAndSettle();

      // Missing asset 'assets/x.png' triggers the errorBuilder fallback.
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });

    testWidgets('empty: shows "Data tidak tersedia" when imageUrl is empty',
        (tester) async {
      await tester.pumpWidget(_wrap(_FakeRepo(), _result(imageUrl: '')));
      await tester.pumpAndSettle();

      expect(find.text('Data tidak tersedia'), findsOneWidget);
      expect(find.text('Simpan ke Riwayat'), findsNothing);
    });

    testWidgets('like toggle: tapping thumb_up switches to filled icon',
        (tester) async {
      _useTallSurface(tester);

      await tester.pumpWidget(_wrap(_FakeRepo(), _result()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.thumb_up_outlined), findsOneWidget);
      expect(find.byIcon(Icons.thumb_up), findsNothing);

      await tester.tap(find.byIcon(Icons.thumb_up_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
      expect(find.byIcon(Icons.thumb_up_outlined), findsNothing);
    });
  });
}
