import 'package:capstone/core/error/app_exception.dart';
import 'package:capstone/core/router/routes.dart';
import 'package:capstone/domain/models/models.dart';
import 'package:capstone/domain/repositories/motif_repository.dart';
import 'package:capstone/features/history_detail/presentation/history_detail_screen.dart';
import 'package:capstone/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// Deterministic repo: controlled getMotif/deleteHistory; records deletion.
class _FakeRepo implements MotifRepository {
  _FakeRepo({this.motif, this.getError, this.deleteError});

  final GeneratedMotif? motif;
  final Object? getError;
  final Object? deleteError;
  bool deleted = false;

  @override
  Future<GeneratedMotif> getMotif(String id) async {
    if (getError != null) throw getError!;
    return motif!;
  }

  @override
  Future<void> deleteHistory(String id) async {
    if (deleteError != null) throw deleteError!;
    deleted = true;
  }

  // Invalidated after delete; return empty to avoid recompute surprises.
  @override
  Future<List<GenerateHistory>> getHistories({
    int page = 1,
    int pageSize = 20,
    String? categoryId,
    HistorySort sort = HistorySort.newest,
  }) async =>
      const [];

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not used in test');
}

// Asset imageUrl forces Image.asset (no network in tests).
GeneratedMotif _motif() => GeneratedMotif(
      id: 'mtf-101',
      historyId: 'gen-042',
      imageUrl: 'assets/x.png',
      categoryId: 'cat-001',
      createdAt: DateTime(2023, 10, 24, 14, 30),
      title: 'Songket Pucuk Rebung',
      baseModel: 'Tradisional Nusantara v2',
      complexity: 0.85,
      primaryColor: 'Monochrome',
      iterations: 50,
    );

// Minimal router: detail hosts the screen, '/history' marks navigation.
GoRouter _router(String location) => GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: Routes.historyDetailPath,
          builder: (_, s) =>
              HistoryDetailScreen(motifId: s.pathParameters['id']!),
        ),
        GoRoute(
          path: Routes.historyPath,
          builder: (_, __) =>
              const Text('HISTORY-OK', textDirection: TextDirection.ltr),
        ),
      ],
    );

Widget _wrap(_FakeRepo repo, String location) => ProviderScope(
      overrides: [motifRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp.router(routerConfig: _router(location)),
    );

// Tall surface so off-screen buttons become hit-testable for taps.
void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('HistoryDetailScreen', () {
    testWidgets('renders metadata when getMotif succeeds', (tester) async {
      final repo = _FakeRepo(motif: _motif());
      await tester.pumpWidget(_wrap(repo, '/history/gen-042'));
      await tester.pumpAndSettle();

      expect(find.text('Songket Pucuk Rebung'), findsOneWidget);
      expect(find.text('Songket'), findsOneWidget); // tag

      // Labels are rendered uppercase by _MetaItem.
      expect(find.text('MODEL DASAR'), findsOneWidget);
      expect(find.text('Tradisional Nusantara v2'), findsOneWidget);
      expect(find.text('KOMPLEKSITAS'), findsOneWidget);
      expect(find.textContaining('0.85'), findsOneWidget);
      expect(find.text('WARNA UTAMA'), findsOneWidget);
      expect(find.text('Monochrome'), findsOneWidget);
      expect(find.text('ITERASI'), findsOneWidget);
      expect(find.text('50 Langkah'), findsOneWidget);

      expect(find.text('Unduh Lagi (PNG)'), findsOneWidget);
      expect(find.text('Hapus dari Riwayat'), findsOneWidget);
    });

    testWidgets('delete confirms, deletes and navigates to history',
        (tester) async {
      _useTallSurface(tester);

      final repo = _FakeRepo(motif: _motif());
      await tester.pumpWidget(_wrap(repo, '/history/gen-042'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hapus dari Riwayat'));
      await tester.pumpAndSettle();
      expect(find.text('Hapus dari Riwayat?'), findsOneWidget); // dialog

      await tester.tap(find.text('Hapus')); // confirm
      await tester.pumpAndSettle();

      expect(repo.deleted, isTrue);
      expect(find.text('HISTORY-OK'), findsOneWidget);

      // Drain the snackbar auto-dismiss timer to avoid a pending timer.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('shows empty state when motif is not found', (tester) async {
      final repo = _FakeRepo(getError: const NotFoundException());
      await tester.pumpWidget(_wrap(repo, '/history/unknown-zzz'));
      await tester.pumpAndSettle();

      expect(find.text('Data tidak tersedia'), findsOneWidget);
      expect(find.text('Unduh Lagi (PNG)'), findsNothing);
    });

    testWidgets('delete failure shows error and stays on screen',
        (tester) async {
      _useTallSurface(tester);

      final repo = _FakeRepo(
        motif: _motif(),
        deleteError: const ServerUnavailableException(),
      );
      await tester.pumpWidget(_wrap(repo, '/history/gen-042'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hapus dari Riwayat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus')); // confirm
      await tester.pumpAndSettle();

      expect(repo.deleted, isFalse);
      expect(find.text('HISTORY-OK'), findsNothing);
      expect(find.text('Server tidak tersedia'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });
  });
}
