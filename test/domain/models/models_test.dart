import 'package:capstone/domain/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

// Fixed timestamps so equality is deterministic.
final _t1 = DateTime.utc(2023, 10, 24, 7);
final _t2 = DateTime.utc(2023, 10, 24, 14, 30);

MotifCategory _category() => MotifCategory(
      id: 'cat-001',
      name: 'Pucuk Rebung',
      description: 'Motif flora klasik.',
      previewImage: 'https://cdn/cat.png',
      createdAt: _t1,
      updatedAt: _t1,
    );

GeneratedMotif _motif({bool withMeta = true}) => GeneratedMotif(
      id: 'mtf-101',
      historyId: 'gen-042',
      imageUrl: 'https://cdn/mtf.png',
      categoryId: 'cat-001',
      createdAt: _t2,
      title: withMeta ? 'Songket Pucuk Rebung' : null,
      baseModel: withMeta ? 'Tradisional Nusantara v2' : null,
      complexity: withMeta ? 0.85 : null,
      primaryColor: withMeta ? 'Monochrome' : null,
      iterations: withMeta ? 50 : null,
    );

AppSettings _settings() => AppSettings(
      id: 'local',
      baseUrl: 'https://api.songketai.dev/v1',
      defaultResolution: Resolution.px128,
      isDarkMode: true,
      updatedAt: _t1,
    );

GenerateRequest _request() => const GenerateRequest(
      categoryId: 'cat-001',
      resolution: Resolution.px128,
      conditions: {AttributeCondition.simetris, AttributeCondition.geometris},
      noiseSeed: 42,
    );

GenerateResult _result() => GenerateResult(
      motif: _motif(),
      usedSeed: 42,
      historyId: 'gen-042',
    );

void main() {
  group('copyWith() with no arguments returns an equal object', () {
    test('MotifCategory', () {
      final a = _category();
      expect(a.copyWith(), equals(a));
      expect(a.copyWith().hashCode, equals(a.hashCode));
    });

    test('GeneratedMotif', () {
      final a = _motif();
      expect(a.copyWith(), equals(a));
      expect(a.copyWith().hashCode, equals(a.hashCode));
    });

    test('AppSettings', () {
      final a = _settings();
      expect(a.copyWith(), equals(a));
      expect(a.copyWith().hashCode, equals(a.hashCode));
    });

    test('GenerateRequest', () {
      final a = _request();
      expect(a.copyWith(), equals(a));
      expect(a.copyWith().hashCode, equals(a.hashCode));
    });

    test('GenerateResult', () {
      final a = _result();
      expect(a.copyWith(), equals(a));
      expect(a.copyWith().hashCode, equals(a.hashCode));
    });
  });

  group('copyWith() partial override changes only the targeted field', () {
    test('MotifCategory name', () {
      final a = _category();
      final b = a.copyWith(name: 'Tampuk Manggis');
      expect(b.name, 'Tampuk Manggis');
      expect(b.id, a.id);
      expect(b.description, a.description);
      expect(b, isNot(equals(a)));
    });

    test('GeneratedMotif imageUrl', () {
      final a = _motif();
      final b = a.copyWith(imageUrl: 'https://cdn/other.png');
      expect(b.imageUrl, 'https://cdn/other.png');
      expect(b.id, a.id);
      expect(b.title, a.title);
      expect(b, isNot(equals(a)));
    });

    test('GenerateResult fields', () {
      final a = _result();
      final b = a.copyWith(usedSeed: 7, historyId: 'gen-099');
      expect(b.usedSeed, 7);
      expect(b.historyId, 'gen-099');
      expect(b.motif, a.motif);
      expect(b, isNot(equals(a)));
    });
  });

  group('value-based equality', () {
    test('MotifCategory: same fields equal, one field differs not equal', () {
      expect(_category(), equals(_category()));
      expect(_category().hashCode, equals(_category().hashCode));
      expect(_category().copyWith(id: 'cat-002'), isNot(equals(_category())));
    });

    test('AppSettings: same fields equal, one field differs not equal', () {
      expect(_settings(), equals(_settings()));
      expect(_settings().hashCode, equals(_settings().hashCode));
      expect(
        _settings().copyWith(isDarkMode: false),
        isNot(equals(_settings())),
      );
    });
  });

  group('GeneratedMotif optional fields', () {
    test('null optionals equal each other', () {
      final a = _motif(withMeta: false);
      final b = _motif(withMeta: false);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('null optional not equal to populated optional', () {
      expect(_motif(withMeta: false), isNot(equals(_motif())));
    });

    test('copyWith populating an optional changes equality', () {
      final a = _motif(withMeta: false);
      final b = a.copyWith(iterations: 50);
      expect(b.iterations, 50);
      expect(b, isNot(equals(a)));
    });
  });

  group('GenerateRequest', () {
    test('conditions equality is order-independent', () {
      const a = GenerateRequest(
        categoryId: 'cat-001',
        resolution: Resolution.px128,
        conditions: {AttributeCondition.simetris, AttributeCondition.geometris},
      );
      const b = GenerateRequest(
        categoryId: 'cat-001',
        resolution: Resolution.px128,
        conditions: {AttributeCondition.geometris, AttributeCondition.simetris},
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different conditions set is not equal', () {
      final a = _request();
      final b = a.copyWith(conditions: {AttributeCondition.minimalis});
      expect(b, isNot(equals(a)));
    });

    test('copyWith overrides conditions and noiseSeed', () {
      final a = _request();
      final b = a.copyWith(
        conditions: {AttributeCondition.padat},
        noiseSeed: 7,
      );
      expect(b.conditions, {AttributeCondition.padat});
      expect(b.noiseSeed, 7);
      expect(b.categoryId, a.categoryId);
      expect(b, isNot(equals(a)));
    });

    test('noiseSeed null vs value affects equality', () {
      const withNull = GenerateRequest(
        categoryId: 'cat-001',
        resolution: Resolution.px128,
        conditions: {AttributeCondition.simetris},
      );
      final withValue = withNull.copyWith(noiseSeed: 0);
      expect(withValue.noiseSeed, 0);
      expect(withValue, isNot(equals(withNull)));
    });
  });

  group('AppSettings copyWith', () {
    test('overrides defaultResolution, baseUrl, isDarkMode', () {
      final a = _settings();
      final b = a.copyWith(
        defaultResolution: Resolution.px64,
        baseUrl: 'https://other/v2',
        isDarkMode: false,
      );
      expect(b.defaultResolution, Resolution.px64);
      expect(b.baseUrl, 'https://other/v2');
      expect(b.isDarkMode, false);
      expect(b.id, a.id);
      expect(b, isNot(equals(a)));
    });
  });
}
