import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hadith_everyday/domain/entities/hadith_entity.dart';
import 'package:hadith_everyday/presentation/screens/editor/design_editor_screen.dart';
import 'package:hadith_everyday/presentation/screens/gallery/gallery_screen.dart';
import 'package:hadith_everyday/presentation/screens/home/home_screen.dart';
import 'package:hadith_everyday/presentation/screens/settings/settings_screen.dart';
import 'package:hadith_everyday/presentation/screens/splash/splash_screen.dart';

class AppRoutes {
  static const String splash   = '/';
  static const String home     = '/home';
  static const String settings = '/settings';
  static const String editor   = '/editor';
  static const String gallery  = '/gallery';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      pageBuilder: (context, state) => _slide(state, const SettingsScreen()),
    ),
    GoRoute(
      path: AppRoutes.gallery,
      name: 'gallery',
      pageBuilder: (context, state) => _slide(state, const GalleryScreen()),
    ),
    GoRoute(
      path: AppRoutes.editor,
      name: 'editor',
      pageBuilder: (context, state) {
        final hadith = state.extra as HadithEntity;
        return _slide(state, DesignEditorScreen(hadith: hadith));
      },
    ),
  ],
);

CustomTransitionPage<void> _slide(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
  );
}
