import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/widgets/game_feedback_banner.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/core/widgets/game_paused_overlay.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/presentation/widgets/alphabet_garden_background.dart';
import 'package:my_tiny_thinker/games/color_shape_bridge_adventure/controllers/color_shape_bridge_controller.dart';
import 'package:my_tiny_thinker/games/color_shape_bridge_adventure/models/color_shape_bridge_models.dart';
import 'package:my_tiny_thinker/games/color_shape_bridge_adventure/presentation/widgets/color_shape_bridge_board.dart';
import 'package:my_tiny_thinker/games/color_shape_bridge_adventure/presentation/widgets/color_shape_bridge_hud.dart';
import 'package:my_tiny_thinker/games/color_shape_bridge_adventure/repository/color_shape_bridge_settings_repository.dart';

class ColorShapeBridgeGameScreen extends ConsumerStatefulWidget {
  const ColorShapeBridgeGameScreen({super.key});

  @override
  ConsumerState<ColorShapeBridgeGameScreen> createState() =>
      _ColorShapeBridgeGameScreenState();
}

class _ColorShapeBridgeGameScreenState
    extends ConsumerState<ColorShapeBridgeGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _particleKey = GlobalKey<ParticleSystemState>();
  Ticker? _ticker;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(colorShapeBridgeControllerProvider, (prev, next) {
      if (next.phase == ColorShapeBridgePhase.finished && !_saved) {
        _onFinished();
      }
      if (next.showSparkles &&
          (next.phase == ColorShapeBridgePhase.celebrating ||
              next.showRoundBonus)) {
        _particleKey.currentState?.emit();
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(colorShapeBridgeSettingsProvider);
    ref.read(colorShapeBridgeControllerProvider.notifier).reset();
    ref.read(colorShapeBridgeControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playMusic(asset: 'audio/ambient_music.mp3');
    }
    _ticker ??= createTicker((_) {
      ref.read(colorShapeBridgeControllerProvider.notifier).tick(1 / 60);
    });
    if (!_ticker!.isActive) _ticker!.start();
  }

  Future<void> _onFinished() async {
    _saved = true;
    _ticker?.stop();
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    await ref.read(colorShapeBridgeControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(colorShapeBridgeControllerProvider.notifier).pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.dispose();
    ref.read(audioServiceProvider).stopMusic();
    super.dispose();
  }

  Future<void> _showPauseMenu() async {
    ref.read(colorShapeBridgeControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () =>
          ref.read(colorShapeBridgeControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () async {
        final ctrl = ref.read(colorShapeBridgeControllerProvider.notifier);
        await ctrl.saveResult();
        ctrl.reset();
        if (!mounted) return;
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(colorShapeBridgeControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onConnect({required String promptId, required String visualId}) {
    final settings = ref.read(colorShapeBridgeSettingsProvider);
    final ok = ref.read(colorShapeBridgeControllerProvider.notifier).tryConnect(
          promptId: promptId,
          visualId: visualId,
        );

    if (settings.hapticsEnabled) {
      ref.read(hapticServiceProvider).trigger(
            ok ? HapticType.success : HapticType.light,
          );
    }
    if (settings.soundEnabled) {
      ref.read(audioServiceProvider).playSfx(
            ok ? SoundEffect.correct : SoundEffect.wrong,
          );
      if (ok) {
        ref.read(audioServiceProvider).playSfx(SoundEffect.reward);
        ref.read(audioServiceProvider).playSfx(SoundEffect.coin);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase =
        ref.watch(colorShapeBridgeControllerProvider.select((s) => s.phase));
    final settings = ref.watch(colorShapeBridgeSettingsProvider);
    final envPhase =
        ref.watch(colorShapeBridgeControllerProvider.select((s) => s.envPhase));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && phase != ColorShapeBridgePhase.finished) {
          await _showPauseMenu();
        }
      },
      child: AlphabetGardenBackground(
        envPhase: envPhase,
        reducedMotion: settings.reducedMotion,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    ColorShapeBridgeHud(
                      remainingSeconds: ref.watch(
                        colorShapeBridgeControllerProvider
                            .select((s) => s.remainingSeconds),
                      ),
                      unlimitedTime: settings.unlimitedTime,
                      starsEarned: ref.watch(
                        colorShapeBridgeControllerProvider
                            .select((s) => s.starsEarned),
                      ),
                      score: ref.watch(
                        colorShapeBridgeControllerProvider
                            .select((s) => s.score),
                      ),
                      round: ref.watch(
                        colorShapeBridgeControllerProvider
                            .select((s) => s.round),
                      ),
                      largerFonts: settings.largerTouchTargets,
                      onPause: _showPauseMenu,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'WORDS',
                            style: TextStyle(
                              color: const Color(0xFF4527A0)
                                  .withValues(alpha: 0.85),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'SHAPES & COLORS',
                            style: TextStyle(
                              color: const Color(0xFF4527A0)
                                  .withValues(alpha: 0.85),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ColorShapeBridgeBoard(
                        promptCards: ref.watch(
                          colorShapeBridgeControllerProvider
                              .select((s) => s.promptCards),
                        ),
                        visualCards: ref.watch(
                          colorShapeBridgeControllerProvider
                              .select((s) => s.visualCards),
                        ),
                        connections: ref.watch(
                          colorShapeBridgeControllerProvider
                              .select((s) => s.connections),
                        ),
                        largerTouch: settings.largerTouchTargets,
                        onConnect: _onConnect,
                      ),
                    ),
                  ],
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: ParticleSystem(
                      key: _particleKey,
                      particleCount: 44,
                      autoStart: false,
                    ),
                  ),
                ),
                GameFeedbackOverlay(
                  message: ref.watch(
                    colorShapeBridgeControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    colorShapeBridgeControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    colorShapeBridgeControllerProvider
                        .select((s) => s.showMascot),
                  ),
                  rewardShadowColor: const Color(0xFF7E57C2),
                ),
                if (phase == ColorShapeBridgePhase.paused)
                  GamePausedOverlay(
                    onResume: () => ref.read(colorShapeBridgeControllerProvider.notifier).resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (phase == ColorShapeBridgePhase.finished)
                  ColorShapeBridgeVictoryOverlay(
                    result: ref
                        .read(colorShapeBridgeControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref
                          .read(colorShapeBridgeControllerProvider.notifier)
                          .reset();
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

