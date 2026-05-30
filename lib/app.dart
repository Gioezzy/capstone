import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

// Root application widget wiring router + monochrome theme.
class SongketApp extends StatefulWidget {
  const SongketApp({super.key});

  @override
  State<SongketApp> createState() => _SongketAppState();
}

class _SongketAppState extends State<SongketApp> {
  final _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    // Theme is fully monochrome; appSettings.monochromeTheme has no alternate
    // palette yet, so a single theme is applied unconditionally.
    return MaterialApp.router(
      title: 'SongketAI',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: _router,
    );
  }
}
