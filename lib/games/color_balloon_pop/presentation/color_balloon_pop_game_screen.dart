import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_feedback_banner.dart';
import 'package:my_tiny_thinker/core/widgets/game_paused_overlay.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/color_balloon_pop/controllers/color_balloon_pop_controller.dart';
import 'package:my_tiny_thinker/games/color_balloon_pop/models/color_balloon_pop_models.dart';
import 'package:my_tiny_thinker/games/color_balloon_pop/presentation/widgets/color_balloon_pop_hud.dart';
import 'package:my_tiny_thinker/games/color_balloon_pop/presentation/widgets/color_target_card.dart';
import 'package:my_tiny_thinker/games/color_balloon_pop/repository/color_balloon_pop_settings_repository.dart';
import 'package:my_tiny_thinker/games/shared/balloon/balloon_festival_background.dart';
import 'package:my_tiny_thinker/games/shared/balloon/balloon_models.dart';
import 'package:my_tiny_thinker/games/shared/balloon/balloon_widget.dart';

class ColorBalloonPopGameScreen extends ConsumerStatefulWidget {
  const ColorBalloonPopGameScreen({super.key});

  @override
  ConsumerState<ColorBalloonPopGameScreen> createState() =>
      _ColorBalloonPopGameScreenState();
}

class _ColorBalloonPopGameScreenState
    extends ConsumerState<ColorBalloonPopGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Ticker? _ticker;
  final _particleKey = GlobalKey<ParticleSystemState>();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(colorBalloonPopControllerProvider, (prev, next) {
      _syncTicker(next.sessionPhase);
      if (next.sessionPhase == ColorBalloonSessionPhase.finished && !_saved) {
        _onFinished();
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(colorBalloonPopSettingsProvider);
    ref.read(colorBalloonPopControllerProvider.notifier).reset();
    ref.read(colorBalloonPopControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playMusic(asset: 'audio/ambient_music.mp3');
    }
    _syncTicker(ColorBalloonSessionPhase.playing);
  }

  void _syncTicker(ColorBalloonSessionPhase phase) {
    if (phase == ColorBalloonSessionPhase.playing) {
      _ticker ??= createTicker((_) {
        ref.read(colorBalloonPopControllerProvider.notifier).tick(1 / 60);
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
    await ref.read(colorBalloonPopControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(colorBalloonPopControllerProvider.notifier).pause();
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
    ref.read(colorBalloonPopControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () =>
          ref.read(colorBalloonPopControllerProvider.notifier).resume(),
      onRestart: () => _start(),
      onHome: () {
        ref.read(colorBalloonPopControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
    );
  }

  void _onTapBalloon(BalloonEntity balloon) {
    final settings = ref.read(colorBalloonPopSettingsProvider);
    final result = ref
        .read(colorBalloonPopControllerProvider.notifier)
        .tapBalloon(balloon.id);
    if (result == null) return;

    if (result.correct) {
      if (settings.soundEnabled) {
        ref.read(audioServiceProvider).playSfx(SoundEffect.bubblePop);
        ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
        ref.read(audioServiceProvider).playSfx(SoundEffect.coin);
      }
      if (settings.hapticsEnabled) {
        ref.read(hapticServiceProvider).trigger(HapticType.medium);
      }
      _particleKey.currentState?.emit(origin: result.origin);
    } else {
      if (settings.soundEnabled) {
        ref.read(audioServiceProvider).playSfx(SoundEffect.buttonTap);
      }
      if (settings.hapticsEnabled) {
        ref.read(hapticServiceProvider).trigger(HapticType.light);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(
      colorBalloonPopControllerProvider.select((s) => s.sessionPhase),
    );
    final settings = ref.watch(colorBalloonPopSettingsProvider);
    final highContrast =
        ref.watch(settingsProvider.select((s) => s.highContrast));
    final targetHue = ref.watch(
      colorBalloonPopControllerProvider.select((s) => s.targetHue),
    );
    final instruction = ref.watch(
      colorBalloonPopControllerProvider.select((s) => s.instructionText),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && phase != ColorBalloonSessionPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: BalloonFestivalBackground(
        showKites: true,
        reducedMotion: settings.reducedMotion,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    ColorBalloonPopHud(
                      remainingSeconds: ref.watch(
                        colorBalloonPopControllerProvider
                            .select((s) => s.remainingSeconds),
                      ),
                      roundsCompleted: ref.watch(
                        colorBalloonPopControllerProvider
                            .select((s) => s.roundsCompleted),
                      ),
                      coinsEarned: ref.watch(
                        colorBalloonPopControllerProvider
                            .select((s) => s.coinsEarned),
                      ),
                      onPause: _showPauseMenu,
                    ),
                    ColorTargetCard(
                      targetHue: targetHue,
                      instruction: instruction,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: _ColorPlayArea(
                        particleKey: _particleKey,
                        highContrast: highContrast,
                        targetHue: targetHue,
                        onTap: _onTapBalloon,
                      ),
                    ),
                  ],
                ),
                GameFeedbackOverlay(
                  message: ref.watch(
                    colorBalloonPopControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    colorBalloonPopControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    colorBalloonPopControllerProvider
                        .select((s) => s.showMascot),
                  ),
                  rewardShadowColor: AppColors.skyBlueDark,
                ),
                if (phase == ColorBalloonSessionPhase.paused)
                  GamePausedOverlay(
                    onResume: () => ref
                        .read(colorBalloonPopControllerProvider.notifier)
                        .resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (phase == ColorBalloonSessionPhase.finished)
                  ColorBalloonVictoryOverlay(
                    result: ref
                        .read(colorBalloonPopControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref
                          .read(colorBalloonPopControllerProvider.notifier)
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

class _ColorPlayArea extends ConsumerWidget {
  const _ColorPlayArea({
    required this.particleKey,
    required this.highContrast,
    required this.targetHue,
    required this.onTap,
  });

  final GlobalKey<ParticleSystemState> particleKey;
  final bool highContrast;
  final BalloonHue targetHue;
  final void Function(BalloonEntity balloon) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balloons = ref.watch(
      colorBalloonPopControllerProvider.select((s) => s.balloons),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(colorBalloonPopControllerProvider.notifier).setPlayArea(
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
                  glow: b.hue == targetHue &&
                      (b.phase == BalloonPhase.bobbing ||
                          b.phase == BalloonPhase.rising),
                  onTap: () => onTap(b),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: ParticleSystem(
                    key: particleKey,
                    particleCount: 36,
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
