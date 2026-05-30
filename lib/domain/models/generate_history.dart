import 'enums.dart';

// generate_histories: a generate event listed in history.
class GenerateHistory {
  final String id;
  final String categoryId;
  final String generatedImage;
  final DateTime createdAt;
  final String? categoryName;
  final MotifTag? tag;

  const GenerateHistory({
    required this.id,
    required this.categoryId,
    required this.generatedImage,
    required this.createdAt,
    this.categoryName,
    this.tag,
  });

  factory GenerateHistory.fromJson(Map<String, dynamic> json) =>
      GenerateHistory(
        id: json['id'] as String,
        categoryId: json['category_id'] as String,
        generatedImage: json['generated_image'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        categoryName: json['category_name'] as String?,
        tag: _tagFromName(json['tag'] as String?),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_id': categoryId,
        'generated_image': generatedImage,
        'created_at': createdAt.toIso8601String(),
        'category_name': categoryName,
        'tag': tag?.name,
      };

  GenerateHistory copyWith({
    String? id,
    String? categoryId,
    String? generatedImage,
    DateTime? createdAt,
    String? categoryName,
    MotifTag? tag,
  }) =>
      GenerateHistory(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        generatedImage: generatedImage ?? this.generatedImage,
        createdAt: createdAt ?? this.createdAt,
        categoryName: categoryName ?? this.categoryName,
        tag: tag ?? this.tag,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenerateHistory &&
          other.id == id &&
          other.categoryId == categoryId &&
          other.generatedImage == generatedImage &&
          other.createdAt == createdAt &&
          other.categoryName == categoryName &&
          other.tag == tag;

  @override
  int get hashCode => Object.hash(
        id,
        categoryId,
        generatedImage,
        createdAt,
        categoryName,
        tag,
      );
}

// Maps an enum name back to MotifTag, null-safe.
MotifTag? _tagFromName(String? name) {
  if (name == null) return null;
  for (final tag in MotifTag.values) {
    if (tag.name == name) return tag;
  }
  return null;
}
