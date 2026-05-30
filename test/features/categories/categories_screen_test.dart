import 'package:capstone/core/error/app_exception.dart';
import 'package:capstone/core/widgets/motif_card.dart';
import 'package:capstone/domain/models/models.dart';
import 'package:capstone/domain/repositories/motif_repository.dart';
import 'package:capstone/features/categories/presentation/categories_screen.dart';
import 'package:capstone/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Deterministic repo: zero latency, controlled categories or error.
class _FakeRepo implements MotifRepository {
  _FakeRepo({this.categories, this.error});

  final List<MotifCategory>? categories;
  final Object? error;

  @override
  Future<List<MotifCategory>> getCategories() async {
    if (error != null) throw error!;
    return categories ?? const [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not used in test');
}

// Builds a category with an asset previewImage (forces Image.asset, no network).
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

Widget _wrap(_FakeRepo repo) {
  return ProviderScope(
    overrides: [motifRepositoryProvider.overrideWithValue(repo)],
    child: const MaterialApp(home: CategoriesScreen()),
  );
}

void main() {
  group('CategoriesScreen', () {
    testWidgets('renders grid of categories from repository', (tester) async {
      // Tall surface so both grid rows lay out (GridView builds lazily).
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = _FakeRepo(categories: [
        _cat('cat-001', 'Pucuk Rebung'),
        _cat('cat-002', 'Bunga Cina'),
        _cat('cat-003', 'Siku Keluang'),
      ]);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      expect(find.text('Pucuk Rebung'), findsOneWidget);
      expect(find.text('Bunga Cina'), findsOneWidget);
      expect(find.text('Siku Keluang'), findsOneWidget);
      expect(find.byType(MotifCard), findsNWidgets(3));
    });

    testWidgets('search filters categories by name', (tester) async {
      final repo = _FakeRepo(categories: [
        _cat('cat-001', 'Pucuk Rebung'),
        _cat('cat-002', 'Bunga Cina'),
        _cat('cat-003', 'Siku Keluang'),
      ]);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'bunga');
      await tester.pumpAndSettle();

      expect(find.text('Bunga Cina'), findsOneWidget);
      expect(find.text('Pucuk Rebung'), findsNothing);
      expect(find.text('Siku Keluang'), findsNothing);
      expect(find.byType(MotifCard), findsOneWidget);
    });

    testWidgets('error state shows message and "Coba Lagi"', (tester) async {
      final repo = _FakeRepo(error: const NetworkException());
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      expect(find.text('Tidak ada koneksi internet'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
      expect(find.byType(MotifCard), findsNothing);
    });

    testWidgets('empty result shows "Motif tidak ditemukan"', (tester) async {
      final repo = _FakeRepo(categories: const []);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      expect(find.text('Motif tidak ditemukan'), findsOneWidget);
      expect(find.byType(MotifCard), findsNothing);
    });
  });
}
