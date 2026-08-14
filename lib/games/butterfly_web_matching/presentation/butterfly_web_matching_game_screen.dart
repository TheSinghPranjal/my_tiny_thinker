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
import 'package:my_tiny_thinker/games/butterfly_web_matching/controllers/butterfly_web_matching_controller.dart';
import 'package:my_tiny_thinker/games/butterfly_web_matching/models/butterfly_web_matching_models.dart';
import 'package:my_tiny_thinker/games/butterfly_web_matching/presentation/widgets/butterfly_web_hud.dart';
import 'package:my_tiny_thinker/games/butterfly_web_matching/presentation/widgets/web_match_butterfly_widget.dart';
import 'package:my_tiny_thinker/games/butterfly_web_matching/repository/butterfly_web_matching_settings_repository.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/presentation/widgets/garden_background.dart';

class ButterflyWebMatchingGameScreen extends ConsumerStatefulWidget {
  const ButterflyWebMatchingGameScreen({super.key});

  @override
  ConsumerState<ButterflyWebMatchingGameScreen> createState() =>
      _ButterflyWebMatchingGameScreenState();
}

class _ButterflyWebMatchingGameScreenState
    extends ConsumerState<ButterflyWebMatchingGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Ticker? _ticker;
  final _particleKey = GlobalKey<ParticleSystemState>();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(butterflyWebMatchingControllerProvider, (prev, next) {
      _syncTicker(next.sessionPhase);
      if (next.sessionPhase == WebMatchSessionPhase.finished && !_saved) {
        _onFinished();
      }
    });
  }

  Future<void> _start() async {
    if (!await ensureCanStartGame(context, ref, GameId.butterflyWebMatching)) {
      return;
    }
    if (!mounted) return;
    _saved = false;
    final settings = ref.read(butterflyWebMatchingSettingsProvider);
    ref.read(butterflyWebMatchingControllerProvider.notifier).reset();
    ref
        .read(butterflyWebMatchingControllerProvider.notifier)
        .startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playGameMusic();
    }
    _syncTicker(WebMatchSessionPhase.playing);
  }

  void _syncTicker(WebMatchSessionPhase phase) {
    if (phase == WebMatchSessionPhase.playing) {
      _ticker ??= createTicker((_) {
        ref.read(butterflyWebMatchingControllerProvider.notifier).tick(1 / 60);
      });
      if (!_ticker!.isActive) _ticker!.start();
    } else {
      _ticker?.stop();
    }
  }

  Future<void> _onFinished() async {
    _saved = true;
    _ticker?.stop();
    final settings = ref.read(butterflyWebMatchingSettingsProvider);
    if (settings.soundEnabled) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    }
    await ref.read(butterflyWebMatchingControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(butterflyWebMatchingControllerProvider.notifier).pause();
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
    ref.read(butterflyWebMatchingControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () =>
          ref.read(butterflyWebMatchingControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(butterflyWebMatchingControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(butterflyWebMatchingControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onTapButterfly(String id) {
    final settings = ref.read(butterflyWebMatchingSettingsProvider);
    final result = ref
        .read(butterflyWebMatchingControllerProvider.notifier)
        .tapButterfly(id);

    if (result == 'ignored') return;

    if (settings.hapticsEnabled) {
      ref.read(hapticServiceProvider).trigger(
            result == 'match' ? HapticType.medium : HapticType.light,
          );
    }

    if (!settings.soundEnabled) {
      if (result == 'match' && settings.celebrationsEnabled) {
        _particleKey.currentState?.emit();
      }
      return;
    }

    switch (result) {
      case 'selected':
        ref.read(audioServiceProvider).playSfx(SoundEffect.buttonTap);
      case 'match':
        ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
        ref.read(audioServiceProvider).playSfx(SoundEffect.reward);
        if (settings.coinRewardsEnabled) {
          ref.read(audioServiceProvider).playSfx(SoundEffect.coin);
        }
        if (settings.celebrationsEnabled) {
          _particleKey.currentState?.emit();
        }
      case 'mismatch':
        ref.read(audioServiceProvider).playSfx(SoundEffect.buttonTap);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionPhase = ref.watch(
      butterflyWebMatchingControllerProvider.select((s) => s.sessionPhase),
    );
    final settings = ref.watch(butterflyWebMatchingSettingsProvider);
    final practice = settings.practiceMode;
    final envPhase = ref.watch(
      butterflyWebMatchingControllerProvider.select((s) => s.envPhase),
    );
    final bloom = ref.watch(
      butterflyWebMatchingControllerProvider.select((s) => s.gardenBloom),
    );
    final showRainbow = ref.watch(
      butterflyWebMatchingControllerProvider.select((s) => s.showRainbow),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && sessionPhase != WebMatchSessionPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: GardenBackground(
        envPhase: envPhase,
        reducedMotion: settings.reducedMotion,
        intensity: 0.85 + bloom * 0.4,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    GameSessionHud(
                      remainingSeconds: ref.watch(
                        butterflyWebMatchingControllerProvider
                            .select((s) => s.remainingSeconds),
                      ),
                      unlimitedTime: practice,
                      coinsEarned: ref.watch(
                        butterflyWebMatchingControllerProvider
                            .select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        butterflyWebMatchingControllerProvider
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
                                butterflyWebMatchingControllerProvider.notifier,
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
                    ButterflyWebProgressBar(
                      pairsMatched: ref.watch(
                        butterflyWebMatchingControllerProvider
                            .select((s) => s.pairsMatched),
                      ),
                      pairCount: settings.effectivePairCount,
                      gardenBloom: bloom,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _PlayArea(
                        particleKey: _particleKey,
                        onTapButterfly: _onTapButterfly,
                        largerTouch: settings.largerTouchTargets,
                      ),
                    ),
                  ],
                ),
                if (showRainbow)
                  const Positioned(
                    top: 100,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Text(
                        '🌈',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 42),
                      ),
                    ),
                  ),
                GameFeedbackOverlay(
                  message: ref.watch(
                    butterflyWebMatchingControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    butterflyWebMatchingControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    butterflyWebMatchingControllerProvider
                        .select((s) => s.showMascot),
                  ),
                ),
                if (sessionPhase == WebMatchSessionPhase.paused)
                  GamePausedOverlay(
                    onResume: () => ref
                        .read(butterflyWebMatchingControllerProvider.notifier)
                        .resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (sessionPhase == WebMatchSessionPhase.finished)
                  ButterflyWebVictoryOverlay(
                    result: ref
                        .read(butterflyWebMatchingControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref
                          .read(butterflyWebMatchingControllerProvider.notifier)
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
    required this.onTapButterfly,
    required this.largerTouch,
  });

  final GlobalKey<ParticleSystemState> particleKey;
  final void Function(String id) onTapButterfly;
  final bool largerTouch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final butterflies = ref.watch(
      butterflyWebMatchingControllerProvider.select((s) => s.butterflies),
    );
    final selectedId = ref.watch(
      butterflyWebMatchingControllerProvider.select((s) => s.selectedId),
    );
    final sparkles = ref.watch(
      butterflyWebMatchingControllerProvider.select((s) => s.sparkles),
    );
    final showSparkles = ref.watch(
      butterflyWebMatchingControllerProvider.select((s) => s.showSparkles),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(butterflyWebMatchingControllerProvider.notifier)
              .setPlayArea(Size(constraints.maxWidth, constraints.maxHeight));
        });

        final size = WebMatchButterflyWidget.layoutSize(largerTouch);

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (details) {
            ref
                .read(butterflyWebMatchingControllerProvider.notifier)
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
                        particleCount: 36,
                        autoStart: false,
                      ),
                    ),
                  ),
                ...butterflies.map((b) {
                  final boxW = size + 24;
                  final boxH = size + 48;
                  return Positioned(
                    left: b.x - boxW / 2,
                    top: b.y - boxH / 2,
                    child: WebMatchButterflyWidget(
                      butterfly: b,
                      largerTouch: largerTouch,
                      selected: selectedId == b.id,
                      onTap: () => onTapButterfly(b.id),
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
                          child: const Text('🌸', style: TextStyle(fontSize: 20)),
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
