import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/models.dart';
import '../../features/about/presentation/about_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/configure/presentation/configure_screen.dart';
import '../../features/generating/presentation/generating_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/history_detail/presentation/history_detail_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/result/presentation/result_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../providers/auth_provider.dart';
import '../widgets/app_bottom_nav.dart';
import 'routes.dart';

// Builds the app router: 12 routes with a 3-tab StatefulShellRoute.
final routerProvider = Provider<GoRouter>((ref) {
  final authStateNotifier = ValueNotifier<bool>(ref.read(authProvider).isAuthenticated);
  ref.listen(authProvider, (_, next) {
    authStateNotifier.value = next.isAuthenticated;
  });

  return GoRouter(
    refreshListenable: authStateNotifier,
    initialLocation: Routes.splashPath,
    redirect: (context, state) {
      final isAuth = ref.read(authProvider).isAuthenticated;
      final isAuthRoute = state.uri.path == Routes.loginPath || state.uri.path == Routes.registerPath;
      final isSplash = state.uri.path == Routes.splashPath;

      if (isSplash) return null;

      if (!isAuth && !isAuthRoute) {
        return Routes.loginPath;
      }

      if (isAuth && isAuthRoute) {
        return Routes.homePath;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.loginPath,
        name: Routes.loginName,
        builder: (context, state) => const LoginScreen(showUnauthenticatedMessage: true),
      ),
      GoRoute(
        path: Routes.registerPath,
        name: Routes.registerName,
        builder: (context, state) => const RegisterScreen(),
      ),
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
        redirect: (context, state) {
          final hasRequest = state.extra is GenerateRequest;
          
          return hasRequest ? null : Routes.categoriesPath;
        },
        builder: (context, state) {
          return GeneratingScreen(request: state.extra! as GenerateRequest);
        },
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profilePath,
                name: Routes.profileName,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

// Shell wrapper: keeps each tab's state via indexedStack + bottom nav.
class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allow body to scroll behind floating nav
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
