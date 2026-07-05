// Property 1: fromJson(toJson(m)) == m for all models.
import 'dart:math';

import 'package:capstone/domain/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

// Iterations per model (property-style sampling).
const _iterations = 200;

// Fixed seed -> deterministic, reproducible runs.
const _seed = 12345;

const _chars =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -_/.:';

String _str(Random r) {
  final len = r.nextInt(20); // includes empty string
  return String.fromCharCodes(
    List.generate(len, (_) => _chars.codeUnitAt(r.nextInt(_chars.length))),
  );
}

// UTC DateTime with microseconds -> ISO string carries 'Z' and round-trips.
DateTime _dateTime(Random r) {
  final seconds = r.nextInt(4102444800); // up to ~year 2100
  final micros = r.nextInt(1000000);
  return DateTime.fromMicrosecondsSinceEpoch(
    seconds * 1000000 + micros,
    isUtc: true,
  );
}

T _pick<T>(Random r, List<T> values) => values[r.nextInt(values.length)];

T? _maybe<T>(Random r, T Function() gen) => r.nextBool() ? gen() : null;

MotifCategory _category(Random r) => MotifCategory(
      id: _str(r),
      name: _str(r),
      description: _str(r),
      previewImage: _str(r),
      createdAt: _dateTime(r),
      updatedAt: _dateTime(r),
    );

GenerateHistory _history(Random r) => GenerateHistory(
      id: _str(r),
      categoryId: _str(r),
      generatedImage: _str(r),
      createdAt: _dateTime(r),
      categoryName: _maybe(r, () => _str(r)),
      tag: _maybe(r, () => _pick(r, MotifTag.values)),
    );

GeneratedMotif _motif(Random r) => GeneratedMotif(
      id: _str(r),
      historyId: _str(r),
      imageUrl: _str(r),
      categoryId: _str(r),
      createdAt: _dateTime(r),
      title: _maybe(r, () => _str(r)),
      baseModel: _maybe(r, () => _str(r)),
      complexity: _maybe(r, () => r.nextDouble()),
      primaryColor: _maybe(r, () => _str(r)),
      iterations: _maybe(r, () => r.nextInt(1000)),
    );

MotifImage _image(Random r) => MotifImage(
      id: _str(r),
      generatedMotifId: _str(r),
      url: _str(r),
      localPath: _maybe(r, () => _str(r)),
      fileName: _str(r),
      createdAt: _dateTime(r),
    );

MotifDownload _download(Random r) => MotifDownload(
      id: _str(r),
      generatedMotifId: _str(r),
      fileName: _str(r),
      filePath: _str(r),
      downloadedAt: _dateTime(r),
    );

AppSettings _settings(Random r) => AppSettings(
      id: _str(r),
      baseUrl: _str(r),
      defaultResolution: _pick(r, Resolution.values),
      isDarkMode: r.nextBool(),
      updatedAt: _dateTime(r),
    );

GenerateResult _result(Random r) => GenerateResult(
      motif: _motif(r),
      usedSeed: r.nextInt(1 << 31),
      historyId: _str(r),
    );

GenerateRequest _request(Random r) => GenerateRequest(
      categoryId: _str(r),
      resolution: _pick(r, Resolution.values),
      conditions: AttributeCondition.values.where((_) => r.nextBool()).toSet(),
      noiseSeed: _maybe(r, () => r.nextInt(1 << 31)),
    );

// Runs the round-trip assertion over many generated samples.
void _roundTrip<T>(
  String label,
  T Function(Random) gen,
  T Function(Map<String, dynamic>) fromJson,
  Map<String, dynamic> Function(T) toJson,
) {
  final r = Random(_seed);
  for (var i = 0; i < _iterations; i++) {
    final m = gen(r);
    expect(fromJson(toJson(m)), equals(m),
        reason: '$label round-trip failed on sample $i: $m');
  }
}

void main() {
  group('Property 1: JSON Round-Trip (semua model)', () {
    test('MotifCategory: fromJson(toJson(m)) == m', () {
      _roundTrip('MotifCategory', _category, MotifCategory.fromJson,
          (m) => m.toJson());
    });

    test('GenerateHistory: fromJson(toJson(m)) == m', () {
      _roundTrip('GenerateHistory', _history, GenerateHistory.fromJson,
          (m) => m.toJson());
    });

    test('GeneratedMotif: fromJson(toJson(m)) == m', () {
      _roundTrip(
          'GeneratedMotif', _motif, GeneratedMotif.fromJson, (m) => m.toJson());
    });

    test('MotifImage: fromJson(toJson(m)) == m', () {
      _roundTrip('MotifImage', _image, MotifImage.fromJson, (m) => m.toJson());
    });

    test('MotifDownload: fromJson(toJson(m)) == m', () {
      _roundTrip('MotifDownload', _download, MotifDownload.fromJson,
          (m) => m.toJson());
    });

    test('AppSettings: fromJson(toJson(m)) == m', () {
      _roundTrip(
          'AppSettings', _settings, AppSettings.fromJson, (m) => m.toJson());
    });

    test('GenerateResult: fromJson(toJson(m)) == m', () {
      _roundTrip('GenerateResult', _result, GenerateResult.fromJson,
          (m) => m.toJson());
    });

    // Included for completeness (Property 2 covers GenerateRequest in depth).
    test('GenerateRequest: fromJson(toJson(m)) == m', () {
      _roundTrip('GenerateRequest', _request, GenerateRequest.fromJson,
          (m) => m.toJson());
    });
  });
}
