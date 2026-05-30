import 'package:capstone/core/error/app_exception.dart';
import 'package:capstone/data/services/file_download_service.dart';
import 'package:flutter_test/flutter_test.dart';

// Stub gate: returns a fixed grant result.
class _FakeGate implements PermissionGate {
  _FakeGate(this.granted);
  final bool granted;

  @override
  Future<bool> ensureStoragePermission() async => granted;
}

// Stub sink: records calls; either returns a path or throws.
class _FakeSink implements FileSink {
  _FakeSink({this.returnPath, this.fail = false});
  final String? returnPath;
  final bool fail;
  bool called = false;
  String? lastFileName;
  List<int>? lastBytes;

  @override
  Future<String> writeBytes(String fileName, List<int> bytes) async {
    called = true;
    lastFileName = fileName;
    lastBytes = bytes;
    if (fail) throw Exception('write failed');
    return returnPath!;
  }
}

void main() {
  const motifId = 'mtf-101';
  const fileName = 'mtf-101.png';
  final bytes = [1, 2, 3, 4];

  group('FileDownloadService.download', () {
    test('success path returns MotifDownload from sink result', () async {
      final sink = _FakeSink(returnPath: '/storage/mtf-101.png');
      final service = FileDownloadService(
        permissionGate: _FakeGate(true),
        fileSink: sink,
      );

      final result = await service.download(
        motifId: motifId,
        fileName: fileName,
        bytes: bytes,
      );

      expect(result.generatedMotifId, motifId);
      expect(result.fileName, fileName);
      expect(result.filePath, '/storage/mtf-101.png');
      expect(result.downloadedAt, isNotNull);
      expect(sink.called, isTrue);
      expect(sink.lastFileName, fileName);
      expect(sink.lastBytes, bytes);
    });

    test('throws PermissionDeniedException and skips sink when denied',
        () async {
      final sink = _FakeSink(returnPath: '/storage/mtf-101.png');
      final service = FileDownloadService(
        permissionGate: _FakeGate(false),
        fileSink: sink,
      );

      await expectLater(
        service.download(motifId: motifId, fileName: fileName, bytes: bytes),
        throwsA(isA<PermissionDeniedException>()),
      );
      expect(sink.called, isFalse);
    });

    test('throws DownloadFailedException when write fails', () async {
      final sink = _FakeSink(fail: true);
      final service = FileDownloadService(
        permissionGate: _FakeGate(true),
        fileSink: sink,
      );

      await expectLater(
        service.download(motifId: motifId, fileName: fileName, bytes: bytes),
        throwsA(isA<DownloadFailedException>()),
      );
    });
  });

  group('FileDownloadService.saveBytes', () {
    test('behaves like download on success path', () async {
      final sink = _FakeSink(returnPath: '/storage/mtf-101.png');
      final service = FileDownloadService(
        permissionGate: _FakeGate(true),
        fileSink: sink,
      );

      final result = await service.saveBytes(
        motifId: motifId,
        fileName: fileName,
        bytes: bytes,
      );

      expect(result.generatedMotifId, motifId);
      expect(result.fileName, fileName);
      expect(result.filePath, '/storage/mtf-101.png');
      expect(sink.called, isTrue);
    });
  });
}
