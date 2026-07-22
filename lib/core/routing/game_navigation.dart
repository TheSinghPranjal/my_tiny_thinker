import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';

void navigateToGame(BuildContext context, GameId gameId) {
  switch (gameId) {
    case GameId.bubbleNumberPop:
      context.push(AppRoutes.bubbleSetup);
    case GameId.ascendingBubbleNumberPop:
      context.push(AppRoutes.ascendingBubbleSetup);
    case GameId.descendingNumberPop:
      context.push(AppRoutes.descendingBubbleSetup);
    case GameId.numberWordPop:
      context.push(AppRoutes.numberWordPopSetup);
    case GameId.classicCardMemory:
      context.push(AppRoutes.classicCardMemorySetup);
    case GameId.completeTheWordAdventure:
      context.push(AppRoutes.completeTheWordSetup);
    case GameId.recallPictureAdventure:
      context.push(AppRoutes.recallPictureSetup);
    case GameId.numberMemory:
      context.push(AppRoutes.numberMemorySetup);
    case GameId.memoryGame:
      context.push(AppRoutes.memoryHub);
    case GameId.oddOneOut:
      context.push(AppRoutes.oddOneOutSetup);
    case GameId.patternMatch:
      context.push(AppRoutes.patternMatchSetup);
    case GameId.colorMemory:
      context.push(AppRoutes.colorMemorySetup);
    case GameId.oceanFishAdventure:
      context.push(AppRoutes.oceanFishSetup);
    case GameId.magicalFlowerGarden:
      context.push(AppRoutes.flowerGardenSetup);
    case GameId.cloudPopGarden:
      context.push(AppRoutes.cloudPopGardenSetup);
    case GameId.peekABooAnimalFriends:
      context.push(AppRoutes.peekABooSetup);
    case GameId.frogPondAdventure:
      context.push(AppRoutes.frogPondSetup);
    case GameId.feedTheFrogAdventure:
      context.push(AppRoutes.feedTheFrogSetup);
    case GameId.hungryMonkeyBananaAdventure:
      context.push(AppRoutes.hungryMonkeySetup);
    case GameId.catchTheButterflyGarden:
      context.push(AppRoutes.butterflyGardenSetup);
    case GameId.catchTheFishAdventure:
      context.push(AppRoutes.catchTheFishSetup);
    case GameId.hungryDuckPondAdventure:
      context.push(AppRoutes.hungryDuckSetup);
    case GameId.hungryTeddyCupcakeParty:
      context.push(AppRoutes.hungryTeddySetup);
    case GameId.bunnyHopAdventure:
      context.push(AppRoutes.bunnyHopSetup);
    case GameId.shadowMatchAdventure:
      context.push(AppRoutes.shadowMatchSetup);
    case GameId.shapeDropAdventure:
      context.push(AppRoutes.shapeDropSetup);
    case GameId.candyColorHunt:
      context.push(AppRoutes.candyColorHuntSetup);
    case GameId.colorSchoolBags:
      context.push(AppRoutes.colorSchoolBagsSetup);
    case GameId.alphabetAdventureQuiz:
      context.push(AppRoutes.alphabetQuizSetup);
    case GameId.animalSounds:
      context.push(AppRoutes.animalSoundsSetup);
    case GameId.alphabetBridgeAdventure:
      context.push(AppRoutes.alphabetBridgeSetup);
    case GameId.numberBridgeAdventure:
      context.push(AppRoutes.numberBridgeSetup);
    case GameId.pictureBridgeAdventure:
      context.push(AppRoutes.pictureBridgeSetup);
    case GameId.colorShapeBridgeAdventure:
      context.push(AppRoutes.colorShapeBridgeSetup);
    case GameId.moonRescueAdventure:
      context.push(AppRoutes.moonRescueSetup);
    case GameId.balloonParade:
      context.push(AppRoutes.balloonParadeSetup);
    case GameId.colorBalloonPop:
      context.push(AppRoutes.colorBalloonPopSetup);
  }
}

/// Shows the free-tier daily play limit dialog.
Future<void> showDailyPlayLimitDialog(BuildContext context) {
  return TTDialog.show(
    context: context,
    title: 'Play Limit Reached',
    emoji: '🌟',
    message:
        'You have played this game $kFreeDailyPlayLimit times today. '
        'TinyThink Premium unlocks unlimited play!',
    primaryLabel: 'See Premium',
    primaryAction: () => context.push(AppRoutes.premium),
    secondaryLabel: 'Maybe Later',
    secondaryAction: () {},
  );
}

/// Returns `true` if [gameId] may start another session right now.
///
/// Call this before every session start (setup Play, first load, Play Again,
/// pause Restart) so free-tier limits cannot be bypassed.
Future<bool> ensureCanStartGame(
  BuildContext context,
  WidgetRef ref,
  GameId gameId,
) async {
  if (canStartGame(ref, gameId)) return true;
  if (!context.mounted) return false;
  await showDailyPlayLimitDialog(context);
  return false;
}

/// Checks daily play limits (free tier) before opening a game's setup screen.
Future<void> navigateToGameGuarded(
  BuildContext context,
  WidgetRef ref,
  GameId gameId,
) async {
  if (!await ensureCanStartGame(context, ref, gameId)) return;
  if (!context.mounted) return;
  navigateToGame(context, gameId);
}

/// Checks daily play limits before pushing a play route (setup → game).
Future<void> pushGameGuarded(
  BuildContext context,
  WidgetRef ref,
  GameId gameId,
  String route, {
  Object? extra,
}) async {
  if (!await ensureCanStartGame(context, ref, gameId)) return;
  if (!context.mounted) return;
  context.push(route, extra: extra);
}

/// Compact premium upgrade chip used on locked surfaces.
class PremiumUpgradeBanner extends StatelessWidget {
  const PremiumUpgradeBanner({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.softPurple.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.lock_rounded, color: AppColors.softPurple, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Available with TinyThink Premium',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.softPurple,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.softPurple),
            ],
          ),
        ),
      ),
    );
  }
}

/// Optional CTA button for premium upgrade.
class PremiumCtaButton extends StatelessWidget {
  const PremiumCtaButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TTButton(
      label: 'Unlock Premium',
      expanded: true,
      onPressed: () => context.push(AppRoutes.premium),
    );
  }
}
