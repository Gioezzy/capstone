// generated_motifs: a generated motif with optional display metadata.
class GeneratedMotif {
  final String id;
  final String historyId;
  final String imageUrl;
  final String categoryId;
  final DateTime createdAt;
  final String? title;
  final String? baseModel;
  final double? complexity;
  final String? primaryColor;
  final int? iterations;

  const GeneratedMotif({
    required this.id,
    required this.historyId,
    required this.imageUrl,
    required this.categoryId,
    required this.createdAt,
    this.title,
    this.baseModel,
    this.complexity,
    this.primaryColor,
    this.iterations,
  });

  factory GeneratedMotif.fromJson(Map<String, dynamic> json) => GeneratedMotif(
        id: json['id'] as String,
        historyId: json['history_id'] as String,
        imageUrl: json['image_url'] as String,
        categoryId: json['category_id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        title: json['title'] as String?,
        baseModel: json['base_model'] as String?,
        complexity: (json['complexity'] as num?)?.toDouble(),
        primaryColor: json['primary_color'] as String?,
        iterations: json['iterations'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'history_id': historyId,
        'image_url': imageUrl,
        'category_id': categoryId,
        'created_at': createdAt.toIso8601String(),
        'title': title,
        'base_model': baseModel,
        'complexity': complexity,
        'primary_color': primaryColor,
        'iterations': iterations,
      };

  GeneratedMotif copyWith({
    String? id,
    String? historyId,
    String? imageUrl,
    String? categoryId,
    DateTime? createdAt,
    String? title,
    String? baseModel,
    double? complexity,
    String? primaryColor,
    int? iterations,
  }) =>
      GeneratedMotif(
        id: id ?? this.id,
        historyId: historyId ?? this.historyId,
        imageUrl: imageUrl ?? this.imageUrl,
        categoryId: categoryId ?? this.categoryId,
        createdAt: createdAt ?? this.createdAt,
        title: title ?? this.title,
        baseModel: baseModel ?? this.baseModel,
        complexity: complexity ?? this.complexity,
        primaryColor: primaryColor ?? this.primaryColor,
        iterations: iterations ?? this.iterations,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneratedMotif &&
          other.id == id &&
          other.historyId == historyId &&
          other.imageUrl == imageUrl &&
          other.categoryId == categoryId &&
          other.createdAt == createdAt &&
          other.title == title &&
          other.baseModel == baseModel &&
          other.complexity == complexity &&
          other.primaryColor == primaryColor &&
          other.iterations == iterations;

  @override
  int get hashCode => Object.hash(
        id,
        historyId,
        imageUrl,
        categoryId,
        createdAt,
        title,
        baseModel,
        complexity,
        primaryColor,
        iterations,
      );
}
