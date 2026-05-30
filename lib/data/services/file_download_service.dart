import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/error/app_exception.dart';
import '../../domain/models/motif_download.dart';

// Asks for storage permission. Abstracted so tests can fake it.
abstract interface class PermissionGate {
  Future<bool> ensureStoragePermission();
}

// Writes bytes to device storage, returning the saved file path.
abstract interface class FileSink {
  Future<String> writeBytes(String fileName, List<int> bytes);
}

// Production gate backed by permission_handler.
class DefaultPermissionGate implements PermissionGate {
  const DefaultPermissionGate();

  @override
  Future<bool> ensureStoragePermission() async {
    final status = await Permission.storage.status;
    if (status.isGranted) return true;
    final result = await Permission.storage.request();
    return result.isGranted;
  }
}

// Production sink backed by path_provider.
class PathProviderFileSink implements FileSink {
  const PathProviderFileSink();

  @override
  Future<String> writeBytes(String fileName, List<int> bytes) async {
    final dir = await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}

// Saves PNG motif bytes to the device (UC-006, UC-004).
class FileDownloadService {
  final PermissionGate _permissionGate;
  final FileSink _fileSink;

  FileDownloadService({PermissionGate? permissionGate, FileSink? fileSink})
      : _permissionGate = permissionGate ?? const DefaultPermissionGate(),
        _fileSink = fileSink ?? const PathProviderFileSink();

  // Throws PermissionDeniedException when storage access is refused,
  // DownloadFailedException when writing the file fails.
  Future<MotifDownload> download({
    required String motifId,
    required String fileName,
    required List<int> bytes,
  }) async {
    final granted = await _permissionGate.ensureStoragePermission();
    if (!granted) throw const PermissionDeniedException();
    try {
      final path = await _fileSink.writeBytes(fileName, bytes);
      return MotifDownload(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        generatedMotifId: motifId,
        fileName: fileName,
        filePath: path,
        downloadedAt: DateTime.now(),
      );
    } catch (_) {
      throw const DownloadFailedException();
    }
  }

  // Alias for download.
  Future<MotifDownload> saveBytes({
    required String motifId,
    required String fileName,
    required List<int> bytes,
  }) =>
      download(motifId: motifId, fileName: fileName, bytes: bytes);
}
