import 'generated_motif.dart';

// Result returned from POST /generate.
class GenerateResult {
  final GeneratedMotif motif;
  final int usedSeed;
  final String historyId;

  const GenerateResult({
    required this.motif,
    required this.usedSeed,
    required this.historyId,
  });

  factory GenerateResult.fromJson(Map<String, dynamic> json) => GenerateResult(
        motif: GeneratedMotif.fromJson(json['motif'] as Map<String, dynamic>),
        usedSeed: json['used_seed'] as int,
        historyId: json['history_id'] as String,
      );

  Map<String, dynamic> toJson() => {
        'motif': motif.toJson(),
        'used_seed': usedSeed,
        'history_id': historyId,
      };

  GenerateResult copyWith({
    GeneratedMotif? motif,
    int? usedSeed,
    String? historyId,
  }) =>
      GenerateResult(
        motif: motif ?? this.motif,
        usedSeed: usedSeed ?? this.usedSeed,
        historyId: historyId ?? this.historyId,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenerateResult &&
          other.motif == motif &&
          other.usedSeed == usedSeed &&
          other.historyId == historyId;

  @override
  int get hashCode => Object.hash(motif, usedSeed, historyId);
}
