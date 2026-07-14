import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_feedback_banner.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/controllers/cloud_pop_garden_controller.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/logic/cloud_pop_garden_logic.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/models/cloud_pop_garden_models.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/presentation/widgets/cloud_pop_background.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/presentation/widgets/cloud_pop_hud.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/presentation/widgets/cloud_widget.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/repository/cloud_pop_garden_settings_repository.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/presentation/widgets/flower_widget.dart';

class CloudPopGardenGameScreen extends ConsumerStatefulWidget {
  const CloudPopGardenGameScreen({super.key});

  @override
  ConsumerState<CloudPopGardenGameScreen> createState() =>
      _CloudPopGardenGameScreenState();
}

class _CloudPopGardenGameScreenState extends ConsumerState<CloudPopGardenGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Ticker? _ticker;
  final _particleKey = GlobalKey<ParticleSystemState>();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(cloudPopGardenControllerProvider, (prev, next) {
      _syncTicker(next.sessionPhase);
      if (next.sessionPhase == CloudPopSessionPhase.finished && !_saved) {
        _onFinished();
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(cloudPopGardenSettingsProvider);
    ref.read(cloudPopGardenControllerProvider.notifier).reset();
    ref.read(cloudPopGardenControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playMusic(asset: 'audio/ambient_music.mp3');
    }
    _syncTicker(CloudPopSessionPhase.playing);
  }

  void _syncTicker(CloudPopSessionPhase phase) {
    if (phase == CloudPopSessionPhase.playing) {
      _ticker ??= createTicker((_) {
        ref.read(cloudPopGardenControllerProvider.notifier).tick(1 / 60);
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
    await ref.read(cloudPopGardenControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(cloudPopGardenControllerProvider.notifier).pause();
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
    ref.read(cloudPopGardenControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () =>
          ref.read(cloudPopGardenControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(cloudPopGardenControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () {
        ref.read(cloudPopGardenControllerProvider.notifier).pause();
        context.push(AppRoutes.parentZone);
      },
    );
  }

  void _onTapCloud(String cloudId) {
    final settings = ref.read(cloudPopGardenSettingsProvider);
    final result =
        ref.read(cloudPopGardenControllerProvider.notifier).tapCloud(cloudId);
    if (result == null || result == CloudTapResult.ignored) return;

    if (settings.hapticsEnabled) {
      ref.read(hapticServiceProvider).trigger(
            result == CloudTapResult.successRain
                ? HapticType.success
                : HapticType.light,
          );
    }

    if (settings.soundEnabled) {
      switch (result) {
        case CloudTapResult.successRain:
          ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
          ref.read(audioServiceProvider).playSfx(SoundEffect.reward);
          if (settings.rainSoundEnabled) {
            ref.read(audioServiceProvider).playSfx(SoundEffect.coin);
          }
        case CloudTapResult.earlyThunder:
          ref.read(audioServiceProvider).playSfx(SoundEffect.wrong);
        case CloudTapResult.lateBounce:
          ref.read(audioServiceProvider).playSfx(SoundEffect.buttonTap);
        case CloudTapResult.ignored:
          break;
      }
    }

    if (result == CloudTapResult.successRain) {
      final cloud = ref
          .read(cloudPopGardenControllerProvider)
          .clouds
          .firstWhere((c) => c.id == cloudId);
      _particleKey.currentState?.emit(origin: Offset(cloud.x, cloud.y + 40));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionPhase = ref.watch(
      cloudPopGardenControllerProvider.select((s) => s.sessionPhase),
    );
    final settings = ref.watch(cloudPopGardenSettingsProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && sessionPhase != CloudPopSessionPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: CloudPopBackground(
        reducedMotion: settings.reducedMotion,
        showRainbow: ref.watch(
          cloudPopGardenControllerProvider.select((s) => s.showRainbow),
        ),
        rainbowProgress: ref.watch(
          cloudPopGardenControllerProvider.select((s) => s.rainbowProgress),
        ),
        intensity: settings.animationIntensity,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    CloudPopHud(
                      remainingSeconds: ref.watch(
                        cloudPopGardenControllerProvider
                            .select((s) => s.remainingSeconds),
                      ),
                      flowersWatered: ref.watch(
                        cloudPopGardenControllerProvider
                            .select((s) => s.flowersWatered),
                      ),
                      coinsEarned: ref.watch(
                        cloudPopGardenControllerProvider
                            .select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        cloudPopGardenControllerProvider
                            .select((s) => s.starsEarned),
                      ),
                      onPause: _showPauseMenu,
                    ),
                    Expanded(
                      child: _PlayArea(
                        particleKey: _particleKey,
                        lightningEnabled: settings.lightningEnabled,
                        onTapCloud: _onTapCloud,
                      ),
                    ),
                  ],
                ),
                GameFeedbackOverlay(
                  message: ref.watch(
                    cloudPopGardenControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    cloudPopGardenControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    cloudPopGardenControllerProvider
                        .select((s) => s.showMascot),
                  ),
                  rewardShadowColor: const Color(0xFF0277BD),
                ),
                if (ref.watch(
                  cloudPopGardenControllerProvider.select((s) => s.showMascot),
                ))
                  const Positioned(
                    bottom: 120,
                    left: 0,
                    right: 0,
                    child: Center(child: MascotWidget(size: 64, waving: true)),
                  ),
                if (sessionPhase == CloudPopSessionPhase.paused)
                  const _PausedOverlay(),
                if (sessionPhase == CloudPopSessionPhase.finished)
                  CloudPopVictoryOverlay(
                    result: ref
                        .read(cloudPopGardenControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref.read(cloudPopGardenControllerProvider.notifier).reset();
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
        color: const Color(0xFF0277BD).withValues(alpha: 0.55),
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

class _PlayArea extends ConsumerWidget {
  const _PlayArea({
    required this.particleKey,
    required this.lightningEnabled,
    required this.onTapCloud,
  });

  final GlobalKey<ParticleSystemState> particleKey;
  final bool lightningEnabled;
  final void Function(String cloudId) onTapCloud;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowers = ref.watch(
      cloudPopGardenControllerProvider.select((s) => s.flowers),
    );
    final clouds = ref.watch(
      cloudPopGardenControllerProvider.select((s) => s.clouds),
    );
    final showSparkles = ref.watch(
      cloudPopGardenControllerProvider.select((s) => s.showSparkles),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(cloudPopGardenControllerProvider.notifier).setPlayArea(
                Size(constraints.maxWidth, constraints.maxHeight),
              );
        });

        final flowerSize =
            math.min(constraints.maxWidth, constraints.maxHeight) * 0.16;

        return ClipRect(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              if (showSparkles)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ParticleSystem(
                      key: particleKey,
                      particleCount: 24,
                      autoStart: false,
                    ),
                  ),
                ),
              ...flowers.map((f) {
                final entity = CloudPopGardenLogic.toFlowerEntity(f);
                return Positioned(
                  left: entity.x - flowerSize / 2,
                  top: entity.y - flowerSize / 2,
                  child: IgnorePointer(
                    child: FlowerWidget(
                      flower: entity,
                      size: flowerSize,
                      canTap: false,
                      onTap: () {},
                    ),
                  ),
                );
              }),
              ...clouds
                  .where((c) => c.phase != CloudPhase.gone && c.spawnDelay <= 0)
                  .map(
                    (c) => CloudWidget(
                      cloud: c,
                      lightningEnabled: lightningEnabled,
                      onTap: () => onTapCloud(c.id),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}
