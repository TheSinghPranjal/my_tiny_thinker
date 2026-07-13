import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/animations/bounce_animation.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/odd_one_out/controllers/odd_one_out_controller.dart';
import 'package:my_tiny_thinker/games/odd_one_out/logic/odd_one_out_logic.dart';
import 'package:my_tiny_thinker/games/odd_one_out/models/odd_one_out_models.dart';

class OddOneOutGameScreen extends ConsumerStatefulWidget {
  const OddOneOutGameScreen({super.key});

  @override
  ConsumerState<OddOneOutGameScreen> createState() => _OddOneOutGameScreenState();
}

class _OddOneOutGameScreenState extends ConsumerState<OddOneOutGameScreen> {
  bool _started = false;
  bool _resultShown = false;
  final _particleKey = GlobalKey<ParticleSystemState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_started) {
        _started = true;
        ref.read(oddOneOutControllerProvider.notifier).start(
              ref.read(oddOneOutConfigProvider),
            );
      }
    });
  }

  Future<void> _pause() async {
    await TTPauseDialog.show(
      context,
      onResume: () {},
      onRestart: () {
        _resultShown = false;
        ref.read(oddOneOutControllerProvider.notifier).start(
              ref.read(oddOneOutConfigProvider),
            );
      },
      onHome: () {
        ref.read(oddOneOutControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(oddOneOutControllerProvider);

    ref.listen(oddOneOutControllerProvider, (prev, next) {
      if (next.phase == OddOnePhase.victory && !_resultShown) {
        _resultShown = true;
        ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
        ref.read(oddOneOutControllerProvider.notifier).saveResult().then((_) {
          if (!mounted) return;
          _showVictory(
            ref.read(oddOneOutControllerProvider.notifier).getResult(),
          );
        });
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _pause();
      },
      child: AnimatedSkyBackground(
        showGrass: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.pause_rounded),
              onPressed: _pause,
            ),
            title: Text('Round ${state.round}/${state.roundsTarget}'),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Chip('⭐ ${state.score}', AppColors.sunYellow),
                      _Chip('🔥 ${state.streak}', AppColors.candyPink),
                      if (OddOneOutScoring.streakLabel(state.streak).isNotEmpty)
                        Text(
                          OddOneOutScoring.streakLabel(state.streak),
                          style: context.textTheme.labelMedium?.copyWith(
                            color: AppColors.lavender,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Tap the odd one out!', style: context.textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: Stack(
                      children: [
                        GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: state.gridSize,
                            crossAxisSpacing: AppSpacing.sm,
                            mainAxisSpacing: AppSpacing.sm,
                          ),
                          itemCount: state.items.length,
                          itemBuilder: (context, i) {
                            final item = state.items[i];
                            return _OddItemTile(
                              item: item,
                              isWrong: state.wrongItemId == item.id,
                              showHint: state.showHint && item.isOdd,
                              onTap: () {
                                if (item.isOdd) {
                                  ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
                                  ref.read(hapticServiceProvider).trigger(HapticType.success);
                                  _particleKey.currentState?.emit();
                                } else {
                                  ref.read(audioServiceProvider).playSfx(SoundEffect.wrong);
                                  ref.read(hapticServiceProvider).trigger(HapticType.error);
                                }
                                ref.read(oddOneOutControllerProvider.notifier).selectItem(item.id);
                              },
                            );
                          },
                        ),
                        ParticleSystem(
                          key: _particleKey,
                          particleCount: 20,
                          autoStart: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showVictory(OddOneOutResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        title: Text(result.isPerfect ? 'Perfect!' : 'Great Job!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Score: ${result.score}'),
            Text('Stars: ${'⭐' * result.stars}'),
            Text('Coins: +${result.coins}'),
            Text('Best Streak: ${result.longestStreak}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(oddOneOutControllerProvider.notifier).reset();
              context.pop();
            },
            child: const Text('Home'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resultShown = false;
              ref.read(oddOneOutControllerProvider.notifier).start(
                    ref.read(oddOneOutConfigProvider),
                  );
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }
}

class _OddItemTile extends StatelessWidget {
  const _OddItemTile({
    required this.item,
    required this.onTap,
    this.isWrong = false,
    this.showHint = false,
  });

  final OddOneItem item;
  final VoidCallback onTap;
  final bool isWrong;
  final bool showHint;

  @override
  Widget build(BuildContext context) {
    return ShakeAnimation(
      trigger: isWrong,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: AppGradients.welcomeCard,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isWrong
                  ? AppColors.error
                  : showHint
                      ? AppColors.sunYellow
                      : AppColors.white,
              width: showHint || isWrong ? 3 : 2,
            ),
            boxShadow: showHint
                ? [
                    BoxShadow(
                      color: AppColors.sunYellow.withValues(alpha: 0.6),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Transform.rotate(
              angle: item.rotation,
              child: Transform.scale(
                scale: item.scale,
                child: Text(
                  item.display,
                  style: TextStyle(fontSize: context.isTablet ? 40 : 32),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
      ),
      child: Text(label, style: context.textTheme.labelMedium),
    );
  }
}
