// motif_downloads: a record of a motif downloaded to the device.
class MotifDownload {
  final String id;
  final String generatedMotifId;
  final String fileName;
  final String filePath;
  final DateTime downloadedAt;

  const MotifDownload({
    required this.id,
    required this.generatedMotifId,
    required this.fileName,
    required this.filePath,
    required this.downloadedAt,
  });

  factory MotifDownload.fromJson(Map<String, dynamic> json) => MotifDownload(
        id: json['id'] as String,
        generatedMotifId: json['generated_motif_id'] as String,
        fileName: json['file_name'] as String,
        filePath: json['file_path'] as String,
        downloadedAt: DateTime.parse(json['downloaded_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'generated_motif_id': generatedMotifId,
        'file_name': fileName,
        'file_path': filePath,
        'downloaded_at': downloadedAt.toIso8601String(),
      };

  MotifDownload copyWith({
    String? id,
    String? generatedMotifId,
    String? fileName,
    String? filePath,
    DateTime? downloadedAt,
  }) =>
      MotifDownload(
        id: id ?? this.id,
        generatedMotifId: generatedMotifId ?? this.generatedMotifId,
        fileName: fileName ?? this.fileName,
        filePath: filePath ?? this.filePath,
        downloadedAt: downloadedAt ?? this.downloadedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MotifDownload &&
          other.id == id &&
          other.generatedMotifId == generatedMotifId &&
          other.fileName == fileName &&
          other.filePath == filePath &&
          other.downloadedAt == downloadedAt;

  @override
  int get hashCode => Object.hash(
        id,
        generatedMotifId,
        fileName,
        filePath,
        downloadedAt,
      );
}
