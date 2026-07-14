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
import 'package:my_tiny_thinker/core/widgets/game_feedback_banner.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
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
  bool _resultShown = false;
  final GlobalKey<ParticleSystemState> _particleKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initGame());

    ref.listenManual(bubbleGameControllerProvider, (prev, next) {
      _onGameStateChanged(prev, next);
    });
  }

  Future<void> _initGame() async {
    _resultShown = false;
    ref.read(bubbleGameControllerProvider.notifier).reset();
    await ref.read(bubbleGameControllerProvider.notifier).startGame();
    _syncTicker(ref.read(bubbleGameControllerProvider).phase);
    ref.read(audioServiceProvider).playMusic(asset: 'audio/ambient_music.mp3');
  }

  void _syncTicker(GamePhase phase) {
    if (phase == GamePhase.playing) {
      _ticker ??= createTicker((_) {
        ref.read(bubbleGameControllerProvider.notifier).tick();
      });
      if (!_ticker!.isActive) _ticker!.start();
    } else {
      _ticker?.stop();
    }
  }

  void _onGameStateChanged(BubbleGameState? prev, BubbleGameState next) {
    _syncTicker(next.phase);
    _checkGameEnd(next);
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
      onRestart: () => _initGame(),
      onHome: () {
        ref.read(bubbleGameControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
    );
    return false;
  }

  void _handleBubbleTap(String bubbleId, BubbleEntity bubble) {
    final result =
        ref.read(bubbleGameControllerProvider.notifier).tapBubble(bubbleId);

    if (result == BubbleTapResult.correct) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.bubblePop);
      ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
      ref.read(hapticServiceProvider).trigger(HapticType.light);
      _particleKey.currentState?.emit(
        origin: Offset(bubble.x, bubble.y),
      );
      final combo = ref.read(bubbleGameControllerProvider).combo;
      if (combo >= 2) {
        ref.read(audioServiceProvider).playSfx(SoundEffect.combo);
      }
      ref.read(audioServiceProvider).playSfx(SoundEffect.coin);
    } else if (result == BubbleTapResult.wrong) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.wrong);
      ref.read(hapticServiceProvider).trigger(HapticType.selection);
    }
  }

  Future<void> _checkGameEnd(BubbleGameState state) async {
    if (_resultShown) return;
    if (state.phase != GamePhase.victory && state.phase != GamePhase.gameOver) {
      return;
    }

    _resultShown = true;
    _ticker?.stop();
    ref.read(audioServiceProvider).playSfx(
          state.phase == GamePhase.victory
              ? SoundEffect.victory
              : SoundEffect.wrong,
        );
    ref.read(hapticServiceProvider).trigger(HapticType.success);

    final controller = ref.read(bubbleGameControllerProvider.notifier);
    final result = controller.getResult();
    await controller.saveResult(result);

    if (!mounted) return;
    VictoryDialog.show(
      context,
      result: result,
      onPlayAgain: () => _initGame(),
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
                  toddlerMode: false,
                ),
              );
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
    final phase = ref.watch(
      bubbleGameControllerProvider.select((s) => s.phase),
    );
    final toddlerMode = ref.watch(
      bubbleGameControllerProvider.select((s) => s.config.toddlerMode),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _onWillPop();
      },
      child: AnimatedSkyBackground(
        showGrass: toddlerMode,
        showElements: true,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _GameHeader(
                      toddlerMode: toddlerMode,
                      onPause: _onWillPop,
                    ),
                    const _GameHudSection(),
                    Expanded(
                      child: _BubblePlayArea(
                        particleKey: _particleKey,
                        onTap: _handleBubbleTap,
                      ),
                    ),
                    if (toddlerMode)
                      const Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: MascotWidget(size: 56, waving: true),
                      ),
                  ],
                ),
                if (toddlerMode)
                  GameFeedbackOverlay(
                    message: ref.watch(
                      bubbleGameControllerProvider
                          .select((s) => s.feedbackMessage),
                    ),
                    top: 96,
                  ),
                if (phase == GamePhase.countdown)
                  const Positioned.fill(child: _CountdownLayer()),
                if (phase == GamePhase.paused)
                  const Positioned.fill(child: _PausedLayer()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameHeader extends ConsumerWidget {
  const _GameHeader({required this.toddlerMode, required this.onPause});

  final bool toddlerMode;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = ref.watch(
      bubbleGameControllerProvider.select((s) => s.targetNumber),
    );
    final sortMode = ref.watch(
      bubbleGameControllerProvider.select((s) => s.config.sortMode),
    );
    final remaining = ref.watch(
      bubbleGameControllerProvider.select((s) => s.remainingSeconds),
    );
    final toddler = ref.watch(
      bubbleGameControllerProvider.select((s) => s.config.toddlerMode),
    );
    final timed = ref.watch(
      bubbleGameControllerProvider.select(
        (s) => s.config.timerMode == TimerMode.timed || s.config.toddlerMode,
      ),
    );

    return Padding(
      padding: EdgeInsets.all(toddlerMode ? AppSpacing.sm : AppSpacing.md),
      child: Row(
        children: [
          if (!toddlerMode)
            IconButton(
              icon: const Icon(Icons.pause_rounded),
              onPressed: onPause,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.white.withValues(alpha: 0.85),
              ),
            ),
          Expanded(
            child: Center(
              child: TargetNumberCard(
                targetNumber: target,
                sortMode: sortMode,
                toddlerMode: toddler,
                large: toddlerMode,
              ),
            ),
          ),
          if (timed)
            GameTimerBadge(seconds: remaining, large: toddlerMode)
          else
            SizedBox(width: toddlerMode ? 0 : 48),
          if (toddlerMode)
            IconButton(
              icon: const Icon(Icons.home_rounded, size: 32),
              onPressed: onPause,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.white.withValues(alpha: 0.85),
              ),
            ),
        ],
      ),
    );
  }
}

