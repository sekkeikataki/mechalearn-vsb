import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/courses.dart';
import 'providers/progress_provider.dart';
import 'screens/about_screen.dart';
import 'screens/courses_hub_screen.dart';
import 'screens/home_screen.dart';
import 'screens/lesson_player_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/shell_scaffold.dart';
import 'services/progress_service.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final progress = ref.watch(progressProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/home',
    redirect: (context, state) {
      final p = progress.value;
      if (p == null) return null;
      final onboarding = state.matchedLocation == '/onboarding';
      if (!p.onboarded && !onboarding) return '/onboarding';
      if (p.onboarded && onboarding) return '/home';

      // Engine unlock gate: deep link /lesson/:id must not bypass lock.
      final lessonId = state.pathParameters['lessonId'];
      if (lessonId != null && state.matchedLocation.startsWith('/lesson/')) {
        final catalog =
            courseById(p.activeCourseId ?? 'matematika') ?? allCourses.first;
        if (!ProgressService.canPlayLesson(lessonId, p, catalog)) {
          return '/home';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (c, s) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (c, s) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/courses',
                builder: (c, s) => const CoursesHubScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (c, s) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    builder: (c, s) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'about',
                    builder: (c, s) => const AboutScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/lesson/:lessonId',
        parentNavigatorKey: _rootKey,
        builder: (c, s) {
          final id = s.pathParameters['lessonId']!;
          return LessonPlayerScreen(lessonId: id);
        },
      ),
    ],
  );
});
