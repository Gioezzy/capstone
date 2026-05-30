import 'package:capstone/core/error/app_exception.dart';
import 'package:capstone/core/widgets/app_bottom_nav.dart';
import 'package:capstone/core/widgets/async_value_view.dart';
import 'package:capstone/core/widgets/attribute_chip.dart';
import 'package:capstone/core/widgets/empty_state.dart';
import 'package:capstone/core/widgets/motif_card.dart';
import 'package:capstone/core/widgets/primary_button.dart';
import 'package:capstone/core/widgets/secondary_button.dart';
import 'package:capstone/core/widgets/section_header.dart';
import 'package:capstone/core/widgets/text_button_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Wraps a widget in MaterialApp/Scaffold for pumping.
Future<void> pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Center(child: child))),
  );
}

void main() {
  group('PrimaryButton', () {
    testWidgets('shows label when not loading', (tester) async {
      await pump(tester, const PrimaryButton(label: 'Generate'));
      expect(find.text('Generate'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('isLoading shows spinner and ignores taps', (tester) async {
      var tapped = false;
      await pump(
        tester,
        PrimaryButton(
          label: 'Generate',
          isLoading: true,
          onPressed: () => tapped = true,
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Generate'), findsNothing);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();
      expect(tapped, isFalse);
    });

    testWidgets('calls onPressed when tapped in normal state', (tester) async {
      var tapped = false;
      await pump(
        tester,
        PrimaryButton(label: 'Generate', onPressed: () => tapped = true),
      );
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('SecondaryButton', () {
    testWidgets('renders label and calls onPressed', (tester) async {
      var tapped = false;
      await pump(
        tester,
        SecondaryButton(label: 'Batal', onPressed: () => tapped = true),
      );
      expect(find.text('Batal'), findsOneWidget);
      await tester.tap(find.byType(SecondaryButton));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('danger variant still renders', (tester) async {
      await pump(tester, const SecondaryButton(label: 'Hapus', danger: true));
      expect(find.text('Hapus'), findsOneWidget);
      expect(find.byType(SecondaryButton), findsOneWidget);
    });
  });

  group('TextButtonLink', () {
    testWidgets('renders label and calls onPressed', (tester) async {
      var tapped = false;
      await pump(
        tester,
        TextButtonLink(label: 'Lihat Semua', onPressed: () => tapped = true),
      );
      expect(find.text('Lihat Semua'), findsOneWidget);
      await tester.tap(find.byType(TextButtonLink));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('AttributeChip', () {
    testWidgets('renders label when unselected and calls onTap', (tester) async {
      var tapped = false;
      await pump(
        tester,
        AttributeChip(
          label: 'Simetris',
          selected: false,
          onTap: () => tapped = true,
        ),
      );
      expect(find.text('Simetris'), findsOneWidget);
      await tester.tap(find.byType(AttributeChip));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('renders label when selected', (tester) async {
      await pump(
        tester,
        const AttributeChip(label: 'Padat', selected: true),
      );
      expect(find.text('Padat'), findsOneWidget);
    });
  });

  group('MotifCard', () {
    testWidgets('grid renders title and placeholder, calls onTap',
        (tester) async {
      var tapped = false;
      await pump(
        tester,
        SizedBox(
          width: 200,
          child: MotifCard.grid(
            title: 'Pucuk Rebung',
            onTap: () => tapped = true,
          ),
        ),
      );
      expect(find.text('Pucuk Rebung'), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
      await tester.tap(find.byType(MotifCard));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('list renders title and placeholder, calls onTap',
        (tester) async {
      var tapped = false;
      await pump(
        tester,
        SizedBox(
          width: 300,
          child: MotifCard.list(
            title: 'Tampuk Manggis',
            onTap: () => tapped = true,
          ),
        ),
      );
      expect(find.text('Tampuk Manggis'), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
      await tester.tap(find.byType(MotifCard));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('SectionHeader', () {
    testWidgets('renders title', (tester) async {
      await pump(tester, const SectionHeader(title: 'Riwayat Terakhir'));
      expect(find.text('Riwayat Terakhir'), findsOneWidget);
    });

    testWidgets('action label renders and tap calls onActionTap',
        (tester) async {
      var tapped = false;
      await pump(
        tester,
        SectionHeader(
          title: 'Riwayat Terakhir',
          actionLabel: 'Lihat Semua',
          onActionTap: () => tapped = true,
        ),
      );
      expect(find.text('Lihat Semua'), findsOneWidget);
      await tester.tap(find.text('Lihat Semua'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('AppBottomNav', () {
    testWidgets('renders 3 labels and reports tapped index', (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNav(
              currentIndex: 0,
              onTap: (i) => tappedIndex = i,
            ),
          ),
        ),
      );
      expect(find.text('Generate'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      await tester.tap(find.text('History'));
      await tester.pump();
      expect(tappedIndex, 1);
    });
  });

  group('EmptyState', () {
    testWidgets('renders message', (tester) async {
      await pump(tester, const EmptyState(message: 'Riwayat kosong'));
      expect(find.text('Riwayat kosong'), findsOneWidget);
    });

    testWidgets('action renders and tap calls onAction', (tester) async {
      var tapped = false;
      await pump(
        tester,
        EmptyState(
          message: 'Riwayat kosong',
          actionLabel: 'Mulai Generate',
          onAction: () => tapped = true,
        ),
      );
      expect(find.text('Mulai Generate'), findsOneWidget);
      await tester.tap(find.text('Mulai Generate'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('AsyncValueView', () {
    testWidgets('loading shows spinner and no data (exclusivity)',
        (tester) async {
      await pump(
        tester,
        AsyncValueView<List<String>>(
          value: const AsyncValue.loading(),
          data: (d) => Text('DATA ${d.length}'),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.textContaining('DATA'), findsNothing);
    });

    testWidgets('non-empty data shows data builder', (tester) async {
      await pump(
        tester,
        AsyncValueView<List<String>>(
          value: const AsyncValue.data(['a', 'b']),
          isEmpty: (d) => d.isEmpty,
          data: (d) => Text('DATA ${d.length}'),
        ),
      );
      expect(find.text('DATA 2'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('empty data shows empty state', (tester) async {
      await pump(
        tester,
        AsyncValueView<List<String>>(
          value: const AsyncValue.data([]),
          isEmpty: (d) => d.isEmpty,
          emptyBuilder: () => const EmptyState(message: 'kosong'),
          data: (d) => Text('DATA ${d.length}'),
        ),
      );
      expect(find.text('kosong'), findsOneWidget);
      expect(find.text('DATA 0'), findsNothing);
    });

    testWidgets('error shows message and retry button calls onRetry',
        (tester) async {
      var retried = false;
      await pump(
        tester,
        AsyncValueView<List<String>>(
          value: AsyncValue.error(
            const GenerationFailedException('Gagal generate'),
            StackTrace.current,
          ),
          data: (d) => Text('DATA ${d.length}'),
          onRetry: () => retried = true,
        ),
      );
      expect(find.text('Gagal generate'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
      await tester.tap(find.text('Coba Lagi'));
      await tester.pump();
      expect(retried, isTrue);
    });
  });
}
