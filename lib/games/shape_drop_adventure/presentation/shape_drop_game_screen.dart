import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_feedback_banner.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/controllers/shape_drop_controller.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/models/shape_drop_models.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/presentation/widgets/classroom_background.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/presentation/widgets/shape_drop_board.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/presentation/widgets/shape_drop_hud.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/repository/shape_drop_settings_repository.dart';

class ShapeDropGameScreen extends ConsumerStatefulWidget {
  const ShapeDropGameScreen({super.key});

  @override
  ConsumerState<ShapeDropGameScreen> createState() => _ShapeDropGameScreenState();
}

class _ShapeDropGameScreenState extends ConsumerState<ShapeDropGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _particleKey = GlobalKey<ParticleSystemState>();
  Ticker? _ticker;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(shapeDropControllerProvider, (prev, next) {
      if (next.phase == ShapeDropPhase.finished && !_saved) {
        _onFinished();
      }
      if (next.showSparkles && next.phase == ShapeDropPhase.celebrating) {
        _particleKey.currentState?.emit();
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(shapeDropSettingsProvider);
    ref.read(shapeDropControllerProvider.notifier).reset();
    ref.read(shapeDropControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playMusic(asset: 'audio/ambient_music.mp3');
    }
    _ticker ??= createTicker((_) {
      ref.read(shapeDropControllerProvider.notifier).tickEnv(1 / 60);
    });
    if (!_ticker!.isActive) _ticker!.start();
  }

  Future<void> _onFinished() async {
    _saved = true;
    _ticker?.stop();
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    await ref.read(shapeDropControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(shapeDropControllerProvider.notifier).pause();
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
    ref.read(shapeDropControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () => ref.read(shapeDropControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(shapeDropControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () {
        ref.read(shapeDropControllerProvider.notifier).pause();
        context.push(AppRoutes.parentZone);
      },
    );
  }

  void _onDrop(String optionId) {
    final settings = ref.read(shapeDropSettingsProvider);
    final ok =
        ref.read(shapeDropControllerProvider.notifier).tryDrop(optionId);

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
    final phase = ref.watch(shapeDropControllerProvider.select((s) => s.phase));
    final settings = ref.watch(shapeDropSettingsProvider);
    final envPhase =
        ref.watch(shapeDropControllerProvider.select((s) => s.envPhase));
    final target =
        ref.watch(shapeDropControllerProvider.select((s) => s.target));
    final options =
        ref.watch(shapeDropControllerProvider.select((s) => s.options));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && phase != ShapeDropPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: ClassroomBackground(
        envPhase: envPhase,
        reducedMotion: settings.reducedMotion,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    ShapeDropHud(
                      remainingSeconds: ref.watch(
                        shapeDropControllerProvider
                            .select((s) => s.remainingSeconds),
                      ),
                      score: ref.watch(
                        shapeDropControllerProvider.select((s) => s.score),
                      ),
                      coinsEarned: ref.watch(
                        shapeDropControllerProvider
                            .select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        shapeDropControllerProvider
                            .select((s) => s.starsEarned),
                      ),
                      largerFonts: settings.largerTouchTargets,
                      onPause: _showPauseMenu,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        target == null
                            ? 'Find the shape!'
                            : 'Find the ${settings.uppercaseLabels ? target.name.toUpperCase() : target.name}!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: settings.largerTouchTargets ? 24 : 20,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF6A1B9A),
                        ),
                      ),
                    ),
                    Expanded(
                      child: target == null
                          ? const Center(child: CircularProgressIndicator())
                          : ShapeDropBoard(
                              target: target,
                              options: options,
                              filled: ref.watch(
                                shapeDropControllerProvider
                                    .select((s) => s.filled),
                              ),
                              outlineGlow: ref.watch(
                                shapeDropControllerProvider
                                    .select((s) => s.outlineGlow),
                              ),
                              largerTouch: settings.largerTouchTargets,
                              envPhase: envPhase,
                              onDrop: _onDrop,
                            ),
                    ),
                  ],
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: ParticleSystem(
                      key: _particleKey,
                      particleCount: 36,
                      autoStart: false,
                    ),
                  ),
                ),
                GameFeedbackOverlay(
                  message: ref.watch(
                    shapeDropControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    shapeDropControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    shapeDropControllerProvider.select((s) => s.showMascot),
                  ),
                  rewardShadowColor: const Color(0xFF7E57C2),
                ),
                if (phase == ShapeDropPhase.paused) const _PausedOverlay(),
                if (phase == ShapeDropPhase.finished)
                  ShapeDropVictoryOverlay(
                    result: ref
                        .read(shapeDropControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref.read(shapeDropControllerProvider.notifier).reset();
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

class _PausedOverlay extends StatelessWidget {
  const _PausedOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF7E57C2).withValues(alpha: 0.55),
        child: const Center(
          child: Text(
            'Paused',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
