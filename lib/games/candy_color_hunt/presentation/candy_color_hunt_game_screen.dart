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
import 'package:my_tiny_thinker/games/candy_color_hunt/controllers/candy_color_hunt_controller.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/models/candy_color_hunt_models.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/presentation/widgets/candy_ant_widget.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/presentation/widgets/candy_bowl_widget.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/presentation/widgets/candy_hunt_hud.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/presentation/widgets/candy_world_background.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/presentation/widgets/thought_bubble_widget.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/repository/candy_color_hunt_settings_repository.dart';

class CandyColorHuntGameScreen extends ConsumerStatefulWidget {
  const CandyColorHuntGameScreen({super.key});

  @override
  ConsumerState<CandyColorHuntGameScreen> createState() =>
      _CandyColorHuntGameScreenState();
}

class _CandyColorHuntGameScreenState extends ConsumerState<CandyColorHuntGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _particleKey = GlobalKey<ParticleSystemState>();
  Ticker? _ticker;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(candyColorHuntControllerProvider, (prev, next) {
      if (next.phase == CandyHuntPhase.finished && !_saved) {
        _onFinished();
      }
      if (next.showSparkles && next.phase == CandyHuntPhase.celebrating) {
        _particleKey.currentState?.emit();
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(candyColorHuntSettingsProvider);
    ref.read(candyColorHuntControllerProvider.notifier).reset();
    ref.read(candyColorHuntControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playMusic(asset: 'audio/ambient_music.mp3');
    }
    _ticker ??= createTicker((_) {
      ref.read(candyColorHuntControllerProvider.notifier).tick(1 / 60);
    });
    if (!_ticker!.isActive) _ticker!.start();
  }

  Future<void> _onFinished() async {
    _saved = true;
    _ticker?.stop();
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    await ref.read(candyColorHuntControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(candyColorHuntControllerProvider.notifier).pause();
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
    ref.read(candyColorHuntControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () => ref.read(candyColorHuntControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(candyColorHuntControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(candyColorHuntControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onCandyTap(String id) {
    final settings = ref.read(candyColorHuntSettingsProvider);
    final ok =
        ref.read(candyColorHuntControllerProvider.notifier).tapCandy(id);

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
        ref.watch(candyColorHuntControllerProvider.select((s) => s.phase));
    final settings = ref.watch(candyColorHuntSettingsProvider);
    final envPhase =
        ref.watch(candyColorHuntControllerProvider.select((s) => s.envPhase));
    final remaining = ref.watch(
      candyColorHuntControllerProvider.select((s) => s.remainingSeconds),
    );
    final targetDef =
        ref.watch(candyColorHuntControllerProvider.select((s) => s.targetDef));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && phase != CandyHuntPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: CandyWorldBackground(
        envPhase: envPhase,
        reducedMotion: settings.reducedMotion,
        exciting: remaining <= 10 && phase != CandyHuntPhase.finished,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    CandyHuntHud(
                      remainingSeconds: remaining,
                      score: ref.watch(
                        candyColorHuntControllerProvider.select((s) => s.score),
                      ),
                      coinsEarned: ref.watch(
                        candyColorHuntControllerProvider
                            .select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        candyColorHuntControllerProvider
                            .select((s) => s.starsEarned),
                      ),
                      largerFonts: settings.largerTouchTargets,
                      onPause: _showPauseMenu,
                    ),
                    // Ant perched on the hill with matching thought candy.
                    Expanded(
                      flex: 3,
                      child: targetDef == null
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ThoughtBubbleWidget(
                                  target: targetDef,
                                  scale: ref.watch(
                                    candyColorHuntControllerProvider
                                        .select((s) => s.bubbleScale),
                                  ),
                                ),
                                CandyAntWidget(
                                  mood: ref.watch(
                                    candyColorHuntControllerProvider
                                        .select((s) => s.antMood),
                                  ),
                                  animPhase: ref.watch(
                                    candyColorHuntControllerProvider
                                        .select((s) => s.antAnimPhase),
                                  ),
                                  blinkTimer: ref.watch(
                                    candyColorHuntControllerProvider
                                        .select((s) => s.blinkTimer),
                                  ),
                                  size: settings.largerTouchTargets ? 128 : 112,
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                    ),
                    // Floating wrapped candies over the meadow (no bowl).
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 4, 10, 16),
                        child: CandyBowlWidget(
                          candies: ref.watch(
                            candyColorHuntControllerProvider
                                .select((s) => s.candies),
                          ),
                          largerTouch: settings.largerTouchTargets,
                          onCandyTap: _onCandyTap,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: ParticleSystem(
                      key: _particleKey,
                      particleCount: 40,
                      autoStart: false,
                    ),
                  ),
                ),
                GameFeedbackOverlay(
                  message: ref.watch(
                    candyColorHuntControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    candyColorHuntControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    candyColorHuntControllerProvider.select((s) => s.showMascot),
                  ),
                  rewardShadowColor: const Color(0xFFFF7043),
                ),
                if (phase == CandyHuntPhase.paused) GamePausedOverlay(
                    onResume: () => ref.read(candyColorHuntControllerProvider.notifier).resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (phase == CandyHuntPhase.finished)
                  CandyHuntVictoryOverlay(
                    result: ref
                        .read(candyColorHuntControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref.read(candyColorHuntControllerProvider.notifier).reset();
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

