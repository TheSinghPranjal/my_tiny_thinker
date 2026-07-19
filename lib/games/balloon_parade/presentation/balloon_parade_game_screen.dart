import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_feedback_banner.dart';
import 'package:my_tiny_thinker/core/widgets/game_paused_overlay.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/balloon_parade/controllers/balloon_parade_controller.dart';
import 'package:my_tiny_thinker/games/balloon_parade/models/balloon_parade_models.dart';
import 'package:my_tiny_thinker/games/balloon_parade/presentation/widgets/balloon_parade_hud.dart';
import 'package:my_tiny_thinker/games/balloon_parade/repository/balloon_parade_settings_repository.dart';
import 'package:my_tiny_thinker/games/shared/balloon/balloon_festival_background.dart';
import 'package:my_tiny_thinker/games/shared/balloon/balloon_models.dart';
import 'package:my_tiny_thinker/games/shared/balloon/balloon_widget.dart';

class BalloonParadeGameScreen extends ConsumerStatefulWidget {
  const BalloonParadeGameScreen({super.key});

  @override
  ConsumerState<BalloonParadeGameScreen> createState() =>
      _BalloonParadeGameScreenState();
}

class _BalloonParadeGameScreenState
    extends ConsumerState<BalloonParadeGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Ticker? _ticker;
  final _particleKey = GlobalKey<ParticleSystemState>();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(balloonParadeControllerProvider, (prev, next) {
      _syncTicker(next.sessionPhase);
      if (next.sessionPhase == BalloonParadeSessionPhase.finished && !_saved) {
        _onFinished();
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(balloonParadeSettingsProvider);
    ref.read(balloonParadeControllerProvider.notifier).reset();
    ref.read(balloonParadeControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playMusic(asset: 'audio/ambient_music.mp3');
    }
    _syncTicker(BalloonParadeSessionPhase.playing);
  }

  void _syncTicker(BalloonParadeSessionPhase phase) {
    if (phase == BalloonParadeSessionPhase.playing) {
      _ticker ??= createTicker((_) {
        ref.read(balloonParadeControllerProvider.notifier).tick(1 / 60);
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
    await ref.read(balloonParadeControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(balloonParadeControllerProvider.notifier).pause();
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
    ref.read(balloonParadeControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () =>
          ref.read(balloonParadeControllerProvider.notifier).resume(),
      onRestart: () => _start(),
      onHome: () {
        ref.read(balloonParadeControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
    );
  }

  void _onTapBalloon(BalloonEntity balloon) {
    final settings = ref.read(balloonParadeSettingsProvider);
    final origin = ref
        .read(balloonParadeControllerProvider.notifier)
        .tapBalloon(balloon.id);
    if (origin == null) return;

    if (settings.soundEnabled) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.bubblePop);
      ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
      ref.read(audioServiceProvider).playSfx(SoundEffect.coin);
    }
    if (settings.hapticsEnabled) {
      ref.read(hapticServiceProvider).trigger(HapticType.light);
    }
    _particleKey.currentState?.emit(origin: origin);
  }

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(
      balloonParadeControllerProvider.select((s) => s.sessionPhase),
    );
    final settings = ref.watch(balloonParadeSettingsProvider);
    final highContrast =
        ref.watch(settingsProvider.select((s) => s.highContrast));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && phase != BalloonParadeSessionPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: BalloonFestivalBackground(
        reducedMotion: settings.reducedMotion,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    BalloonParadeHud(
                      remainingSeconds: ref.watch(
                        balloonParadeControllerProvider
                            .select((s) => s.remainingSeconds),
                      ),
                      balloonsPopped: ref.watch(
                        balloonParadeControllerProvider
                            .select((s) => s.balloonsPopped),
                      ),
                      coinsEarned: ref.watch(
                        balloonParadeControllerProvider
                            .select((s) => s.coinsEarned),
                      ),
                      pointsEarned: ref.watch(
                        balloonParadeControllerProvider
                            .select((s) => s.pointsEarned),
                      ),
                      onPause: _showPauseMenu,
                    ),
                    Expanded(
                      child: _BalloonPlayArea(
                        particleKey: _particleKey,
                        highContrast: highContrast,
                        onTap: _onTapBalloon,
                      ),
                    ),
                  ],
                ),
                GameFeedbackOverlay(
                  message: ref.watch(
                    balloonParadeControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    balloonParadeControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    balloonParadeControllerProvider
                        .select((s) => s.showMascot),
                  ),
                  rewardShadowColor: AppColors.skyBlueDark,
                ),
                if (phase == BalloonParadeSessionPhase.paused)
                  GamePausedOverlay(
                    onResume: () => ref
                        .read(balloonParadeControllerProvider.notifier)
                        .resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (phase == BalloonParadeSessionPhase.finished)
                  BalloonParadeVictoryOverlay(
                    result: ref
                        .read(balloonParadeControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref
                          .read(balloonParadeControllerProvider.notifier)
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

class _BalloonPlayArea extends ConsumerWidget {
  const _BalloonPlayArea({
    required this.particleKey,
    required this.highContrast,
    required this.onTap,
  });

  final GlobalKey<ParticleSystemState> particleKey;
  final bool highContrast;
  final void Function(BalloonEntity balloon) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balloons = ref.watch(
      balloonParadeControllerProvider.select((s) => s.balloons),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(balloonParadeControllerProvider.notifier).setPlayArea(
                Size(constraints.maxWidth, constraints.maxHeight),
              );
        });

        return ClipRect(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              ...balloons.map(
                (b) => BalloonWidget(
                  key: ValueKey(b.id),
                  balloon: b,
                  highContrast: highContrast,
                  onTap: () => onTap(b),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: ParticleSystem(
                    key: particleKey,
                    particleCount: 32,
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
