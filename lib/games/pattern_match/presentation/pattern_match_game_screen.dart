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
import 'package:my_tiny_thinker/core/widgets/game_paused_overlay.dart';
import 'package:my_tiny_thinker/core/widgets/game_session_hud.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/pattern_match/controllers/pattern_match_controller.dart';
import 'package:my_tiny_thinker/games/pattern_match/models/pattern_match_models.dart';
import 'package:my_tiny_thinker/games/pattern_match/presentation/widgets/pattern_match_hud.dart';
import 'package:my_tiny_thinker/games/pattern_match/repository/pattern_match_settings_repository.dart';

class PatternMatchGameScreen extends ConsumerStatefulWidget {
  const PatternMatchGameScreen({super.key});

  @override
  ConsumerState<PatternMatchGameScreen> createState() =>
      _PatternMatchGameScreenState();
}

class _PatternMatchGameScreenState extends ConsumerState<PatternMatchGameScreen>
    with WidgetsBindingObserver {
  bool _saved = false;
  final _particleKey = GlobalKey<ParticleSystemState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(patternMatchControllerProvider, (prev, next) {
      if (next.phase == PatternPhase.finished && !_saved) {
        _onFinished();
      }
      if (next.showSparkles) {
        _particleKey.currentState?.emit();
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(patternMatchSettingsProvider);
    ref.read(patternMatchControllerProvider.notifier).reset();
    ref.read(patternMatchControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playGameMusic();
    }
  }

  Future<void> _onFinished() async {
    _saved = true;
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    await ref.read(patternMatchControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(patternMatchControllerProvider.notifier).pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(audioServiceProvider).playHomeMusic();
    super.dispose();
  }

  Future<void> _showPauseMenu() async {
    ref.read(patternMatchControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () => ref.read(patternMatchControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(patternMatchControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(patternMatchControllerProvider);
    final settings = ref.watch(patternMatchSettingsProvider);
    final phase = state.phase;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && phase != PatternPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: AnimatedSkyBackground(
        showGrass: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      GameSessionHud(
                        remainingSeconds: state.remainingSeconds,
                        coinsEarned: state.score,
                        starsEarned: state.streak,
                        onPause: _showPauseMenu,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TTCard(
                        gradient: AppGradients.bubblePurple,
                        child: Column(
                          children: [
                            Text(
                              'What comes next?',
                              style: context.textTheme.titleMedium?.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              spacing: AppSpacing.md,
                              alignment: WrapAlignment.center,
                              children: state.sequence.asMap().entries.map((e) {
                                final isMissing = e.key == state.missingIndex;
                                final tile = Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withValues(alpha: 0.9),
                                    borderRadius:
                                        BorderRadius.circular(AppSpacing.radiusMd),
                                  ),
                                  child: Center(
                                    child: Text(
                                      e.value,
                                      style: TextStyle(
                                        fontSize: isMissing ? 28 : 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                                if (settings.reducedMotion) return tile;
                                return PulseAnimation(child: tile);
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text('Pick the answer:', style: context.textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.md),
                      Expanded(
                        child: Stack(
                          children: [
                            Wrap(
                              spacing: AppSpacing.md,
                              runSpacing: AppSpacing.md,
                              alignment: WrapAlignment.center,
                              children: state.options.map((opt) {
                                final isWrong = state.wrongOptionId == opt.id;
                                final optionTile = Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: AppGradients.welcomeCard,
                                    borderRadius:
                                        BorderRadius.circular(AppSpacing.radiusLg),
                                    border: Border.all(
                                      color: isWrong
                                          ? AppColors.error
                                          : AppColors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      opt.display,
                                      style: const TextStyle(fontSize: 36),
                                    ),
                                  ),
                                );
                                final wrapped = settings.reducedMotion
                                    ? optionTile
                                    : ShakeAnimation(
                                        trigger: isWrong,
                                        child: optionTile,
                                      );
                                return BounceTapWrapper(
                                  onTap: () {
                                    if (settings.soundEnabled) {
                                      if (opt.id == state.correctOptionId) {
                                        ref
                                            .read(audioServiceProvider)
                                            .playSfx(SoundEffect.correct);
                                      } else {
                                        ref
                                            .read(audioServiceProvider)
                                            .playSfx(SoundEffect.wrong);
                                      }
                                    }
                                    if (settings.hapticsEnabled) {
                                      if (opt.id == state.correctOptionId) {
                                        ref
                                            .read(hapticServiceProvider)
                                            .trigger(HapticType.success);
                                      } else {
                                        ref
                                            .read(hapticServiceProvider)
                                            .trigger(HapticType.error);
                                      }
                                    }
                                    ref
                                        .read(patternMatchControllerProvider.notifier)
                                        .selectOption(opt.id);
                                  },
                                  child: wrapped,
                                );
                              }).toList(),
                            ),
                            IgnorePointer(
                              child: ParticleSystem(
                                key: _particleKey,
                                particleCount: 20,
                                autoStart: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (phase == PatternPhase.paused)
                  GamePausedOverlay(
                    onResume: () =>
                        ref.read(patternMatchControllerProvider.notifier).resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (phase == PatternPhase.finished)
                  PatternMatchVictoryOverlay(
                    result: ref
                        .read(patternMatchControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref.read(patternMatchControllerProvider.notifier).reset();
                      context.go(AppRoutes.home);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
