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
import 'package:my_tiny_thinker/games/moon_rescue_adventure/controllers/moon_rescue_controller.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/models/moon_rescue_models.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/presentation/widgets/moon_rescue_board.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/presentation/widgets/moon_rescue_hud.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/presentation/widgets/space_background.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/repository/moon_rescue_settings_repository.dart';

class MoonRescueGameScreen extends ConsumerStatefulWidget {
  const MoonRescueGameScreen({super.key});

  @override
  ConsumerState<MoonRescueGameScreen> createState() =>
      _MoonRescueGameScreenState();
}

class _MoonRescueGameScreenState extends ConsumerState<MoonRescueGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _particleKey = GlobalKey<ParticleSystemState>();
  Ticker? _ticker;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(moonRescueControllerProvider, (prev, next) {
      if (next.phase == MoonRescuePhase.finished && !_saved) {
        _onFinished();
      }
      if (next.showSparkles || next.showEarthCelebration) {
        _particleKey.currentState?.emit();
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(moonRescueSettingsProvider);
    ref.read(moonRescueControllerProvider.notifier).reset();
    ref.read(moonRescueControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playMusic(asset: 'audio/ambient_music.mp3');
    }
    _ticker ??= createTicker((_) {
      ref.read(moonRescueControllerProvider.notifier).tick(1 / 60);
    });
    if (!_ticker!.isActive) _ticker!.start();
  }

  Future<void> _onFinished() async {
    _saved = true;
    _ticker?.stop();
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    await ref.read(moonRescueControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(moonRescueControllerProvider.notifier).pause();
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
    ref.read(moonRescueControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () =>
          ref.read(moonRescueControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () async {
        final ctrl = ref.read(moonRescueControllerProvider.notifier);
        await ctrl.saveResult();
        ctrl.reset();
        if (!mounted) return;
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(moonRescueControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onTapAstronaut(String id) {
    final settings = ref.read(moonRescueSettingsProvider);
    ref.read(moonRescueControllerProvider.notifier).tapAstronaut(id);
    if (settings.hapticsEnabled) {
      ref.read(hapticServiceProvider).trigger(HapticType.light);
    }
    if (settings.soundEnabled) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.bubblePop);
    }
  }

  void _onFlickAstronaut(String id, Offset delta) {
    final settings = ref.read(moonRescueSettingsProvider);
    ref.read(moonRescueControllerProvider.notifier).pushAstronaut(id, delta);
    if (settings.hapticsEnabled) {
      ref.read(hapticServiceProvider).trigger(HapticType.medium);
    }
    if (settings.soundEnabled) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.bubblePop);
    }
  }

  void _onTapRocket() {
    final settings = ref.read(moonRescueSettingsProvider);
    ref.read(moonRescueControllerProvider.notifier).tapRocket();
    if (settings.hapticsEnabled) {
      ref.read(hapticServiceProvider).trigger(HapticType.success);
    }
    if (settings.rocketSoundsEnabled || settings.soundEnabled) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.reward);
      ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase =
        ref.watch(moonRescueControllerProvider.select((s) => s.phase));
    final settings = ref.watch(moonRescueSettingsProvider);
    final envPhase =
        ref.watch(moonRescueControllerProvider.select((s) => s.envPhase));
    final celebrate = ref.watch(
      moonRescueControllerProvider.select((s) => s.showEarthCelebration),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && phase != MoonRescuePhase.finished) {
          await _showPauseMenu();
        }
      },
      child: SpaceBackground(
        envPhase: envPhase,
        showEarthCelebration: celebrate,
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
                        moonRescueControllerProvider.select((s) => s.remainingSeconds),
                      ),
                      unlimitedTime: settings.unlimitedTime,
                      coinsEarned: ref.watch(
                        moonRescueControllerProvider.select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        moonRescueControllerProvider.select((s) => s.starsEarned),
                      ),
                      largerFonts: settings.largerTouchTargets,
                      onPause: _showPauseMenu,
                    ),
                    Expanded(
                      child: MoonRescueBoard(
                        astronauts: ref.watch(
                          moonRescueControllerProvider
                              .select((s) => s.astronauts),
                        ),
                        rocket: ref.watch(
                          moonRescueControllerProvider.select((s) => s.rocket),
                        ),
                        capacity: settings.rocketCapacity,
                        largerTouch: settings.largerTouchTargets,
                        onPlayAreaSized: (size) => ref
                            .read(moonRescueControllerProvider.notifier)
                            .setPlayArea(size),
                        onTapAstronaut: _onTapAstronaut,
                        onFlickAstronaut: _onFlickAstronaut,
                        onTapRocket: _onTapRocket,
                      ),
                    ),
                  ],
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: ParticleSystem(
                      key: _particleKey,
                      particleCount: 48,
                      autoStart: false,
                    ),
                  ),
                ),
                GameFeedbackOverlay(
                  message: ref.watch(
                    moonRescueControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    moonRescueControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    moonRescueControllerProvider.select((s) => s.showMascot),
                  ),
                  rewardShadowColor: const Color(0xFF7E57C2),
                ),
                if (phase == MoonRescuePhase.paused) GamePausedOverlay(
                    onResume: () => ref.read(moonRescueControllerProvider.notifier).resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (phase == MoonRescuePhase.finished)
                  MoonRescueVictoryOverlay(
                    result: ref
                        .read(moonRescueControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref.read(moonRescueControllerProvider.notifier).reset();
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

