import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../domain/repositories/motif_repository.dart';
import '../../../providers/repository_providers.dart';

// User feedback for the shown motif: 0 none, 1 like, -1 dislike.
final resultFeedbackProvider = StateProvider.autoDispose<int>((ref) => 0);

enum ResultActionStatus { idle, saving, saved, downloading, downloaded, failed }

// State for save/download actions on the result screen.
class ResultActionState {
  final ResultActionStatus status;
  final String? message;

  const ResultActionState({this.status = ResultActionStatus.idle, this.message});

  bool get isSaving => status == ResultActionStatus.saving;
  bool get isDownloading => status == ResultActionStatus.downloading;
}

// Handles "save to history" (UC-004) and "download" (UC-006) actions.
class ResultController extends StateNotifier<ResultActionState> {
  final MotifRepository _repo;

  ResultController(this._repo) : super(const ResultActionState());

  Future<bool> saveToHistory(String motifId) async {
    state = const ResultActionState(status: ResultActionStatus.saving);
    try {
      await _repo.saveToHistory(motifId);
      state = const ResultActionState(
        status: ResultActionStatus.saved,
        message: 'Tersimpan ke riwayat',
      );
      return true;
    } on AppException catch (e) {
      state = ResultActionState(
        status: ResultActionStatus.failed,
        message: _saveMessage(e),
      );
      return false;
    }
  }

  // Mock stage: no real bytes, so success means download info is reachable.
  Future<bool> download(String motifId) async {
    state = const ResultActionState(status: ResultActionStatus.downloading);
    try {
      await _repo.getDownloadInfo(motifId);
      state = const ResultActionState(
        status: ResultActionStatus.downloaded,
        message: 'Unduhan dimulai',
      );
      return true;
    } on AppException catch (e) {
      state = ResultActionState(
        status: ResultActionStatus.failed,
        message: _downloadMessage(e),
      );
      return false;
    }
  }

  String _saveMessage(AppException e) =>
      e is StorageException ? 'Penyimpanan penuh' : 'Gagal menyimpan';

  String _downloadMessage(AppException e) => switch (e) {
        PermissionDeniedException() => 'Unduhan memerlukan izin penyimpanan',
        DownloadFailedException() => 'Unduhan gagal',
        _ => 'Unduhan gagal',
      };
}

final resultControllerProvider =
    StateNotifierProvider.autoDispose<ResultController, ResultActionState>(
  (ref) => ResultController(ref.watch(motifRepositoryProvider)),
);
