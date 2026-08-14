import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/widgets/game_feedback_banner.dart';
import 'package:my_tiny_thinker/core/widgets/game_paused_overlay.dart';
import 'package:my_tiny_thinker/core/widgets/game_session_hud.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/catch_the_falling_stars/controllers/catch_the_falling_stars_controller.dart';
import 'package:my_tiny_thinker/games/catch_the_falling_stars/models/catch_the_falling_stars_models.dart';
import 'package:my_tiny_thinker/games/catch_the_falling_stars/presentation/widgets/catch_stars_hud.dart';
import 'package:my_tiny_thinker/games/catch_the_falling_stars/presentation/widgets/falling_star_widget.dart';
import 'package:my_tiny_thinker/games/catch_the_falling_stars/presentation/widgets/night_sky_background.dart';
import 'package:my_tiny_thinker/games/catch_the_falling_stars/repository/catch_the_falling_stars_settings_repository.dart';

class CatchTheFallingStarsGameScreen extends ConsumerStatefulWidget {
  const CatchTheFallingStarsGameScreen({super.key});

  @override
  ConsumerState<CatchTheFallingStarsGameScreen> createState() =>
      _CatchTheFallingStarsGameScreenState();
}

class _CatchTheFallingStarsGameScreenState
    extends ConsumerState<CatchTheFallingStarsGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Ticker? _ticker;
  final _particleKey = GlobalKey<ParticleSystemState>();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(catchTheFallingStarsControllerProvider, (prev, next) {
      _syncTicker(next.sessionPhase);
      if (next.sessionPhase == StarSessionPhase.finished && !_saved) {
        _onFinished();
      }
    });
  }

  Future<void> _start() async {
    if (!await ensureCanStartGame(context, ref, GameId.catchTheFallingStars)) {
      return;
    }
    if (!mounted) return;
    _saved = false;
    final settings = ref.read(catchTheFallingStarsSettingsProvider);
    ref.read(catchTheFallingStarsControllerProvider.notifier).reset();
    ref.read(catchTheFallingStarsControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playGameMusic();
    }
    _syncTicker(StarSessionPhase.playing);
  }

  void _syncTicker(StarSessionPhase phase) {
    if (phase == StarSessionPhase.playing) {
      _ticker ??= createTicker((_) {
        ref.read(catchTheFallingStarsControllerProvider.notifier).tick(1 / 60);
      });
      if (!_ticker!.isActive) _ticker!.start();
    } else {
      _ticker?.stop();
    }
  }

  Future<void> _onFinished() async {
    _saved = true;
    _ticker?.stop();
    final settings = ref.read(catchTheFallingStarsSettingsProvider);
    if (settings.soundEnabled) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    }
    await ref.read(catchTheFallingStarsControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(catchTheFallingStarsControllerProvider.notifier).pause();
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
    ref.read(catchTheFallingStarsControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () =>
          ref.read(catchTheFallingStarsControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(catchTheFallingStarsControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(catchTheFallingStarsControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onTapStar(String starId) {
    final settings = ref.read(catchTheFallingStarsSettingsProvider);
    final hit =
        ref.read(catchTheFallingStarsControllerProvider.notifier).tapStar(starId);

    if (settings.hapticsEnabled) {
      ref.read(hapticServiceProvider).trigger(
            hit ? HapticType.medium : HapticType.light,
          );
    }

    if (!hit) {
      if (settings.soundEnabled) {
        ref.read(audioServiceProvider).playSfx(SoundEffect.buttonTap);
      }
      return;
    }

    if (settings.soundEnabled) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
      ref.read(audioServiceProvider).playSfx(SoundEffect.reward);
      if (settings.coinRewardsEnabled) {
        ref.read(audioServiceProvider).playSfx(SoundEffect.coin);
      }
    }
    if (settings.celebrationsEnabled) {
      _particleKey.currentState?.emit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionPhase = ref.watch(
      catchTheFallingStarsControllerProvider.select((s) => s.sessionPhase),
    );
    final settings = ref.watch(catchTheFallingStarsSettingsProvider);
    final practice = settings.practiceMode;
    final envPhase = ref.watch(
      catchTheFallingStarsControllerProvider.select((s) => s.envPhase),
    );
    final moonCheer = ref.watch(
      catchTheFallingStarsControllerProvider.select((s) => s.moonCheer),
    );
    final constellation = ref.watch(
      catchTheFallingStarsControllerProvider.select((s) => s.activeConstellation),
    );
    final pieces = ref.watch(
      catchTheFallingStarsControllerProvider.select((s) => s.constellationPieces),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && sessionPhase != StarSessionPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: NightSkyBackground(
        envPhase: envPhase,
        moonCheer: moonCheer,
        constellationEmoji: settings.constellationEnabled
            ? kConstellationEmojis[constellation]
            : null,
        constellationPieces: settings.constellationEnabled ? pieces : 0,
        celebrate: sessionPhase == StarSessionPhase.finished,
        twinkleIntensity: settings.twinkleIntensity,
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
                        catchTheFallingStarsControllerProvider
                            .select((s) => s.remainingSeconds),
                      ),
                      unlimitedTime: practice,
                      coinsEarned: ref.watch(
                        catchTheFallingStarsControllerProvider
                            .select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        catchTheFallingStarsControllerProvider
                            .select((s) => s.starsEarned),
                      ),
                      onPause: _showPauseMenu,
                    ),
                    if (practice)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => ref
                              .read(
                                catchTheFallingStarsControllerProvider.notifier,
                              )
                              .endPractice(),
                          child: const Text(
                            'Done Playing',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    CatchStarsProgressMeter(
                      progress: ref.watch(
                        catchTheFallingStarsControllerProvider
                            .select((s) => s.progressMeter),
                      ),
                      constellationEmoji:
                          kConstellationEmojis[constellation] ?? '✨',
                      pieces: pieces,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _PlayArea(
                        particleKey: _particleKey,
                        onTapStar: _onTapStar,
                        largerTouch: settings.largerTouchTargets,
                      ),
                    ),
                  ],
                ),
                GameFeedbackOverlay(
                  message: ref.watch(
                    catchTheFallingStarsControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    catchTheFallingStarsControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    catchTheFallingStarsControllerProvider
                        .select((s) => s.showMascot),
                  ),
                ),
                if (sessionPhase == StarSessionPhase.paused)
                  GamePausedOverlay(
                    onResume: () => ref
                        .read(catchTheFallingStarsControllerProvider.notifier)
                        .resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (sessionPhase == StarSessionPhase.finished)
                  CatchStarsVictoryOverlay(
                    result: ref
                        .read(catchTheFallingStarsControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref
                          .read(catchTheFallingStarsControllerProvider.notifier)
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

class _PlayArea extends ConsumerWidget {
  const _PlayArea({
    required this.particleKey,
    required this.onTapStar,
    required this.largerTouch,
  });

  final GlobalKey<ParticleSystemState> particleKey;
  final void Function(String starId) onTapStar;
  final bool largerTouch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stars = ref.watch(
      catchTheFallingStarsControllerProvider.select((s) => s.stars),
    );
    final sparkles = ref.watch(
      catchTheFallingStarsControllerProvider.select((s) => s.sparkles),
    );
    final showSparkles = ref.watch(
      catchTheFallingStarsControllerProvider.select((s) => s.showSparkles),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(catchTheFallingStarsControllerProvider.notifier).setPlayArea(
                Size(constraints.maxWidth, constraints.maxHeight),
              );
        });

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (details) {
            ref
                .read(catchTheFallingStarsControllerProvider.notifier)
                .tapMiss(details.localPosition);
          },
          child: ClipRect(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                if (showSparkles)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ParticleSystem(
                        key: particleKey,
                        particleCount: 40,
                        autoStart: false,
                      ),
                    ),
                  ),
                ...stars.map((star) {
                  final size =
                      star.radius * 2 * (largerTouch ? 1.08 : 1.0);
                  return Positioned(
                    left: star.x - size / 2,
                    top: star.y - size / 2,
                    child: FallingStarWidget(
                      star: star,
                      largerTouch: largerTouch,
                      onTap: () => onTapStar(star.id),
                    ),
                  );
                }),
                ...sparkles.map(
                  (s) => Positioned(
                    left: s.x - 12,
                    top: s.y - 12,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: (1 - s.progress).clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, -24 * s.progress),
                          child: const Text('✨', style: TextStyle(fontSize: 22)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
