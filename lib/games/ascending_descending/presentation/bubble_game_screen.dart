import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/ascending_descending/controllers/bubble_game_controller.dart';
import 'package:my_tiny_thinker/games/ascending_descending/logic/bubble_game_logic.dart';
import 'package:my_tiny_thinker/games/ascending_descending/models/bubble_game_models.dart';
import 'package:my_tiny_thinker/games/ascending_descending/presentation/widgets/bubble_widget.dart';
import 'package:my_tiny_thinker/games/ascending_descending/presentation/widgets/game_hud_widgets.dart';
import 'package:my_tiny_thinker/games/ascending_descending/presentation/widgets/victory_dialog.dart';

class BubbleGameScreen extends ConsumerStatefulWidget {
  const BubbleGameScreen({super.key});

  @override
  ConsumerState<BubbleGameScreen> createState() => _BubbleGameScreenState();
}

class _BubbleGameScreenState extends ConsumerState<BubbleGameScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  Ticker? _ticker;
  final GlobalKey _playAreaKey = GlobalKey();
  bool _resultShown = false;
  String? _hintBubbleId;
  final GlobalKey<ParticleSystemState> _particleKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initGame();
    });
  }

  Future<void> _initGame() async {
    ref.read(bubbleGameControllerProvider.notifier).reset();
    _measurePlayArea();
    await ref.read(bubbleGameControllerProvider.notifier).startGame();
    _startTicker();
    ref.read(audioServiceProvider).playMusic(asset: 'audio/ambient_music.mp3');
  }

  void _measurePlayArea() {
    final box = _playAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      ref.read(bubbleGameControllerProvider.notifier).setPlayArea(box.size);
    }
  }

  void _startTicker() {
    _ticker?.dispose();
    _ticker = createTicker((_) {
      ref.read(bubbleGameControllerProvider.notifier).tick();
    });
    _ticker!.start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(bubbleGameControllerProvider.notifier).pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.dispose();
    ref.read(audioServiceProvider).stopMusic();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    ref.read(bubbleGameControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () => ref.read(bubbleGameControllerProvider.notifier).resume(),
      onRestart: () {
        _resultShown = false;
        _initGame();
      },
      onHome: () {
        ref.read(bubbleGameControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
    );
    return false;
  }

  void _handleBubbleTap(String bubbleId, BubbleEntity bubble) {
    final state = ref.read(bubbleGameControllerProvider);
    final target = state.targetNumber;

    ref.read(bubbleGameControllerProvider.notifier).tapBubble(bubbleId);

    if (target != null && bubble.number == target) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.bubblePop);
      ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
      ref.read(hapticServiceProvider).trigger(HapticType.success);
      _particleKey.currentState?.emit(
        origin: Offset(bubble.x, bubble.y),
      );
      if (state.combo >= 1) {
        ref.read(audioServiceProvider).playSfx(SoundEffect.combo);
      }
    } else {
      ref.read(audioServiceProvider).playSfx(SoundEffect.wrong);
      ref.read(hapticServiceProvider).trigger(HapticType.error);
    }
  }

  void _checkGameEnd(BubbleGameState state) {
    if (_resultShown) return;
    if (state.phase != GamePhase.victory && state.phase != GamePhase.gameOver) {
      return;
    }

    _resultShown = true;
    _ticker?.stop();
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    ref.read(hapticServiceProvider).trigger(HapticType.heavy);

    final controller = ref.read(bubbleGameControllerProvider.notifier);
    final result = controller.getResult();
    controller.saveResult(result);

    VictoryDialog.show(
      context,
      result: result,
      onPlayAgain: () {
        _resultShown = false;
        _initGame();
      },
      onHome: () {
        controller.reset();
        context.go(AppRoutes.home);
      },
      onNextDifficulty: _canIncreaseDifficulty(state.config.difficulty)
          ? () {
              final next = _nextDifficulty(state.config.difficulty);
              final range =
                  BubbleNumberGenerator.defaultRangeForDifficulty(next);
              controller.updateConfig(
                state.config.copyWith(
                  difficulty: next,
                  minValue: range.$1,
                  maxValue: range.$2,
                  bubbleSpeed:
                      BubbleNumberGenerator.speedForDifficulty(next),
                ),
              );
              _resultShown = false;
              _initGame();
            }
          : null,
    );
  }

  bool _canIncreaseDifficulty(Difficulty d) => d != Difficulty.expert;

  Difficulty _nextDifficulty(Difficulty d) {
    final index = Difficulty.values.indexOf(d);
    if (index < Difficulty.values.length - 1) {
      return Difficulty.values[index + 1];
    }
    return d;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bubbleGameControllerProvider);

    ref.listen(bubbleGameControllerProvider, (prev, next) {
      if (next.showHint && next.targetNumber != null) {
        final targetBubble = next.bubbles.cast<BubbleEntity?>().firstWhere(
              (b) => b!.number == next.targetNumber && !b.isPopping,
              orElse: () => null,
            );
        setState(() => _hintBubbleId = targetBubble?.id);
      } else if (!next.showHint) {
        setState(() => _hintBubbleId = null);
      }
      _checkGameEnd(next);
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _onWillPop();
      },
      child: AnimatedSkyBackground(
        showGrass: false,
        showElements: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.pause_rounded),
                        onPressed: _onWillPop,
                        style: IconButton.styleFrom(
                          backgroundColor:
                              AppColors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const Spacer(),
                      TargetNumberCard(
                        targetNumber: state.targetNumber,
                        sortMode: state.config.sortMode,
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: GameHudBar(
                    current: state.currentIndex,
                    total: state.total,
                    score: state.score,
                    combo: state.combo,
                    remainingSeconds: state.remainingSeconds,
                    timerMode: state.config.timerMode,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref
                            .read(bubbleGameControllerProvider.notifier)
                            .setPlayArea(Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ));
                      });
                      return Stack(
                        key: _playAreaKey,
                        clipBehavior: Clip.none,
                        children: [
                          ...state.bubbles.map(
                            (bubble) => BubbleWidget(
                              key: ValueKey(bubble.id),
                              bubble: bubble,
                              showHint: bubble.id == _hintBubbleId,
                              onTap: () => _handleBubbleTap(bubble.id, bubble),
                            ),
                          ),
                          ParticleSystem(
                            key: _particleKey,
                            particleCount: 24,
                            autoStart: false,
                          ),
                          if (state.phase == GamePhase.countdown)
                            CountdownOverlay(count: state.countdown),
                          if (state.phase == GamePhase.paused)
                            Container(
                              color: AppColors.skyBlueDark.withValues(alpha: 0.5),
                              child: const Center(
                                child: Text(
                                  'Paused',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 32,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
