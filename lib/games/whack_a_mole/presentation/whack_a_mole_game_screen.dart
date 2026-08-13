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
import 'package:my_tiny_thinker/games/whack_a_mole/controllers/whack_a_mole_controller.dart';
import 'package:my_tiny_thinker/games/whack_a_mole/models/whack_a_mole_models.dart';
import 'package:my_tiny_thinker/games/whack_a_mole/presentation/widgets/meadow_background.dart';
import 'package:my_tiny_thinker/games/whack_a_mole/presentation/widgets/mole_hole_widget.dart';
import 'package:my_tiny_thinker/games/whack_a_mole/presentation/widgets/whack_a_mole_hud.dart';
import 'package:my_tiny_thinker/games/whack_a_mole/repository/whack_a_mole_settings_repository.dart';

class WhackAMoleGameScreen extends ConsumerStatefulWidget {
  const WhackAMoleGameScreen({super.key});

  @override
  ConsumerState<WhackAMoleGameScreen> createState() =>
      _WhackAMoleGameScreenState();
}

class _WhackAMoleGameScreenState extends ConsumerState<WhackAMoleGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Ticker? _ticker;
  final _particleKey = GlobalKey<ParticleSystemState>();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(whackAMoleControllerProvider, (prev, next) {
      _syncTicker(next.sessionPhase);
      if (next.sessionPhase == WhackSessionPhase.finished && !_saved) {
        _onFinished();
      }
    });
  }

  Future<void> _start() async {
    if (!await ensureCanStartGame(context, ref, GameId.whackAMole)) {
      return;
    }
    if (!mounted) return;
    _saved = false;
    final settings = ref.read(whackAMoleSettingsProvider);
    ref.read(whackAMoleControllerProvider.notifier).reset();
    ref.read(whackAMoleControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playGameMusic();
    }
    _syncTicker(WhackSessionPhase.playing);
  }

  void _syncTicker(WhackSessionPhase phase) {
    if (phase == WhackSessionPhase.playing) {
      _ticker ??= createTicker((_) {
        ref.read(whackAMoleControllerProvider.notifier).tick(1 / 60);
      });
      if (!_ticker!.isActive) _ticker!.start();
    } else {
      _ticker?.stop();
    }
  }

  Future<void> _onFinished() async {
    _saved = true;
    _ticker?.stop();
    final settings = ref.read(whackAMoleSettingsProvider);
    if (settings.soundEnabled) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    }
    await ref.read(whackAMoleControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(whackAMoleControllerProvider.notifier).pause();
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
    ref.read(whackAMoleControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () => ref.read(whackAMoleControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(whackAMoleControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(whackAMoleControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onTapHole(String holeId) {
    final settings = ref.read(whackAMoleSettingsProvider);
    final hit =
        ref.read(whackAMoleControllerProvider.notifier).tapHole(holeId);

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
      whackAMoleControllerProvider.select((s) => s.sessionPhase),
    );
    final settings = ref.watch(whackAMoleSettingsProvider);
    final practice = settings.practiceMode;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && sessionPhase != WhackSessionPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: MeadowBackground(
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
                        whackAMoleControllerProvider
                            .select((s) => s.remainingSeconds),
                      ),
                      unlimitedTime: practice,
                      coinsEarned: ref.watch(
                        whackAMoleControllerProvider.select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        whackAMoleControllerProvider.select((s) => s.starsEarned),
                      ),
                      onPause: _showPauseMenu,
                    ),
                    if (practice)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => ref
                              .read(whackAMoleControllerProvider.notifier)
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
                    WhackProgressMeter(
                      progress: ref.watch(
                        whackAMoleControllerProvider
                            .select((s) => s.progressMeter),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _PlayArea(
                        particleKey: _particleKey,
                        onTapHole: _onTapHole,
                        largerTouch: settings.largerTouchTargets,
                      ),
                    ),
                  ],
                ),
                GameFeedbackOverlay(
                  message: ref.watch(
                    whackAMoleControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    whackAMoleControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    whackAMoleControllerProvider.select((s) => s.showMascot),
                  ),
                ),
                ..._cheerOverlays(),
                if (sessionPhase == WhackSessionPhase.paused)
                  GamePausedOverlay(
                    onResume: () =>
                        ref.read(whackAMoleControllerProvider.notifier).resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (sessionPhase == WhackSessionPhase.finished)
                  WhackVictoryOverlay(
                    result: ref
                        .read(whackAMoleControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref.read(whackAMoleControllerProvider.notifier).reset();
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

  List<Widget> _cheerOverlays() {
    final cheers = ref.watch(
      whackAMoleControllerProvider.select((s) => s.cheers),
    );
    return cheers.map((c) {
      return Positioned(
        left: c.side ? null : 8,
        right: c.side ? 8 : null,
        bottom: 120,
        child: IgnorePointer(child: CheerAnimalWidget(cheer: c)),
      );
    }).toList();
  }
}

class _PlayArea extends ConsumerWidget {
  const _PlayArea({
    required this.particleKey,
    required this.onTapHole,
    required this.largerTouch,
  });

  final GlobalKey<ParticleSystemState> particleKey;
  final void Function(String holeId) onTapHole;
  final bool largerTouch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holes =
        ref.watch(whackAMoleControllerProvider.select((s) => s.holes));
    final mole =
        ref.watch(whackAMoleControllerProvider.select((s) => s.activeMole));
    final sparkles =
        ref.watch(whackAMoleControllerProvider.select((s) => s.sparkles));
    final showSparkles = ref.watch(
      whackAMoleControllerProvider.select((s) => s.showSparkles),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(whackAMoleControllerProvider.notifier).setPlayArea(
                Size(constraints.maxWidth, constraints.maxHeight),
              );
        });

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (details) {
            ref
                .read(whackAMoleControllerProvider.notifier)
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
                        particleCount: 32,
                        autoStart: false,
                      ),
                    ),
                  ),
                ...holes.map((h) {
                  final size = h.radius * 2.4 * (largerTouch ? 1.08 : 1.0);
                  final holeMole =
                      mole != null && mole.holeId == h.id ? mole : null;
                  return Positioned(
                    left: h.centerX - size / 2,
                    top: h.centerY - size * 0.55,
                    child: MoleHoleWidget(
                      hole: h,
                      mole: holeMole,
                      largerTouch: largerTouch,
                      onTap: () => onTapHole(h.id),
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
                          offset: Offset(0, -20 * s.progress),
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
