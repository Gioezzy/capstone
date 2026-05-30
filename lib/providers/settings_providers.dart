import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/services/settings_store.dart';
import '../domain/models/app_settings.dart';
import '../domain/models/enums.dart';

// Override in ProviderScope (bootstrap) with a resolved SharedPreferences.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  ),
);

final settingsStoreProvider = Provider<SettingsStore>(
  (ref) => SettingsStore(ref.watch(sharedPreferencesProvider)),
);

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (ref) => AppSettingsNotifier(ref.watch(settingsStoreProvider)),
);

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsStore _store;

  AppSettingsNotifier(this._store) : super(AppSettings.defaults);

  // Load persisted settings into state.
  Future<void> loadInitial() async {
    state = await _store.load();
  }

  Future<void> updateBaseUrl(String baseUrl) async {
    state = state.copyWith(baseUrl: baseUrl, updatedAt: DateTime.now());
    await _store.save(state);
  }

  Future<void> updateResolution(Resolution resolution) async {
    state =
        state.copyWith(defaultResolution: resolution, updatedAt: DateTime.now());
    await _store.save(state);
  }

  Future<void> updateMonochrome(bool monochromeTheme) async {
    state = state.copyWith(
        monochromeTheme: monochromeTheme, updatedAt: DateTime.now());
    await _store.save(state);
  }
}
