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
import 'package:my_tiny_thinker/games/frog_pond_adventure/controllers/frog_pond_controller.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/models/frog_pond_models.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/presentation/widgets/frog_widget.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/presentation/widgets/lily_pad_widget.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/presentation/widgets/pond_background.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/presentation/widgets/pond_hud.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/repository/frog_pond_settings_repository.dart';

class FrogPondGameScreen extends ConsumerStatefulWidget {
  const FrogPondGameScreen({super.key});

  @override
  ConsumerState<FrogPondGameScreen> createState() => _FrogPondGameScreenState();
}

class _FrogPondGameScreenState extends ConsumerState<FrogPondGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Ticker? _ticker;
  final _particleKey = GlobalKey<ParticleSystemState>();
  bool _saved = false;
  AudioService? _audio;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audio = ref.read(audioServiceProvider);
      _start();
    });

    ref.listenManual(frogPondControllerProvider, (prev, next) {
      _syncTicker(next.sessionPhase);
      if (next.sessionPhase == FrogPondSessionPhase.finished && !_saved) {
        _onFinished();
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(frogPondSettingsProvider);
    ref.read(frogPondControllerProvider.notifier).reset();
    ref.read(frogPondControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playGameMusic();
    }
    _syncTicker(FrogPondSessionPhase.playing);
  }

  void _syncTicker(FrogPondSessionPhase phase) {
    if (phase == FrogPondSessionPhase.playing) {
      _ticker ??= createTicker((_) {
        ref.read(frogPondControllerProvider.notifier).tick(1 / 60);
      });
      if (!_ticker!.isActive) _ticker!.start();
    } else {
      _ticker?.stop();
    }
  }

  Future<void> _onFinished() async {
    _saved = true;
    _ticker?.stop();
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    await ref.read(frogPondControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(frogPondControllerProvider.notifier).pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.dispose();
    _audio?.playHomeMusic();
    super.dispose();
  }

  Future<void> _showPauseMenu() async {
    ref.read(frogPondControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () => ref.read(frogPondControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(frogPondControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(frogPondControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onTapFrog(String frogId) {
    final settings = ref.read(frogPondSettingsProvider);
    final frog = ref
        .read(frogPondControllerProvider)
        .frogs
        .where((f) => f.id == frogId)
        .firstOrNull;
    if (frog == null) return;

    final willCompleteKing = frog.isKing && frog.crownGems <= 1;
    final ok = ref.read(frogPondControllerProvider.notifier).tapFrog(frogId);
    if (!ok) return;

    if (settings.hapticsEnabled) {
      ref.read(hapticServiceProvider).trigger(HapticType.light);
    }
    if (settings.soundEnabled) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.buttonTap);
      if (!frog.isKing || willCompleteKing) {
        ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
        ref.read(audioServiceProvider).playSfx(SoundEffect.reward);
        ref.read(audioServiceProvider).playSfx(SoundEffect.coin);
      }
      if (willCompleteKing) {
        ref.read(audioServiceProvider).playSfx(SoundEffect.levelComplete);
      }
    }
    if (ref.read(frogPondControllerProvider).showSparkles) {
      _particleKey.currentState?.emit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionPhase = ref.watch(
      frogPondControllerProvider.select((s) => s.sessionPhase),
    );
    final settings = ref.watch(frogPondSettingsProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && sessionPhase != FrogPondSessionPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: PondBackground(
        reducedMotion: settings.reducedMotion,
        intensity: settings.animationIntensity,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    GameSessionHud(
                      remainingSeconds: ref.watch(
                        frogPondControllerProvider.select((s) => s.remainingSeconds),
                      ),
                      coinsEarned: ref.watch(
                        frogPondControllerProvider.select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        frogPondControllerProvider.select((s) => s.starsEarned),
                      ),
                      largerFonts: settings.largerTouchTargets,
                      onPause: _showPauseMenu,
                    ),
                    Expanded(
                      child: _PondPlayArea(
                        particleKey: _particleKey,
                        onTapFrog: _onTapFrog,
                        highContrast: settings.highContrast,
                        largerTouch: settings.largerTouchTargets,
                      ),
                    ),
                  ],
                ),
                GameFeedbackOverlay(
                  message: ref.watch(
                    frogPondControllerProvider.select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    frogPondControllerProvider.select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    frogPondControllerProvider.select((s) => s.showMascot),
                  ),
                ),
                if (sessionPhase == FrogPondSessionPhase.paused)
                  GamePausedOverlay(
                    onResume: () => ref.read(frogPondControllerProvider.notifier).resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (sessionPhase == FrogPondSessionPhase.finished)
                  PondVictoryOverlay(
                    result: ref.read(frogPondControllerProvider.notifier).getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref.read(frogPondControllerProvider.notifier).reset();
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


class _PondPlayArea extends ConsumerWidget {
  const _PondPlayArea({
    required this.particleKey,
    required this.onTapFrog,
    required this.highContrast,
    required this.largerTouch,
  });

  final GlobalKey<ParticleSystemState> particleKey;
  final void Function(String frogId) onTapFrog;
  final bool highContrast;
  final bool largerTouch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pads = ref.watch(frogPondControllerProvider.select((s) => s.pads));
    final frogs = ref.watch(frogPondControllerProvider.select((s) => s.frogs));
    final showSparkles = ref.watch(
      frogPondControllerProvider.select((s) => s.showSparkles),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(frogPondControllerProvider.notifier).setPlayArea(
                Size(constraints.maxWidth, constraints.maxHeight),
              );
        });

        return ClipRect(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              if (showSparkles)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ParticleSystem(
                      key: particleKey,
                      particleCount: 32,
                      autoStart: false,
                    ),
                  ),
                ),
              ...pads.map(
                (pad) => Positioned(
                  left: pad.centerX - pad.radius * 1.1,
                  top: pad.centerY - pad.radius * 0.7,
                  child: LilyPadWidget(pad: pad),
                ),
              ),
              ...frogs
                  .where((f) => f.phase != FrogPhase.gone)
                  .map(
                    (frog) => Positioned(
                      left: frog.x - (frog.isKing ? 52 : 44),
                      top: frog.y - (frog.isKing ? 52 : 44),
                      child: FrogWidget(
                        frog: frog,
                        highContrast: highContrast,
                        largerTouch: largerTouch,
                        onTap: () => onTapFrog(frog.id),
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
