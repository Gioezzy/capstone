import 'enums.dart';

// app_settings: local application settings.
class AppSettings {
  final String id;
  final String baseUrl;
  final Resolution defaultResolution;
  final bool isDarkMode;
  final DateTime updatedAt;

  const AppSettings({
    required this.id,
    required this.baseUrl,
    required this.defaultResolution,
    required this.isDarkMode,
    required this.updatedAt,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        id: json['id'] as String,
        baseUrl: json['base_url'] as String,
        defaultResolution:
            Resolution.fromApi(json['default_resolution'] as String),
        isDarkMode: json['is_dark_mode'] as bool? ?? false,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'base_url': baseUrl,
        'default_resolution': defaultResolution.apiValue,
        'is_dark_mode': isDarkMode,
        'updated_at': updatedAt.toIso8601String(),
      };

  AppSettings copyWith({
    String? id,
    String? baseUrl,
    Resolution? defaultResolution,
    bool? isDarkMode,
    DateTime? updatedAt,
  }) =>
      AppSettings(
        id: id ?? this.id,
        baseUrl: baseUrl ?? this.baseUrl,
        defaultResolution: defaultResolution ?? this.defaultResolution,
        isDarkMode: isDarkMode ?? this.isDarkMode,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          other.id == id &&
          other.baseUrl == baseUrl &&
          other.defaultResolution == defaultResolution &&
          other.isDarkMode == isDarkMode &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        baseUrl,
        defaultResolution,
        isDarkMode,
        updatedAt,
      );

  // Default settings used before any persisted value exists.
  static final AppSettings defaults = AppSettings(
    id: 'local',
    baseUrl: 'http://127.0.0.1:8000',
    defaultResolution: Resolution.px128,
    isDarkMode: false,
    updatedAt: DateTime.now(),
  );
}
