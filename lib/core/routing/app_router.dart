import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/widgets/app_loading_gate.dart';
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
import 'package:my_tiny_thinker/games/odd_one_out/presentation/odd_one_out_game_screen.dart';
import 'package:my_tiny_thinker/games/odd_one_out/presentation/odd_one_out_setup_screen.dart';
import 'package:my_tiny_thinker/games/pattern_match/presentation/pattern_match_game_screen.dart';
import 'package:my_tiny_thinker/games/pattern_match/presentation/pattern_match_setup_screen.dart';
import 'package:my_tiny_thinker/games/color_memory/presentation/color_memory_setup_screen.dart';
import 'package:my_tiny_thinker/games/color_memory/presentation/color_memory_game_screen.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/presentation/ocean_fish_setup_screen.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/presentation/ocean_fish_game_screen.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/presentation/cloud_pop_garden_setup_screen.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/presentation/cloud_pop_garden_game_screen.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/presentation/flower_garden_setup_screen.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/presentation/flower_garden_game_screen.dart';
import 'package:my_tiny_thinker/onboarding/presentation/welcome_screen.dart';
import 'package:my_tiny_thinker/onboarding/presentation/age_selection_screen.dart';
import 'package:my_tiny_thinker/onboarding/presentation/avatar_selection_screen.dart';

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
  static const oddOneOutSetup = '/games/odd-one-out/setup';
  static const oddOneOutGame = '/games/odd-one-out/play';
  static const patternMatchSetup = '/games/pattern-match/setup';
  static const patternMatchGame = '/games/pattern-match/play';
  static const colorMemorySetup = '/games/color-memory/setup';
  static const colorMemoryGame = '/games/color-memory/play';
  static const oceanFishSetup = '/games/ocean-fish/setup';
  static const oceanFishGame = '/games/ocean-fish/play';
  static const flowerGardenSetup = '/games/flower-garden/setup';
  static const flowerGardenGame = '/games/flower-garden/play';
  static const cloudPopGardenSetup = '/games/cloud-pop-garden/setup';
  static const cloudPopGardenGame = '/games/cloud-pop-garden/play';
  static const welcome = '/welcome';
  static const ageSelection = '/onboarding/age';
  static const avatarSelection = '/onboarding/avatar';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.loading,
  routes: [
    GoRoute(
      path: AppRoutes.loading,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AppLoadingGate(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.welcome,
      pageBuilder: (context, state) => _fadePage(state, const WelcomeScreen()),
    ),
    GoRoute(
      path: AppRoutes.ageSelection,
      pageBuilder: (context, state) =>
          _fadePage(state, const AgeSelectionScreen()),
    ),
    GoRoute(
      path: AppRoutes.avatarSelection,
      pageBuilder: (context, state) =>
          _fadePage(state, const AvatarSelectionScreen()),
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
    GoRoute(
      path: AppRoutes.oddOneOutSetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const OddOneOutSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.oddOneOutGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const OddOneOutGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.patternMatchSetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const PatternMatchSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.patternMatchGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const PatternMatchGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.colorMemorySetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const ColorMemorySetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.colorMemoryGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const ColorMemoryGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.oceanFishSetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const OceanFishSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.oceanFishGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const OceanFishGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.flowerGardenSetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const FlowerGardenSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.flowerGardenGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const FlowerGardenGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.cloudPopGardenSetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const CloudPopGardenSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.cloudPopGardenGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const CloudPopGardenGameScreen()),
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
