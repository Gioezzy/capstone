enum Resolution {
  px64,
  px128;

  // apiValue and fromApi are inverses (round-trip safe).
  String get apiValue => this == Resolution.px64 ? '64x64' : '128x128';

  int get pixels => this == Resolution.px64 ? 64 : 128;

  static Resolution fromApi(String value) {
    switch (value) {
      case '64x64':
        return Resolution.px64;
      case '128x128':
        return Resolution.px128;
      default:
        throw ArgumentError.value(
          value,
          'value',
          'Nilai resolusi tidak dikenal (harus "64x64" atau "128x128")',
        );
    }
  }
}

enum AttributeCondition {
  simetris,
  padat,
  minimalis,
  geometris,
}

enum MotifTag {
  floral,
  abstract,
  geometric,
  classic,
  songket,
}
