import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/game_feedback_banner.dart';
import 'package:my_tiny_thinker/core/widgets/game_session_hud.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/color_memory/controllers/color_memory_controller.dart';
import 'package:my_tiny_thinker/games/color_memory/models/color_memory_models.dart';

class ColorMemoryGameScreen extends ConsumerStatefulWidget {
  const ColorMemoryGameScreen({super.key});

  @override
  ConsumerState<ColorMemoryGameScreen> createState() =>
      _ColorMemoryGameScreenState();
}

class _ColorMemoryGameScreenState extends ConsumerState<ColorMemoryGameScreen> {
  bool _started = false;
  bool _resultShown = false;
  final _particleKey = GlobalKey<ParticleSystemState>();
  AudioService? _audio;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_started) {
        _started = true;
        _beginSession();
      }
    });
  }

  Future<void> _beginSession() async {
    if (!await ensureCanStartGame(context, ref, GameId.colorMemory)) return;
    if (!mounted) return;
    _resultShown = false;
    _audio ??= ref.read(audioServiceProvider);
    _audio?.playGameMusic();
    ref.read(colorMemoryControllerProvider.notifier).start(
          ref.read(colorMemoryConfigProvider),
        );
  }

  @override
  void dispose() {
    _audio?.playHomeMusic();
    super.dispose();
  }

  Future<void> _pause() async {
    await TTPauseDialog.show(
      context,
      onResume: () {},
      onRestart: () {
        _beginSession();
      },
      onHome: () {
        ref.read(colorMemoryControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
    );
  }

  void _showHintMenu() {
    final state = ref.read(colorMemoryControllerProvider);
    if (state.hintsRemaining <= 0 || !state.config.hintsEnabled) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pick a hint', style: context.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const Icon(Icons.replay_10_rounded),
              title: const Text('Replay last 3 colors'),
              onTap: () {
                Navigator.pop(ctx);
                ref
                    .read(colorMemoryControllerProvider.notifier)
                    .useHintReplayLast3();
              },
            ),
            ListTile(
              leading: const Icon(Icons.replay_rounded),
              title: const Text('Replay entire sequence'),
              onTap: () {
                Navigator.pop(ctx);
                ref
                    .read(colorMemoryControllerProvider.notifier)
                    .useHintReplayAll();
              },
            ),
            ListTile(
              leading: const Icon(Icons.lightbulb_rounded),
              title: const Text('Highlight first tile'),
              onTap: () {
                Navigator.pop(ctx);
                ref
                    .read(colorMemoryControllerProvider.notifier)
                    .useHintHighlightFirst();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(colorMemoryControllerProvider);
    final tiles = state.config.theme.tiles;

    ref.listen(colorMemoryControllerProvider, (prev, next) {
      if (next.phase == ColorMemoryPhase.feedback &&
          next.feedbackMessage == 'Awesome!') {
        ref.read(hapticServiceProvider).trigger(HapticType.success);
        ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
      }
      if (next.phase == ColorMemoryPhase.feedback &&
          next.feedbackMessage != null &&
          next.feedbackMessage != 'Awesome!') {
        ref.read(hapticServiceProvider).trigger(HapticType.error);
        ref.read(audioServiceProvider).playSfx(SoundEffect.wrong);
      }
      if (next.phase == ColorMemoryPhase.victory && !_resultShown) {
        _resultShown = true;
        ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
        _particleKey.currentState?.emit();
        ref.read(colorMemoryControllerProvider.notifier).saveResult().then((_) {
          if (!mounted) return;
          _showVictory(
            ref.read(colorMemoryControllerProvider.notifier).getResult(),
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
          body: Stack(
            children: [
              ParticleSystem(key: _particleKey, particleCount: 24, autoStart: false),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      GameSessionHud(
                        remainingSeconds: 0,
                        unlimitedTime: true,
                        coinsEarned: state.score,
                        starsEarned: state.streak,
                        onPause: _pause,
                      ),
                      if (state.config.hintsEnabled)
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Badge(
                              label: Text('${state.hintsRemaining}'),
                              isLabelVisible: state.hintsRemaining > 0,
                              child: const Icon(Icons.lightbulb_outline_rounded),
                            ),
                            onPressed: _showHintMenu,
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      Expanded(
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: state.gridSize,
                                crossAxisSpacing: AppSpacing.sm,
                                mainAxisSpacing: AppSpacing.sm,
                              ),
                              itemCount: state.tileCount,
                              itemBuilder: (context, index) {
                                final isActive = state.activeTile == index;
                                final emoji = tiles[index % tiles.length];
                                return _ColorTile(
                                  emoji: emoji,
                                  isActive: isActive,
                                  enabled: state.phase == ColorMemoryPhase.input,
                                  onTap: () {
                                    ref
                                        .read(colorMemoryControllerProvider
                                            .notifier)
                                        .onTileTap(index);
                                    ref
                                        .read(hapticServiceProvider)
                                        .trigger(HapticType.light);
                                    ref
                                        .read(audioServiceProvider)
                                        .playSfx(SoundEffect.buttonTap);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      if (state.phase == ColorMemoryPhase.showing)
                        Text(
                          'Watch carefully...',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: AppColors.white,
                          ),
                        )
                      else if (state.phase == ColorMemoryPhase.input)
                        Text(
                          'Your turn!',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              GameFeedbackOverlay(
                message: state.feedbackMessage,
                plainMessage: true,
                top: 72,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showVictory(ColorMemoryResult result) async {
    await TTDialog.show(
      context: context,
      title: 'Amazing!',
      emoji: '🎉',
      message:
          'Score: ${result.score}\nStars: ${result.stars}\nCoins: +${result.coins}',
      primaryLabel: 'Play Again',
      secondaryLabel: 'Home',
      primaryAction: () async {
        if (!await ensureCanStartGame(context, ref, GameId.colorMemory)) {
          return;
        }
        if (!mounted) return;
        _resultShown = false;
        ref.read(colorMemoryControllerProvider.notifier).start(
              ref.read(colorMemoryConfigProvider),
            );
      },
      secondaryAction: () {
        ref.read(colorMemoryControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
    );
  }
}

class _ColorTile extends StatelessWidget {
  const _ColorTile({
    required this.emoji,
    required this.isActive,
    required this.enabled,
    required this.onTap,
  });

  final String emoji;
  final bool isActive;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        transform: Matrix4.identity()
          ..scaleByDouble(
            isActive ? 1.08 : 1.0,
            isActive ? 1.08 : 1.0,
            isActive ? 1.08 : 1.0,
            1.0,
          ),
        decoration: BoxDecoration(
          gradient: isActive ? AppGradients.rainbow : AppGradients.welcomeCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? AppColors.candyPink.withValues(alpha: 0.6)
                  : AppColors.skyBlue.withValues(alpha: 0.2),
              blurRadius: isActive ? 20 : 8,
              spreadRadius: isActive ? 2 : 0,
            ),
          ],
        ),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 36)),
        ),
      ),
    );
  }
}
