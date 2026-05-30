import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/models.dart';
import '../../features/about/presentation/about_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/configure/presentation/configure_screen.dart';
import '../../features/generating/presentation/generating_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/history_detail/presentation/history_detail_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/result/presentation/result_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../widgets/app_bottom_nav.dart';
import 'routes.dart';

// Builds the app router: 10 routes with a 3-tab StatefulShellRoute.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: Routes.splashPath,
    routes: [
      GoRoute(
        path: Routes.splashPath,
        name: Routes.splashName,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.categoriesPath,
        name: Routes.categoriesName,
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: Routes.configurePath,
        name: Routes.configureName,
        builder: (context, state) => ConfigureScreen(
          categoryId: state.uri.queryParameters['categoryId'] ?? '',
        ),
      ),
      GoRoute(
        path: Routes.generatingPath,
        name: Routes.generatingName,
        // Reached directly without a request (e.g. deep link): fall back to
        // categories instead of crashing.
        redirect: (context, state) =>
            state.extra is GenerateRequest ? null : Routes.categoriesPath,
        builder: (context, state) =>
            GeneratingScreen(request: state.extra! as GenerateRequest),
      ),
      GoRoute(
        path: Routes.resultPath,
        name: Routes.resultName,
        // No result to show without an extra: fall back to home.
        redirect: (context, state) =>
            state.extra is GenerateResult ? null : Routes.homePath,
        builder: (context, state) =>
            ResultScreen(result: state.extra! as GenerateResult),
      ),
      GoRoute(
        path: Routes.aboutPath,
        name: Routes.aboutName,
        builder: (context, state) => const AboutScreen(),
      ),
      // Top-level (outside shell) so it pushes full with a back button and
      // does not collide with the '/history' shell branch.
      GoRoute(
        path: Routes.historyDetailPath,
        name: Routes.historyDetailName,
        builder: (context, state) =>
            HistoryDetailScreen(motifId: state.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _ShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.homePath,
                name: Routes.homeName,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.historyPath,
                name: Routes.historyName,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.settingsPath,
                name: Routes.settingsName,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

// Shell wrapper: keeps each tab's state via indexedStack + bottom nav.
class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
