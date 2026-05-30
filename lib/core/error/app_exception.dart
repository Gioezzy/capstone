// Sealed base for all domain errors.
sealed class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException([String message = 'Tidak ada koneksi internet'])
      : super(message);
}

class ServerUnavailableException extends AppException {
  const ServerUnavailableException([String message = 'Server tidak tersedia'])
      : super(message);
}

class GenerationFailedException extends AppException {
  const GenerationFailedException([String message = 'Gagal menghasilkan motif'])
      : super(message);
}

class NotFoundException extends AppException {
  const NotFoundException([String message = 'Data tidak tersedia'])
      : super(message);
}

class ImageLoadException extends AppException {
  const ImageLoadException([String message = 'Gagal memuat hasil motif'])
      : super(message);
}

class StorageException extends AppException {
  const StorageException([String message = 'Gagal menyimpan motif'])
      : super(message);
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException([
    String message = 'Izin penyimpanan diperlukan',
  ]) : super(message);
}

class DownloadFailedException extends AppException {
  const DownloadFailedException([String message = 'Unduhan gagal'])
      : super(message);
}

class UnknownException extends AppException {
  const UnknownException([String message = 'Terjadi kesalahan tak terduga'])
      : super(message);
}
