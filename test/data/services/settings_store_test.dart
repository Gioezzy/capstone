// Unit tests for SettingsStore persistence.
import 'package:capstone/data/services/settings_store.dart';
import 'package:capstone/domain/models/app_settings.dart';
import 'package:capstone/domain/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // shared_preferences uses a platform channel.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('SettingsStore', () {
    test('load() returns defaults when storage is empty', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = SettingsStore(prefs);

      final settings = await store.load();

      expect(settings.baseUrl, AppSettings.defaults.baseUrl);
      expect(settings.defaultResolution, Resolution.px128);
      expect(settings.monochromeTheme, isTrue);
    });

    test('save() then load() preserves changed fields', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = SettingsStore(prefs);

      final saved = AppSettings.defaults.copyWith(
        defaultResolution: Resolution.px64,
        monochromeTheme: false,
        updatedAt: DateTime.now(),
      );
      await store.save(saved);

      // New store over the same prefs simulates a reload.
      final reloaded = await SettingsStore(prefs).load();

      expect(reloaded.baseUrl, saved.baseUrl);
      expect(reloaded.defaultResolution, Resolution.px64);
      expect(reloaded.monochromeTheme, isFalse);
    });

    test('round-trips multiple changed values across getInstance()', () async {
      final prefs = await SharedPreferences.getInstance();
      final saved = AppSettings.defaults.copyWith(
        baseUrl: 'https://x/v2',
        defaultResolution: Resolution.px64,
        monochromeTheme: false,
        updatedAt: DateTime.now(),
      );
      await SettingsStore(prefs).save(saved);

      final freshPrefs = await SharedPreferences.getInstance();
      final reloaded = await SettingsStore(freshPrefs).load();

      expect(reloaded.baseUrl, 'https://x/v2');
      expect(reloaded.defaultResolution, Resolution.px64);
      expect(reloaded.monochromeTheme, isFalse);
    });

    test('load() returns defaults when stored value is corrupt', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_settings', 'not json');
      final store = SettingsStore(prefs);

      final settings = await store.load();

      expect(settings.baseUrl, AppSettings.defaults.baseUrl);
      expect(settings.defaultResolution, AppSettings.defaults.defaultResolution);
      expect(settings.monochromeTheme, AppSettings.defaults.monochromeTheme);
    });
  });
}
