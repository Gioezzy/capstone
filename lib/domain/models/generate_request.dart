import 'enums.dart';

// Payload for POST /generate.
class GenerateRequest {
  final String categoryId;
  final Resolution resolution;
  final Set<AttributeCondition> conditions;
  final int? noiseSeed; // null = random (backend picks seed)

  const GenerateRequest({
    required this.categoryId,
    required this.resolution,
    required this.conditions,
    this.noiseSeed,
  });

  factory GenerateRequest.fromJson(Map<String, dynamic> json) => GenerateRequest(
        categoryId: json['category_id'] as String,
        resolution: Resolution.fromApi(json['resolution'] as String),
        conditions: (json['conditions'] as List)
            .map((c) => AttributeCondition.values.byName(c as String))
            .toSet(),
        noiseSeed: json['noise_seed'] as int?,
      );

  // conditions sorted by enum index for deterministic output.
  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'resolution': resolution.apiValue,
        'conditions': _sortedConditions().map((c) => c.name).toList(),
        'noise_seed': noiseSeed,
      };

  List<AttributeCondition> _sortedConditions() {
    final list = conditions.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    return list;
  }

  GenerateRequest copyWith({
    String? categoryId,
    Resolution? resolution,
    Set<AttributeCondition>? conditions,
    int? noiseSeed,
  }) =>
      GenerateRequest(
        categoryId: categoryId ?? this.categoryId,
        resolution: resolution ?? this.resolution,
        conditions: conditions ?? this.conditions,
        noiseSeed: noiseSeed ?? this.noiseSeed,
      );

  bool _conditionsEqual(Set<AttributeCondition> other) =>
      conditions.length == other.length && conditions.containsAll(other);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenerateRequest &&
          other.categoryId == categoryId &&
          other.resolution == resolution &&
          _conditionsEqual(other.conditions) &&
          other.noiseSeed == noiseSeed;

  @override
  int get hashCode => Object.hash(
        categoryId,
        resolution,
        Object.hashAll(_sortedConditions().map((c) => c.name)),
        noiseSeed,
      );
}
