// motif_categories: category metadata for motif generation.
class MotifCategory {
  final String id;
  final String name;
  final String description;
  final String previewImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MotifCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.previewImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MotifCategory.fromJson(Map<String, dynamic> json) => MotifCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        previewImage: json['preview_image'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'preview_image': previewImage,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  MotifCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? previewImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      MotifCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        previewImage: previewImage ?? this.previewImage,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MotifCategory &&
          other.id == id &&
          other.name == name &&
          other.description == description &&
          other.previewImage == previewImage &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        previewImage,
        createdAt,
        updatedAt,
      );
}
