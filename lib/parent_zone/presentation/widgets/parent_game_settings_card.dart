import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/game_config/game_catalog.dart';
import 'package:my_tiny_thinker/core/game_config/game_duration.dart';
import 'package:my_tiny_thinker/core/learning_path/learning_path_provider.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/premium/premium_provider.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_duration_slider.dart';
import 'package:my_tiny_thinker/core/widgets/parent_game_card.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/repository/alphabet_quiz_settings_repository.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/repository/alphabet_bridge_settings_repository.dart';
import 'package:my_tiny_thinker/games/bunny_hop_adventure/repository/bunny_hop_settings_repository.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/repository/candy_color_hunt_settings_repository.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/repository/butterfly_garden_settings_repository.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/repository/cloud_pop_garden_settings_repository.dart';
import 'package:my_tiny_thinker/games/color_school_bags/repository/color_school_bags_settings_repository.dart';
import 'package:my_tiny_thinker/games/color_shape_bridge_adventure/repository/color_shape_bridge_settings_repository.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/repository/feed_frog_settings_repository.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/repository/frog_pond_settings_repository.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/repository/hungry_duck_settings_repository.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/repository/hungry_monkey_settings_repository.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/repository/hungry_teddy_settings_repository.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/repository/flower_garden_settings_repository.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/repository/moon_rescue_settings_repository.dart';
import 'package:my_tiny_thinker/games/number_bridge_adventure/repository/number_bridge_settings_repository.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/repository/ocean_fish_settings_repository.dart';
import 'package:my_tiny_thinker/games/balloon_parade/repository/balloon_parade_settings_repository.dart';
import 'package:my_tiny_thinker/games/color_balloon_pop/repository/color_balloon_pop_settings_repository.dart';
import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/repository/peek_a_boo_animal_friends_settings_repository.dart';
import 'package:my_tiny_thinker/games/picture_bridge_adventure/repository/picture_bridge_settings_repository.dart';
import 'package:my_tiny_thinker/games/shadow_match_adventure/repository/shadow_match_settings_repository.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/repository/shape_drop_settings_repository.dart';

typedef SessionSecondsReader = int Function(WidgetRef ref);
typedef SessionSecondsWriter = void Function(WidgetRef ref, int seconds);

/// Collapsible parent settings shell shared by every game card.
class ParentGameSettingsCard extends ConsumerWidget {
  const ParentGameSettingsCard({
    super.key,
    required this.gameId,
    required this.child,
  });

  final GameId gameId;
  final Widget child;

  static int readSeconds(WidgetRef ref, GameId gameId) {
    return switch (gameId) {
      GameId.candyColorHunt => ref.watch(candyColorHuntSettingsProvider).sessionSeconds,
      GameId.bunnyHopAdventure => ref.watch(bunnyHopSettingsProvider).sessionSeconds,
      GameId.hungryTeddyCupcakeParty =>
        ref.watch(hungryTeddySettingsProvider).sessionSeconds,
      GameId.hungryDuckPondAdventure =>
        ref.watch(hungryDuckSettingsProvider).sessionSeconds,
      GameId.catchTheButterflyGarden =>
        ref.watch(butterflyGardenSettingsProvider).sessionSeconds,
      GameId.hungryMonkeyBananaAdventure =>
        ref.watch(hungryMonkeySettingsProvider).sessionSeconds,
      GameId.feedTheFrogAdventure => ref.watch(feedFrogSettingsProvider).sessionSeconds,
      GameId.frogPondAdventure => ref.watch(frogPondSettingsProvider).sessionSeconds,
      GameId.peekABooAnimalFriends => ref.watch(peekABooSettingsProvider).sessionSeconds,
      GameId.magicalFlowerGarden =>
        ref.watch(flowerGardenSettingsProvider).sessionSeconds,
      GameId.colorSchoolBags =>
        ref.watch(colorSchoolBagsSettingsProvider).sessionSeconds,
      GameId.alphabetBridgeAdventure =>
        ref.watch(alphabetBridgeSettingsProvider).sessionSeconds,
      GameId.numberBridgeAdventure =>
        ref.watch(numberBridgeSettingsProvider).sessionSeconds,
      GameId.pictureBridgeAdventure =>
        ref.watch(pictureBridgeSettingsProvider).sessionSeconds,
      GameId.colorShapeBridgeAdventure =>
        ref.watch(colorShapeBridgeSettingsProvider).sessionSeconds,
      GameId.moonRescueAdventure =>
        ref.watch(moonRescueSettingsProvider).sessionSeconds,
      GameId.shapeDropAdventure => ref.watch(shapeDropSettingsProvider).sessionSeconds,
      GameId.shadowMatchAdventure =>
        ref.watch(shadowMatchSettingsProvider).sessionSeconds,
      GameId.alphabetAdventureQuiz =>
        ref.watch(alphabetQuizSettingsProvider).sessionSeconds,
      GameId.cloudPopGarden =>
        ref.watch(cloudPopGardenSettingsProvider).sessionSeconds,
      GameId.oceanFishAdventure => ref.watch(oceanFishSettingsProvider).sessionSeconds,
      GameId.balloonParade =>
        ref.watch(balloonParadeSettingsProvider).sessionSeconds,
      GameId.colorBalloonPop =>
        ref.watch(colorBalloonPopSettingsProvider).sessionSeconds,
      _ => GameDuration.defaultSeconds,
    };
  }

