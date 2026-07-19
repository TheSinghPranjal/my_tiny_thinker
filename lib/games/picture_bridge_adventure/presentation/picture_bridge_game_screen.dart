import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/widgets/game_session_hud.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/widgets/game_feedback_banner.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/core/widgets/game_paused_overlay.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/presentation/widgets/alphabet_garden_background.dart';
import 'package:my_tiny_thinker/games/picture_bridge_adventure/controllers/picture_bridge_controller.dart';
import 'package:my_tiny_thinker/games/picture_bridge_adventure/models/picture_bridge_models.dart';
import 'package:my_tiny_thinker/games/picture_bridge_adventure/presentation/widgets/picture_bridge_board.dart';
import 'package:my_tiny_thinker/games/picture_bridge_adventure/presentation/widgets/picture_bridge_hud.dart';
import 'package:my_tiny_thinker/games/picture_bridge_adventure/repository/picture_bridge_settings_repository.dart';

class PictureBridgeGameScreen extends ConsumerStatefulWidget {
  const PictureBridgeGameScreen({super.key});

  @override
  ConsumerState<PictureBridgeGameScreen> createState() =>
      _PictureBridgeGameScreenState();
}

class _PictureBridgeGameScreenState extends ConsumerState<PictureBridgeGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _particleKey = GlobalKey<ParticleSystemState>();
  Ticker? _ticker;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(pictureBridgeControllerProvider, (prev, next) {
      if (next.phase == PictureBridgePhase.finished && !_saved) {
        _onFinished();
      }
      if (next.showSparkles &&
          (next.phase == PictureBridgePhase.celebrating ||
              next.showRoundBonus)) {
        _particleKey.currentState?.emit();
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(pictureBridgeSettingsProvider);
    ref.read(pictureBridgeControllerProvider.notifier).reset();
    ref.read(pictureBridgeControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playGameMusic();
    }
    _ticker ??= createTicker((_) {
      ref.read(pictureBridgeControllerProvider.notifier).tick(1 / 60);
    });
    if (!_ticker!.isActive) _ticker!.start();
  }

  Future<void> _onFinished() async {
    _saved = true;
    _ticker?.stop();
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    await ref.read(pictureBridgeControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(pictureBridgeControllerProvider.notifier).pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.dispose();
    ref.read(audioServiceProvider).playHomeMusic();
    super.dispose();
  }

  Future<void> _showPauseMenu() async {
    ref.read(pictureBridgeControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () =>
          ref.read(pictureBridgeControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () async {
        final ctrl = ref.read(pictureBridgeControllerProvider.notifier);
        await ctrl.saveResult();
        ctrl.reset();
        if (!mounted) return;
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(pictureBridgeControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onConnect({required String pictureId, required String wordId}) {
    final settings = ref.read(pictureBridgeSettingsProvider);
    final ok = ref.read(pictureBridgeControllerProvider.notifier).tryConnect(
          pictureId: pictureId,
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
        ref.watch(pictureBridgeControllerProvider.select((s) => s.phase));
    final settings = ref.watch(pictureBridgeSettingsProvider);
    final envPhase =
        ref.watch(pictureBridgeControllerProvider.select((s) => s.envPhase));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && phase != PictureBridgePhase.finished) {
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
                    GameSessionHud(
                      remainingSeconds: ref.watch(
                        pictureBridgeControllerProvider.select((s) => s.remainingSeconds),
                      ),
                      unlimitedTime: settings.unlimitedTime,
                      coinsEarned: ref.watch(
                        pictureBridgeControllerProvider.select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        pictureBridgeControllerProvider.select((s) => s.starsEarned),
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
                            'pictures',
                            style: TextStyle(
                              color: const Color(0xFF4527A0)
                                  .withValues(alpha: 0.85),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'WORDS',
                            style: TextStyle(
                              color: const Color(0xFF4527A0)
                                  .withValues(alpha: 0.85),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PictureBridgeBoard(
                        pictureCards: ref.watch(
                          pictureBridgeControllerProvider
                              .select((s) => s.pictureCards),
                        ),
                        wordCards: ref.watch(
                          pictureBridgeControllerProvider
                              .select((s) => s.wordCards),
                        ),
                        connections: ref.watch(
                          pictureBridgeControllerProvider
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
                    pictureBridgeControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    pictureBridgeControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    pictureBridgeControllerProvider
                        .select((s) => s.showMascot),
                  ),
                  rewardShadowColor: const Color(0xFF7E57C2),
                ),
                if (phase == PictureBridgePhase.paused)
                  GamePausedOverlay(
                    onResume: () => ref.read(pictureBridgeControllerProvider.notifier).resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (phase == PictureBridgePhase.finished)
                  PictureBridgeVictoryOverlay(
                    result: ref
                        .read(pictureBridgeControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref.read(pictureBridgeControllerProvider.notifier).reset();
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

