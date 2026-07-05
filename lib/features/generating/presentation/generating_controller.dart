import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../domain/models/generate_request.dart';
import '../../../domain/models/generate_result.dart';
import '../../../domain/repositories/motif_repository.dart';
import '../../../providers/repository_providers.dart';

// Sealed state for the generate flow. Valid transitions are enforced by the
// controller: Idle->Loading, Loading->{Success,Error,Cancelled},
// Error->Loading, Cancelled->Idle.
sealed class GenerateState {
  const GenerateState();
}

class GenerateIdle extends GenerateState {
  const GenerateIdle();

  @override
  bool operator ==(Object other) => other is GenerateIdle;

  @override
  int get hashCode => 0;
}

class GenerateLoading extends GenerateState {
  final double progress; // 0.0..1.0, never decreasing
  final List<String> logs;

  const GenerateLoading({this.progress = 0.0, this.logs = const []});

  @override
  bool operator ==(Object other) =>
      other is GenerateLoading &&
      other.progress == progress &&
      _listEquals(other.logs, logs);

  @override
  int get hashCode => Object.hash(progress, Object.hashAll(logs));
}

class GenerateSuccess extends GenerateState {
  final GenerateResult result;

  const GenerateSuccess(this.result);

  @override
  bool operator ==(Object other) =>
      other is GenerateSuccess && other.result == result;

  @override
  int get hashCode => result.hashCode;
}

class GenerateError extends GenerateState {
  final AppException error;

  const GenerateError(this.error);

  @override
  bool operator ==(Object other) =>
      other is GenerateError && other.error == error;

  @override
  int get hashCode => error.hashCode;
}

class GenerateCancelled extends GenerateState {
  const GenerateCancelled();

  @override
  bool operator ==(Object other) => other is GenerateCancelled;

  @override
  int get hashCode => 1;
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

// Simulated progress steps (backend is mocked). Each step's progress is
// strictly increasing within [0, 1); success emits the final 1.0.
const List<(double, String)> _progressSteps = [
  (0.0, 'Menginisialisasi ruang laten GAN...'),
  (0.25, 'Mengekstraksi fitur motif tradisional...'),
  (0.5, 'Melatih Discriminator... (Epoch 42/100)'),
  (0.75, 'Optimasi fungsi loss generator...'),
];

class GeneratingController extends StateNotifier<GenerateState> {
  final MotifRepository _repo;
  final Duration _stepDelay;

  bool _cancelled = false;
  double _lastProgress = 0.0;
  List<String> _logs = const [];

  GeneratingController({
    required MotifRepository repo,
    Duration stepDelay = const Duration(milliseconds: 120),
  })  : _repo = repo,
        _stepDelay = stepDelay,
        super(const GenerateIdle());

  Future<void> start(GenerateRequest request) async {
    // Ignore re-entrant start while already running.
    if (state is GenerateLoading) return;


    _cancelled = false;
    _lastProgress = 0.0;
    _logs = const [];

    // Idle/Error/Cancelled -> Loading.
    _emitLoading(_progressSteps.first.$1, _progressSteps.first.$2);

    for (final step in _progressSteps.skip(1)) {
      await Future<void>.delayed(_stepDelay);
      if (_cancelled) {
        state = const GenerateCancelled();
        return;
      }
      _emitLoading(step.$1, step.$2);
    }

    try {
      final result = await _repo.generateMotif(request);
      
      if (_cancelled) {
        state = const GenerateCancelled();
        return;
      }
      
      
      _emitLoading(1.0, 'Motif berhasil dihasilkan.');
      state = GenerateSuccess(result);
    } on AppException catch (e) {
      if (_cancelled) {
        state = const GenerateCancelled();
        return;
      }
      state = GenerateError(e);
    } catch (e) {
      
      if (_cancelled) {
        state = const GenerateCancelled();
        return;
      }
      // Keep the real error visible while integrating the API backend.
      // This avoids hiding JSON parsing or routing issues behind a generic UI.
      state = GenerateError(UnknownException(e.toString()));
    }
  }

  // Loading -> Cancelled.
  void cancel() {
    _cancelled = true;
    if (state is GenerateLoading) state = const GenerateCancelled();
  }

  // Cancelled/Error -> Idle.
  void reset() {
    if (state is GenerateCancelled || state is GenerateError) {
      state = const GenerateIdle();
    }
  }

  // Error -> Loading (via start).
  Future<void> retry(GenerateRequest request) async {
    if (state is GenerateError) await start(request);
  }

  // Emit a Loading state with monotonic, clamped progress and accumulated logs.
  void _emitLoading(double progress, String log) {
    final clamped = progress.clamp(_lastProgress, 1.0);
    _lastProgress = clamped;
    _logs = [..._logs, log];
    state = GenerateLoading(progress: clamped, logs: _logs);
  }
}

final generatingControllerProvider =
    StateNotifierProvider.autoDispose<GeneratingController, GenerateState>(
  (ref) => GeneratingController(repo: ref.watch(motifRepositoryProvider)),
);