class _GameHudSection extends ConsumerWidget {
  const _GameHudSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(
      bubbleGameControllerProvider.select((s) => s.currentIndex),
    );
    final total = ref.watch(
      bubbleGameControllerProvider.select((s) => s.total),
    );
    final score = ref.watch(
      bubbleGameControllerProvider.select((s) => s.score),
    );
    final combo = ref.watch(
      bubbleGameControllerProvider.select((s) => s.combo),
    );
    final lastPoints = ref.watch(
      bubbleGameControllerProvider.select((s) => s.lastPointsEarned),
    );
    final toddler = ref.watch(
      bubbleGameControllerProvider.select((s) => s.config.toddlerMode),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GameHudBar(
        current: current,
        total: total,
        score: score,
        combo: combo,
        lastPointsEarned: lastPoints,
        toddlerMode: toddler,
      ),
    );
  }
}

class _BubblePlayArea extends ConsumerWidget {
  const _BubblePlayArea({
    required this.particleKey,
    required this.onTap,
  });

  final GlobalKey<ParticleSystemState> particleKey;
  final void Function(String id, BubbleEntity bubble) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bubbles = ref.watch(
      bubbleGameControllerProvider.select((s) => s.bubbles),
    );
    final showHint = ref.watch(
      bubbleGameControllerProvider.select((s) => s.showHint),
    );
    final target = ref.watch(
      bubbleGameControllerProvider.select((s) => s.targetNumber),
    );
    final toddler = ref.watch(
      bubbleGameControllerProvider.select((s) => s.config.toddlerMode),
    );

    String? hintBubbleId;
    if (showHint && target != null) {
      for (final b in bubbles) {
        if (b.number == target && !b.isPopping) {
          hintBubbleId = b.id;
          break;
        }
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(bubbleGameControllerProvider.notifier).setPlayArea(
                Size(constraints.maxWidth, constraints.maxHeight),
              );
        });

        return ClipRect(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              ...bubbles.map(
                (bubble) => BubbleWidget(
                  key: ValueKey(bubble.id),
                  bubble: bubble,
                  showHint: bubble.id == hintBubbleId,
                  toddlerMode: toddler,
                  onTap: () => onTap(bubble.id, bubble),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: ParticleSystem(
                    key: particleKey,
                    particleCount: toddler ? 32 : 24,
                    autoStart: false,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CountdownLayer extends ConsumerWidget {
  const _CountdownLayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(
      bubbleGameControllerProvider.select((s) => s.countdown),
    );
    return CountdownOverlay(count: count);
  }
}

class _PausedLayer extends StatelessWidget {
  const _PausedLayer();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: AppColors.skyBlueDark.withValues(alpha: 0.5),
        child: const Center(
          child: Text(
            'Paused',
            style: TextStyle(color: AppColors.white, fontSize: 32),
          ),
        ),
      ),
    );
  }
}
