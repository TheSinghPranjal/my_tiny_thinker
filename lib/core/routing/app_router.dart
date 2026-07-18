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
import 'package:my_tiny_thinker/games/shadow_match_adventure/presentation/shadow_match_setup_screen.dart';
import 'package:my_tiny_thinker/games/shadow_match_adventure/presentation/shadow_match_game_screen.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/presentation/shape_drop_setup_screen.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/presentation/shape_drop_game_screen.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/presentation/candy_color_hunt_setup_screen.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/presentation/candy_color_hunt_game_screen.dart';
import 'package:my_tiny_thinker/games/color_school_bags/presentation/color_school_bags_setup_screen.dart';
import 'package:my_tiny_thinker/games/color_school_bags/presentation/color_school_bags_game_screen.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/presentation/alphabet_quiz_setup_screen.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/presentation/alphabet_quiz_game_screen.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/presentation/alphabet_bridge_setup_screen.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/presentation/alphabet_bridge_game_screen.dart';
import 'package:my_tiny_thinker/games/number_bridge_adventure/presentation/number_bridge_setup_screen.dart';
import 'package:my_tiny_thinker/games/number_bridge_adventure/presentation/number_bridge_game_screen.dart';
import 'package:my_tiny_thinker/games/picture_bridge_adventure/presentation/picture_bridge_setup_screen.dart';
import 'package:my_tiny_thinker/games/picture_bridge_adventure/presentation/picture_bridge_game_screen.dart';
import 'package:my_tiny_thinker/games/color_shape_bridge_adventure/presentation/color_shape_bridge_setup_screen.dart';
import 'package:my_tiny_thinker/games/color_shape_bridge_adventure/presentation/color_shape_bridge_game_screen.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/presentation/moon_rescue_setup_screen.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/presentation/moon_rescue_game_screen.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/presentation/cloud_pop_garden_setup_screen.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/presentation/cloud_pop_garden_game_screen.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/presentation/flower_garden_setup_screen.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/presentation/flower_garden_game_screen.dart';
import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/presentation/peek_a_boo_animal_friends_setup_screen.dart';
import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/presentation/peek_a_boo_animal_friends_game_screen.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/presentation/frog_pond_setup_screen.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/presentation/frog_pond_game_screen.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/presentation/feed_frog_setup_screen.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/presentation/feed_frog_game_screen.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/presentation/hungry_monkey_setup_screen.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/presentation/hungry_monkey_game_screen.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/presentation/butterfly_garden_setup_screen.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/presentation/butterfly_garden_game_screen.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/presentation/hungry_duck_setup_screen.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/presentation/hungry_duck_game_screen.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/presentation/hungry_teddy_setup_screen.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/presentation/hungry_teddy_game_screen.dart';
import 'package:my_tiny_thinker/games/bunny_hop_adventure/presentation/bunny_hop_setup_screen.dart';
import 'package:my_tiny_thinker/games/bunny_hop_adventure/presentation/bunny_hop_game_screen.dart';
import 'package:my_tiny_thinker/premium/presentation/premium_subscription_screen.dart';
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
  static const premium = '/premium';
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
  static const peekABooSetup = '/games/peek-a-boo/setup';
  static const peekABooGame = '/games/peek-a-boo/play';
  static const frogPondSetup = '/games/frog-pond/setup';
  static const frogPondGame = '/games/frog-pond/play';
  static const feedTheFrogSetup = '/games/feed-the-frog/setup';
  static const feedTheFrogGame = '/games/feed-the-frog/play';
  static const hungryMonkeySetup = '/games/hungry-monkey/setup';
  static const hungryMonkeyGame = '/games/hungry-monkey/play';
  static const butterflyGardenSetup = '/games/butterfly-garden/setup';
  static const butterflyGardenGame = '/games/butterfly-garden/play';
  static const hungryDuckSetup = '/games/hungry-duck/setup';
  static const hungryDuckGame = '/games/hungry-duck/play';
  static const hungryTeddySetup = '/games/hungry-teddy/setup';
  static const hungryTeddyGame = '/games/hungry-teddy/play';
  static const bunnyHopSetup = '/games/bunny-hop/setup';
  static const bunnyHopGame = '/games/bunny-hop/play';
  static const shadowMatchSetup = '/games/shadow-match/setup';
  static const shadowMatchGame = '/games/shadow-match/play';
  static const shapeDropSetup = '/games/shape-drop/setup';
  static const shapeDropGame = '/games/shape-drop/play';
  static const candyColorHuntSetup = '/games/candy-color-hunt/setup';
  static const candyColorHuntGame = '/games/candy-color-hunt/play';
  static const colorSchoolBagsSetup = '/games/color-school-bags/setup';
  static const colorSchoolBagsGame = '/games/color-school-bags/play';
  static const alphabetQuizSetup = '/games/alphabet-adventure/setup';
  static const alphabetQuizGame = '/games/alphabet-adventure/play';
  static const alphabetBridgeSetup = '/games/alphabet-bridge/setup';
  static const alphabetBridgeGame = '/games/alphabet-bridge/play';
  static const numberBridgeSetup = '/games/number-bridge/setup';
  static const numberBridgeGame = '/games/number-bridge/play';
  static const pictureBridgeSetup = '/games/picture-bridge/setup';
  static const pictureBridgeGame = '/games/picture-bridge/play';
  static const colorShapeBridgeSetup = '/games/color-shape-bridge/setup';
  static const colorShapeBridgeGame = '/games/color-shape-bridge/play';
  static const moonRescueSetup = '/games/moon-rescue/setup';
  static const moonRescueGame = '/games/moon-rescue/play';
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
      path: AppRoutes.premium,
      pageBuilder: (context, state) =>
          _fadePage(state, const PremiumSubscriptionScreen()),
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
    GoRoute(
      path: AppRoutes.peekABooSetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const PeekABooSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.peekABooGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const PeekABooGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.frogPondSetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const FrogPondSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.frogPondGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const FrogPondGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.feedTheFrogSetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const FeedFrogSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.feedTheFrogGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const FeedFrogGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.hungryMonkeySetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const HungryMonkeySetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.hungryMonkeyGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const HungryMonkeyGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.butterflyGardenSetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const ButterflyGardenSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.butterflyGardenGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const ButterflyGardenGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.hungryDuckSetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const HungryDuckSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.hungryDuckGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const HungryDuckGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.hungryTeddySetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const HungryTeddySetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.hungryTeddyGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const HungryTeddyGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.bunnyHopSetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const BunnyHopSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.bunnyHopGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const BunnyHopGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.shadowMatchSetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const ShadowMatchSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.shadowMatchGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const ShadowMatchGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.shapeDropSetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const ShapeDropSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.shapeDropGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const ShapeDropGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.candyColorHuntSetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const CandyColorHuntSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.candyColorHuntGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const CandyColorHuntGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.colorSchoolBagsSetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const ColorSchoolBagsSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.colorSchoolBagsGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const ColorSchoolBagsGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.alphabetQuizSetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const AlphabetQuizSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.alphabetQuizGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const AlphabetQuizGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.alphabetBridgeSetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const AlphabetBridgeSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.alphabetBridgeGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const AlphabetBridgeGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.numberBridgeSetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const NumberBridgeSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.numberBridgeGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const NumberBridgeGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.pictureBridgeSetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const PictureBridgeSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.pictureBridgeGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const PictureBridgeGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.colorShapeBridgeSetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const ColorShapeBridgeSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.colorShapeBridgeGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const ColorShapeBridgeGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.moonRescueSetup,
      pageBuilder: (context, state) =>
          _slidePage(state, const MoonRescueSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.moonRescueGame,
      pageBuilder: (context, state) =>
          _slidePage(state, const MoonRescueGameScreen()),
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
