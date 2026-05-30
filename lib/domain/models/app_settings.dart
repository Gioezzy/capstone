import 'enums.dart';

// app_settings: local application settings.
class AppSettings {
  final String id;
  final String baseUrl;
  final Resolution defaultResolution;
  final bool monochromeTheme;
  final DateTime updatedAt;

  const AppSettings({
    required this.id,
    required this.baseUrl,
    required this.defaultResolution,
    required this.monochromeTheme,
    required this.updatedAt,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        id: json['id'] as String,
        baseUrl: json['base_url'] as String,
        defaultResolution:
            Resolution.fromApi(json['default_resolution'] as String),
        monochromeTheme: json['monochrome_theme'] as bool,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'base_url': baseUrl,
        'default_resolution': defaultResolution.apiValue,
        'monochrome_theme': monochromeTheme,
        'updated_at': updatedAt.toIso8601String(),
      };

  AppSettings copyWith({
    String? id,
    String? baseUrl,
    Resolution? defaultResolution,
    bool? monochromeTheme,
    DateTime? updatedAt,
  }) =>
      AppSettings(
        id: id ?? this.id,
        baseUrl: baseUrl ?? this.baseUrl,
        defaultResolution: defaultResolution ?? this.defaultResolution,
        monochromeTheme: monochromeTheme ?? this.monochromeTheme,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          other.id == id &&
          other.baseUrl == baseUrl &&
          other.defaultResolution == defaultResolution &&
          other.monochromeTheme == monochromeTheme &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        baseUrl,
        defaultResolution,
        monochromeTheme,
        updatedAt,
      );

  // Default settings used before any persisted value exists.
  static final AppSettings defaults = AppSettings(
    id: 'local',
    baseUrl: 'https://api.songketai.dev/v1',
    defaultResolution: Resolution.px128,
    monochromeTheme: true,
    updatedAt: DateTime.now(),
  );
}
