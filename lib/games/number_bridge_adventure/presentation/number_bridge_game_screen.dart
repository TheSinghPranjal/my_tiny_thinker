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
import 'package:my_tiny_thinker/games/number_bridge_adventure/controllers/number_bridge_controller.dart';
import 'package:my_tiny_thinker/games/number_bridge_adventure/models/number_bridge_models.dart';
import 'package:my_tiny_thinker/games/number_bridge_adventure/presentation/widgets/number_bridge_board.dart';
import 'package:my_tiny_thinker/games/number_bridge_adventure/presentation/widgets/number_bridge_hud.dart';
import 'package:my_tiny_thinker/games/number_bridge_adventure/repository/number_bridge_settings_repository.dart';

class NumberBridgeGameScreen extends ConsumerStatefulWidget {
  const NumberBridgeGameScreen({super.key});

  @override
  ConsumerState<NumberBridgeGameScreen> createState() =>
      _NumberBridgeGameScreenState();
}

class _NumberBridgeGameScreenState extends ConsumerState<NumberBridgeGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _particleKey = GlobalKey<ParticleSystemState>();
  Ticker? _ticker;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(numberBridgeControllerProvider, (prev, next) {
      if (next.phase == NumberBridgePhase.finished && !_saved) {
        _onFinished();
      }
      if (next.showSparkles &&
          (next.phase == NumberBridgePhase.celebrating || next.showRoundBonus)) {
        _particleKey.currentState?.emit();
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(numberBridgeSettingsProvider);
    ref.read(numberBridgeControllerProvider.notifier).reset();
    ref.read(numberBridgeControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playMusic(asset: 'audio/ambient_music.mp3');
    }
    _ticker ??= createTicker((_) {
      ref.read(numberBridgeControllerProvider.notifier).tick(1 / 60);
    });
    if (!_ticker!.isActive) _ticker!.start();
  }

  Future<void> _onFinished() async {
    _saved = true;
    _ticker?.stop();
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    await ref.read(numberBridgeControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(numberBridgeControllerProvider.notifier).pause();
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
    ref.read(numberBridgeControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () =>
          ref.read(numberBridgeControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () async {
        final ctrl = ref.read(numberBridgeControllerProvider.notifier);
        await ctrl.saveResult();
        ctrl.reset();
        if (!mounted) return;
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(numberBridgeControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onConnect({required String digitId, required String wordId}) {
    final settings = ref.read(numberBridgeSettingsProvider);
    final ok = ref.read(numberBridgeControllerProvider.notifier).tryConnect(
          digitId: digitId,
          wordId: wordId,
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
        ref.watch(numberBridgeControllerProvider.select((s) => s.phase));
    final settings = ref.watch(numberBridgeSettingsProvider);
    final envPhase =
        ref.watch(numberBridgeControllerProvider.select((s) => s.envPhase));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && phase != NumberBridgePhase.finished) {
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
                    NumberBridgeHud(
                      remainingSeconds: ref.watch(
                        numberBridgeControllerProvider
                            .select((s) => s.remainingSeconds),
                      ),
                      unlimitedTime: settings.unlimitedTime,
                      starsEarned: ref.watch(
                        numberBridgeControllerProvider
                            .select((s) => s.starsEarned),
                      ),
                      score: ref.watch(
                        numberBridgeControllerProvider.select((s) => s.score),
                      ),
                      round: ref.watch(
                        numberBridgeControllerProvider.select((s) => s.round),
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
                            'digits',
                            style: TextStyle(
                              color: const Color(0xFF01579B)
                                  .withValues(alpha: 0.85),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'NUMBER WORDS',
                            style: TextStyle(
                              color: const Color(0xFF01579B)
                                  .withValues(alpha: 0.85),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: NumberBridgeBoard(
                        digitCards: ref.watch(
                          numberBridgeControllerProvider
                              .select((s) => s.digitCards),
                        ),
                        wordCards: ref.watch(
                          numberBridgeControllerProvider
                              .select((s) => s.wordCards),
                        ),
                        connections: ref.watch(
                          numberBridgeControllerProvider
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
                    numberBridgeControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    numberBridgeControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    numberBridgeControllerProvider
                        .select((s) => s.showMascot),
                  ),
                  rewardShadowColor: const Color(0xFF0288D1),
                ),
                if (phase == NumberBridgePhase.paused)
                  GamePausedOverlay(
                    onResume: () => ref.read(numberBridgeControllerProvider.notifier).resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (phase == NumberBridgePhase.finished)
                  NumberBridgeVictoryOverlay(
                    result: ref
                        .read(numberBridgeControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref.read(numberBridgeControllerProvider.notifier).reset();
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

