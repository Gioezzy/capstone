// motif_images: an image asset belonging to a generated motif.
class MotifImage {
  final String id;
  final String generatedMotifId;
  final String url;
  final String? localPath;
  final String fileName;
  final DateTime createdAt;

  const MotifImage({
    required this.id,
    required this.generatedMotifId,
    required this.url,
    required this.fileName,
    required this.createdAt,
    this.localPath,
  });

  factory MotifImage.fromJson(Map<String, dynamic> json) => MotifImage(
        id: json['id'] as String,
        generatedMotifId: json['generated_motif_id'] as String,
        url: json['url'] as String,
        localPath: json['local_path'] as String?,
        fileName: json['file_name'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'generated_motif_id': generatedMotifId,
        'url': url,
        'local_path': localPath,
        'file_name': fileName,
        'created_at': createdAt.toIso8601String(),
      };

  MotifImage copyWith({
    String? id,
    String? generatedMotifId,
    String? url,
    String? localPath,
    String? fileName,
    DateTime? createdAt,
  }) =>
      MotifImage(
        id: id ?? this.id,
        generatedMotifId: generatedMotifId ?? this.generatedMotifId,
        url: url ?? this.url,
        localPath: localPath ?? this.localPath,
        fileName: fileName ?? this.fileName,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MotifImage &&
          other.id == id &&
          other.generatedMotifId == generatedMotifId &&
          other.url == url &&
          other.localPath == localPath &&
          other.fileName == fileName &&
          other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(
        id,
        generatedMotifId,
        url,
        localPath,
        fileName,
        createdAt,
      );
}