  static void writeSeconds(WidgetRef ref, GameId gameId, int seconds) {
    final snapped = GameDuration.snap(seconds);
    switch (gameId) {
      case GameId.candyColorHunt:
        ref.read(candyColorHuntSettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      case GameId.bunnyHopAdventure:
        ref.read(bunnyHopSettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      case GameId.hungryTeddyCupcakeParty:
        ref.read(hungryTeddySettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      case GameId.hungryDuckPondAdventure:
        ref.read(hungryDuckSettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      case GameId.catchTheButterflyGarden:
        ref.read(butterflyGardenSettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      case GameId.hungryMonkeyBananaAdventure:
        ref.read(hungryMonkeySettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      case GameId.feedTheFrogAdventure:
        ref.read(feedFrogSettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      case GameId.frogPondAdventure:
        ref.read(frogPondSettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      case GameId.peekABooAnimalFriends:
        ref.read(peekABooSettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      case GameId.magicalFlowerGarden:
        ref.read(flowerGardenSettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      case GameId.colorSchoolBags:
        ref.read(colorSchoolBagsSettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      case GameId.alphabetBridgeAdventure:
        ref.read(alphabetBridgeSettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      case GameId.numberBridgeAdventure:
        ref.read(numberBridgeSettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      case GameId.pictureBridgeAdventure:
        ref.read(pictureBridgeSettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      case GameId.colorShapeBridgeAdventure:
        ref.read(colorShapeBridgeSettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      case GameId.moonRescueAdventure:
        ref.read(moonRescueSettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      case GameId.shapeDropAdventure:
        ref.read(shapeDropSettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      case GameId.shadowMatchAdventure:
        ref.read(shadowMatchSettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      case GameId.alphabetAdventureQuiz:
        ref.read(alphabetQuizSettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      case GameId.cloudPopGarden:
        ref.read(cloudPopGardenSettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      case GameId.oceanFishAdventure:
        ref.read(oceanFishSettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      case GameId.balloonParade:
        ref.read(balloonParadeSettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      case GameId.colorBalloonPop:
        ref.read(colorBalloonPopSettingsProvider.notifier)
            .patch((x) => x.copyWith(sessionSeconds: snapped));
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = GameCatalog.entryFor(gameId);
    if (entry == null) return child;

    final isPremium = ref.watch(isPremiumProvider);
    final inPath = ref.watch(learningPathPrefsProvider).isIncluded(gameId);
    final durationSeconds = readSeconds(ref, gameId);
    final accent = AppColors
        .gameCardColors[gameId.index % AppColors.gameCardColors.length];

    return ParentGameCard(
      entry: entry,
      durationSeconds: durationSeconds,
      inLearningPath: inPath,
      playsLabel: playsLabel(ref, gameId),
      isPremium: isPremium,
      accent: accent,
      expandedChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameDurationSlider(
            sessionSeconds: durationSeconds,
            enabled: isPremium,
            onChanged: (secs) => writeSeconds(ref, gameId, secs),
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Include in Learning Path',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text('Play during automatic Learning Path sessions'),
            value: inPath,
            activeThumbColor: AppColors.grassGreen,
            onChanged: isPremium
                ? (v) => ref
                    .read(learningPathPrefsProvider.notifier)
                    .setIncluded(gameId, v)
                : null,
          ),
          const Divider(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}
