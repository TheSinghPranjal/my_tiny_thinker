import 'dart:math' as math;

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
import 'package:my_tiny_thinker/games/magical_flower_garden/controllers/flower_garden_controller.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/models/flower_garden_models.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/presentation/widgets/flower_widget.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/presentation/widgets/garden_background.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/presentation/widgets/garden_critters.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/presentation/widgets/garden_hud.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/repository/flower_garden_settings_repository.dart';

class FlowerGardenGameScreen extends ConsumerStatefulWidget {
  const FlowerGardenGameScreen({super.key});

  @override
  ConsumerState<FlowerGardenGameScreen> createState() =>
      _FlowerGardenGameScreenState();
}

class _FlowerGardenGameScreenState extends ConsumerState<FlowerGardenGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Ticker? _ticker;
  final _particleKey = GlobalKey<ParticleSystemState>();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(flowerGardenControllerProvider, (prev, next) {
      _syncTicker(next.sessionPhase);
      if (next.sessionPhase == GardenSessionPhase.finished && !_saved) {
        _onFinished();
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(flowerGardenSettingsProvider);
    ref.read(flowerGardenControllerProvider.notifier).reset();
    ref.read(flowerGardenControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playGameMusic();
    }
    _syncTicker(GardenSessionPhase.playing);
  }

  void _syncTicker(GardenSessionPhase phase) {
    if (phase == GardenSessionPhase.playing) {
      _ticker ??= createTicker((_) {
        ref.read(flowerGardenControllerProvider.notifier).tick(1 / 60);
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
    await ref.read(flowerGardenControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(flowerGardenControllerProvider.notifier).pause();
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
    ref.read(flowerGardenControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () =>
          ref.read(flowerGardenControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(flowerGardenControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(flowerGardenControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onTapFlower(String flowerId) {
    final settings = ref.read(flowerGardenSettingsProvider);
    final ok =
        ref.read(flowerGardenControllerProvider.notifier).tapFlower(flowerId);
    if (!ok) return;
    if (settings.soundEnabled) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
      ref.read(audioServiceProvider).playSfx(SoundEffect.reward);
    }
    if (settings.hapticsEnabled) {
      ref.read(hapticServiceProvider).trigger(HapticType.light);
    }
    final flower = ref.read(flowerGardenControllerProvider).flower;
    if (flower != null) {
      _particleKey.currentState?.emit(origin: Offset(flower.x, flower.y));
    }
    if (settings.soundEnabled) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.coin);
    }
  }

  void _onTapBird() {
    final settings = ref.read(flowerGardenSettingsProvider);
    final ok = ref.read(flowerGardenControllerProvider.notifier).tapBird();
    if (!ok) return;
    if (settings.soundEnabled) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.buttonTap);
    }
    if (settings.hapticsEnabled) {
      ref.read(hapticServiceProvider).trigger(HapticType.light);
    }
    _particleKey.currentState?.emit();
  }

  @override
  Widget build(BuildContext context) {
    final sessionPhase = ref.watch(
      flowerGardenControllerProvider.select((s) => s.sessionPhase),
    );
    final settings = ref.watch(flowerGardenSettingsProvider);
    final showRainbow = ref.watch(
      flowerGardenControllerProvider.select((s) => s.showRainbow),
    );
    final showSunbeam = ref.watch(
      flowerGardenControllerProvider.select((s) => s.showSunbeam),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && sessionPhase != GardenSessionPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: GardenBackground(
        reducedMotion: settings.reducedMotion,
        showRainbow: showRainbow,
        showSunbeam: showSunbeam,
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
                        flowerGardenControllerProvider.select((s) => s.remainingSeconds),
                      ),
                      coinsEarned: ref.watch(
                        flowerGardenControllerProvider.select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        flowerGardenControllerProvider.select((s) => s.starsEarned),
                      ),
                      onPause: _showPauseMenu,
                    ),
                    Expanded(
                      child: _GardenPlayArea(
                        particleKey: _particleKey,
                        onTapFlower: _onTapFlower,
                        onTapBird: _onTapBird,
                      ),
                    ),
                  ],
                ),
                GameFeedbackOverlay(
                  message: ref.watch(
                    flowerGardenControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    flowerGardenControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    flowerGardenControllerProvider
                        .select((s) => s.showMascot),
                  ),
                ),
                if (sessionPhase == GardenSessionPhase.paused)
                  GamePausedOverlay(
                    onResume: () => ref.read(flowerGardenControllerProvider.notifier).resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (sessionPhase == GardenSessionPhase.finished)
                  GardenVictoryOverlay(
                    result: ref
                        .read(flowerGardenControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref.read(flowerGardenControllerProvider.notifier).reset();
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


class _GardenPlayArea extends ConsumerWidget {
  const _GardenPlayArea({
    required this.particleKey,
    required this.onTapFlower,
    required this.onTapBird,
  });

  final GlobalKey<ParticleSystemState> particleKey;
  final void Function(String flowerId) onTapFlower;
  final VoidCallback onTapBird;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flower = ref.watch(
      flowerGardenControllerProvider.select((s) => s.flower),
    );
    final pollinators = ref.watch(
      flowerGardenControllerProvider.select((s) => s.pollinators),
    );
    final bird = ref.watch(
      flowerGardenControllerProvider.select((s) => s.bird),
    );
    final showSparkles = ref.watch(
      flowerGardenControllerProvider.select((s) => s.showSparkles),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(flowerGardenControllerProvider.notifier).setPlayArea(
                Size(constraints.maxWidth, constraints.maxHeight),
              );
        });

        final flowerSize =
            math.min(constraints.maxWidth, constraints.maxHeight) * 0.48;

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
              ...pollinators
                  .where((p) => p.phase != PollinatorPhase.gone)
                  .map((p) => PollinatorWidget(pollinator: p)),
              if (bird != null && bird.phase != BirdPhase.gone)
                BirdWidget(bird: bird, onTap: onTapBird),
              if (flower != null && flower.isVisible)
                Positioned(
                  left: flower.x - flowerSize / 2,
                  top: flower.y - flowerSize / 2,
                  child: FlowerWidget(
                    flower: flower,
                    size: flowerSize,
                    canTap: flower.canTap,
                    onTap: () => onTapFlower(flower.id),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
