import 'dart:async';

import 'package:capstone/core/error/app_exception.dart';
import 'package:capstone/core/router/routes.dart';
import 'package:capstone/data/mock/mock_data.dart';
import 'package:capstone/domain/models/models.dart';
import 'package:capstone/domain/repositories/motif_repository.dart';
import 'package:capstone/features/generating/presentation/generating_controller.dart';
import 'package:capstone/features/generating/presentation/generating_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// Deterministic repo controlling the generate outcome.
// - pending: never completes -> state stays Loading.
// - failFirst: throw once then succeed (for retry).
// - result/error: terminal success or failure.
class _FakeRepo implements MotifRepository {
  _FakeRepo({this.result, this.error, this.pending = false, this.failFirst = false});

  final GenerateResult? result;
  final Object? error;
  final bool pending;
  bool failFirst;

  @override
  Future<GenerateResult> generateMotif(GenerateRequest request) {
    if (pending) return Completer<GenerateResult>().future;
    if (failFirst) {
      failFirst = false;
      return Future.error(error ?? const NetworkException());
    }
    if (result != null) return Future.value(result!);
    return Future.error(error ?? const NetworkException());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not used in test');
}

const _request = GenerateRequest(
  categoryId: 'cat-001',
  resolution: Resolution.px128,
  conditions: {},
);

GenerateResult _result() => GenerateResult(
      motif: MockData.motifFor('cat-001', 7),
      usedSeed: 7,
      historyId: 'gen-test',
    );

// Override the controller so the fake repo drives state with zero step delay.
List<Override> _overrides(_FakeRepo repo) => [
      generatingControllerProvider.overrideWith(
        (ref) => GeneratingController(repo: repo, stepDelay: Duration.zero),
      ),
    ];

// Wrap without router: loading/error states never navigate.
Widget _wrapHome(_FakeRepo repo) => ProviderScope(
      overrides: _overrides(repo),
      child: const MaterialApp(home: GeneratingScreen(request: _request)),
    );

class _Marker extends StatelessWidget {
  const _Marker(this.label);
  final String label;
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(label)));
}

GoRouter _router({String initialLocation = Routes.generatingPath}) => GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: Routes.configurePath,
          builder: (_, __) => const _Marker('CONFIG'),
        ),
        GoRoute(
          path: Routes.generatingPath,
          builder: (_, __) => const GeneratingScreen(request: _request),
        ),
        GoRoute(
          path: Routes.resultPath,
          builder: (_, __) => const _Marker('RESULT-OK'),
        ),
      ],
    );

Widget _wrapRouter(_FakeRepo repo, GoRouter router) => ProviderScope(
      overrides: _overrides(repo),
      child: MaterialApp.router(routerConfig: router),
    );

void main() {
  group('GeneratingScreen', () {
    testWidgets('loading: shows title, system log panel and progress',
        (tester) async {
      // Never-completing generate keeps the screen in Loading.
      await tester.pumpWidget(_wrapHome(_FakeRepo(pending: true)));
      await tester.pumpAndSettle();

      expect(find.text('Sedang Menghasilkan Motif Baru'), findsOneWidget);
      expect(find.text('PROSES SYSTEM'), findsOneWidget);
      expect(find.text('Generasi Motif'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.text('Batalkan Proses'), findsOneWidget);
    });

    testWidgets('error: shows message and "Coba Lagi"', (tester) async {
      await tester.pumpWidget(_wrapHome(_FakeRepo(error: const NetworkException())));
      await tester.pumpAndSettle();

      expect(find.text('Generasi Gagal'), findsOneWidget);
      expect(find.text('Tidak ada koneksi internet'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('retry: tapping "Coba Lagi" recovers and navigates to result',
        (tester) async {
      final repo = _FakeRepo(failFirst: true, result: _result());
      await tester.pumpWidget(_wrapRouter(repo, _router()));
      await tester.pumpAndSettle();

      // First attempt failed.
      expect(find.text('Coba Lagi'), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();

      // Second attempt succeeds and replaces with the result route.
      expect(find.text('RESULT-OK'), findsOneWidget);
    });

    testWidgets('success: navigates to result via pushReplacement',
        (tester) async {
      await tester.pumpWidget(_wrapRouter(_FakeRepo(result: _result()), _router()));
      await tester.pumpAndSettle();

      expect(find.text('RESULT-OK'), findsOneWidget);
      expect(find.byType(GeneratingScreen), findsNothing);
    });

    testWidgets('cancel: tapping "Batalkan Proses" pops back to Configure',
        (tester) async {
      final router = _router(initialLocation: Routes.configurePath);
      await tester.pumpWidget(_wrapRouter(_FakeRepo(pending: true), router));
      await tester.pumpAndSettle();

      // Push Generating on top of Configure so cancel can pop back.
      router.push(Routes.generatingPath);
      await tester.pumpAndSettle();
      expect(find.byType(GeneratingScreen), findsOneWidget);

      await tester.tap(find.text('Batalkan Proses'));
      await tester.pumpAndSettle();

      expect(find.text('CONFIG'), findsOneWidget);
      expect(find.byType(GeneratingScreen), findsNothing);
    });
  });
}
