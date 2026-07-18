import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/models/feed_frog_models.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/presentation/widgets/feed_pond_background.dart';

class FeedFrogSetupScreen extends ConsumerWidget {
  const FeedFrogSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FeedPondBackground(
      nightFactor: 0,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🐸🪰',
          emojiSize: 72,
          title: 'Feed the Frog Adventure',
          subtitle: 'Tap the flying bugs and feed the happy frog!',
          skills: kFeedFrogSkills,
          skillChipColor: const Color(0xFFA5D6A7).withValues(alpha: 0.45),
          titleColor: AppColors.white,
          subtitleColor: AppColors.white.withValues(alpha: 0.95),
          titleShadows: const [
            Shadow(color: Color(0xFF2E7D32), blurRadius: 6),
          ],
          onPlay: () => context.push(AppRoutes.feedTheFrogGame),
        ),
      ),
    );
  }
}
