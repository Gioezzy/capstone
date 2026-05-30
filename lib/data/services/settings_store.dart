import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/app_settings.dart';

// Persists AppSettings as a single JSON string in shared_preferences.
class SettingsStore {
  static const String _key = 'app_settings';

  final SharedPreferences _prefs;

  SettingsStore(this._prefs);

  // Production helper: resolves SharedPreferences itself.
  static Future<SettingsStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsStore(prefs);
  }

  // Returns persisted settings, or defaults when absent/corrupt.
  Future<AppSettings> load() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return AppSettings.defaults;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AppSettings.fromJson(json);
    } catch (_) {
      return AppSettings.defaults;
    }
  }

  Future<void> save(AppSettings settings) async {
    await _prefs.setString(_key, jsonEncode(settings.toJson()));
  }
}
