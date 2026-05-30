import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/enums.dart';
import '../../../domain/models/generate_request.dart';
import '../../../domain/models/motif_category.dart';

// Form state for the generate configuration screen.
class ConfigureState {
  final MotifCategory category;
  final Resolution resolution;
  final Set<AttributeCondition> conditions;
  final String seedInput;

  const ConfigureState({
    required this.category,
    this.resolution = Resolution.px128,
    this.conditions = const {},
    this.seedInput = '',
  });

  // Valid iff empty (random) OR parses to an integer >= 0.
  bool get isSeedValid {
    if (seedInput.isEmpty) return true;
    final parsed = int.tryParse(seedInput);
    return parsed != null && parsed >= 0;
  }

  // Pre-condition: isSeedValid. Empty seed -> null (backend random).
  GenerateRequest toRequest() => GenerateRequest(
        categoryId: category.id,
        resolution: resolution,
        conditions: conditions,
        noiseSeed: seedInput.isEmpty ? null : int.parse(seedInput),
      );

  // Pure toggle: toggling twice yields the original set.
  ConfigureState toggleCondition(AttributeCondition c) {
    final next = Set<AttributeCondition>.from(conditions);
    if (!next.remove(c)) next.add(c);
    return copyWith(conditions: next);
  }

  ConfigureState withResolution(Resolution resolution) =>
      copyWith(resolution: resolution);

  ConfigureState withSeedInput(String seedInput) =>
      copyWith(seedInput: seedInput);

  ConfigureState copyWith({
    MotifCategory? category,
    Resolution? resolution,
    Set<AttributeCondition>? conditions,
    String? seedInput,
  }) =>
      ConfigureState(
        category: category ?? this.category,
        resolution: resolution ?? this.resolution,
        conditions: conditions ?? this.conditions,
        seedInput: seedInput ?? this.seedInput,
      );

  List<String> _sortedConditionNames() {
    final names = conditions.map((c) => c.name).toList()..sort();
    return names;
  }

  bool _conditionsEqual(Set<AttributeCondition> other) =>
      conditions.length == other.length && conditions.containsAll(other);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigureState &&
          other.category == category &&
          other.resolution == resolution &&
          _conditionsEqual(other.conditions) &&
          other.seedInput == seedInput;

  @override
  int get hashCode => Object.hash(
        category,
        resolution,
        Object.hashAll(_sortedConditionNames()),
        seedInput,
      );
}

class ConfigureController extends StateNotifier<ConfigureState> {
  ConfigureController(MotifCategory category)
      : super(ConfigureState(category: category));

  void toggle(AttributeCondition c) => state = state.toggleCondition(c);

  void setResolution(Resolution resolution) =>
      state = state.withResolution(resolution);

  void setSeedInput(String seedInput) =>
      state = state.withSeedInput(seedInput);

  // "Acak": clear the field so the backend picks a random seed.
  void randomizeSeed() => state = state.withSeedInput('');

  bool get isSeedValid => state.isSeedValid;
}

final configureControllerProvider = StateNotifierProvider.autoDispose
    .family<ConfigureController, ConfigureState, MotifCategory>(
  (ref, category) => ConfigureController(category),
);
