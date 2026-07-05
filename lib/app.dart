import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/settings_providers.dart';

// Root application widget wiring router + theme.
class SongketApp extends ConsumerStatefulWidget {
  const SongketApp({super.key});

  @override
  ConsumerState<SongketApp> createState() => _SongketAppState();
}

class _SongketAppState extends ConsumerState<SongketApp> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SongketAI',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildAppTheme(isDarkMode: true),
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
