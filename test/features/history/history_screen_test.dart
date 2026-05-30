import 'package:capstone/core/error/app_exception.dart';
import 'package:capstone/core/widgets/motif_card.dart';
import 'package:capstone/domain/models/models.dart';
import 'package:capstone/domain/repositories/motif_repository.dart';
import 'package:capstone/features/history/presentation/history_controller.dart';
import 'package:capstone/features/history/presentation/history_screen.dart';
import 'package:capstone/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Deterministic repo: zero latency, controlled histories or error.
// getCategories feeds the Filter menu so it never hits noSuchMethod.
class _FakeRepo implements MotifRepository {
  _FakeRepo({this.histories, this.error});

  final List<GenerateHistory>? histories;
  final Object? error;

  @override
  Future<List<GenerateHistory>> getHistories({
    int page = 1,
    int pageSize = 20,
    String? categoryId,
    HistorySort sort = HistorySort.newest,
  }) async {
    if (error != null) throw error!;
    return histories ?? const [];
  }

  @override
  Future<List<MotifCategory>> getCategories() async => [
        _cat('cat-001', 'Pucuk Rebung'),
        _cat('cat-002', 'Bunga Cina'),
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not used in test');
}

// Category with an asset previewImage (no network).
MotifCategory _cat(String id, String name) {
  final now = DateTime(2023, 10, 24);
  return MotifCategory(
    id: id,
    name: name,
    description: 'desc $name',
    previewImage: 'assets/$id.png',
    createdAt: now,
    updatedAt: now,
  );
}

// History with an asset image (no network); fields overridable per test.
GenerateHistory _history({
  String id = 'gen-042',
  String categoryId = 'cat-001',
  String categoryName = 'Pucuk Rebung',
  MotifTag tag = MotifTag.geometric,
}) {
  return GenerateHistory(
    id: id,
    categoryId: categoryId,
    generatedImage: 'assets/x.png',
    createdAt: DateTime(2023, 10, 24, 14, 30),
    categoryName: categoryName,
    tag: tag,
  );
}

Widget _wrap(_FakeRepo repo) {
  return ProviderScope(
    overrides: [motifRepositoryProvider.overrideWithValue(repo)],
    child: const MaterialApp(home: HistoryScreen()),
  );
}

// Tall surface so the list lays out without overflow.
void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('HistoryScreen', () {
    testWidgets('renders list of history cards with sort & filter controls',
        (tester) async {
      _useTallSurface(tester);

      final repo = _FakeRepo(histories: [
        _history(),
        _history(id: 'gen-043', categoryName: 'Bunga Cina'),
        _history(id: 'gen-044', categoryName: 'Siku Keluang'),
      ]);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      expect(find.text('Generated Motifs'), findsOneWidget);
      expect(find.byType(MotifCard), findsNWidgets(3));
      expect(find.text('Pucuk Rebung'), findsOneWidget);
      expect(find.text('Bunga Cina'), findsOneWidget);
      expect(find.text('Siku Keluang'), findsOneWidget);

      expect(find.text('Sort'), findsOneWidget);
      expect(find.text('Filter'), findsOneWidget);
    });

    testWidgets('empty: shows "Belum ada motif" with "Mulai Generate" CTA',
        (tester) async {
      final repo = _FakeRepo(histories: const []);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada motif'), findsOneWidget);
      expect(find.text('Mulai Generate'), findsOneWidget);
      expect(find.byType(MotifCard), findsNothing);
    });

    testWidgets('error: shows "Muat Ulang" retry action', (tester) async {
      final repo = _FakeRepo(error: const NetworkException());
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      expect(find.text('Muat Ulang'), findsOneWidget);
      expect(find.byType(MotifCard), findsNothing);
    });

    testWidgets('sort toggle flips historySortProvider newest -> oldest',
        (tester) async {
      _useTallSurface(tester);

      final repo = _FakeRepo(histories: [_history()]);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(HistoryScreen)),
      );
      expect(container.read(historySortProvider), HistorySort.newest);

      await tester.tap(find.text('Sort'));
      await tester.pumpAndSettle();

      expect(container.read(historySortProvider), HistorySort.oldest);
    });
  });
}
