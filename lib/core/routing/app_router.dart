import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/widgets/loading_screen.dart';
import 'package:my_tiny_thinker/games/memory_game/presentation/memory_hub_screen.dart';
import 'package:my_tiny_thinker/games/memory_game/presentation/memory_play_screen.dart';
import 'package:my_tiny_thinker/games/memory_game/models/memory_models.dart';
import 'package:my_tiny_thinker/games/ascending_descending/presentation/bubble_game_setup_screen.dart';
import 'package:my_tiny_thinker/games/ascending_descending/presentation/bubble_game_screen.dart';
import 'package:my_tiny_thinker/home/presentation/games_screen.dart';
import 'package:my_tiny_thinker/home/presentation/home_screen.dart';
import 'package:my_tiny_thinker/home/presentation/main_shell.dart';
import 'package:my_tiny_thinker/parent_zone/presentation/parent_zone_screen.dart';
import 'package:my_tiny_thinker/profile/presentation/profile_screen.dart';
import 'package:my_tiny_thinker/rewards/presentation/rewards_screen.dart';
import 'package:my_tiny_thinker/settings/presentation/settings_screen.dart';

abstract final class AppRoutes {
  static const loading = '/';
  static const home = '/home';
  static const games = '/games';
  static const rewards = '/rewards';
  static const profile = '/profile';
  static const parents = '/parents';
  static const settings = '/settings';
  static const parentZone = '/parent-zone';
  static const bubbleSetup = '/games/bubble-number-pop/setup';
  static const bubbleGame = '/games/bubble-number-pop/play';
  static const memoryHub = '/games/memory-game';
  static const memoryPlay = '/games/memory-game/play';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.loading,
  routes: [
    GoRoute(
      path: AppRoutes.loading,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: LoadingScreen(onComplete: () => context.go(AppRoutes.home)),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => _fadePage(state, const HomeScreen()),
        ),
        GoRoute(
          path: AppRoutes.games,
          pageBuilder: (context, state) => _fadePage(state, const GamesScreen()),
        ),
        GoRoute(
          path: AppRoutes.rewards,
          pageBuilder: (context, state) => _fadePage(state, const RewardsScreen()),
        ),
        GoRoute(
          path: AppRoutes.profile,
          pageBuilder: (context, state) => _fadePage(state, const ProfileScreen()),
        ),
        GoRoute(
          path: AppRoutes.parents,
          pageBuilder: (context, state) =>
              _fadePage(state, const ParentZoneScreen()),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.settings,
      pageBuilder: (context, state) => _slidePage(state, const SettingsScreen()),
    ),
    GoRoute(
      path: AppRoutes.parentZone,
      pageBuilder: (context, state) =>
          _slidePage(state, const ParentZoneScreen()),
    ),
    GoRoute(
      path: AppRoutes.bubbleSetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const BubbleGameSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.bubbleGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const BubbleGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.memoryHub,
      pageBuilder: (context, state) =>
          _slidePage(state, const MemoryHubScreen()),
    ),
    GoRoute(
      path: AppRoutes.memoryPlay,
      pageBuilder: (context, state) => _slidePage(
        state,
        MemoryPlayScreen(
          initialConfig: state.extra as MemoryGameConfig?,
        ),
      ),
    ),
  ],
);

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

CustomTransitionPage<void> _slidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offset = Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return SlideTransition(
        position: offset,
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}
