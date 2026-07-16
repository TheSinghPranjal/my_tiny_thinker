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
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/controllers/butterfly_garden_controller.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/models/butterfly_garden_models.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/presentation/widgets/butterfly_basket_widget.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/presentation/widgets/garden_background.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/presentation/widgets/garden_bee_widget.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/presentation/widgets/garden_butterfly_widget.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/presentation/widgets/garden_hud.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/repository/butterfly_garden_settings_repository.dart';

class ButterflyGardenGameScreen extends ConsumerStatefulWidget {
  const ButterflyGardenGameScreen({super.key});

  @override
  ConsumerState<ButterflyGardenGameScreen> createState() =>
      _ButterflyGardenGameScreenState();
}

class _ButterflyGardenGameScreenState extends ConsumerState<ButterflyGardenGameScreen>
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

    ref.listenManual(butterflyGardenControllerProvider, (prev, next) {
      _syncTicker(next.sessionPhase);
      if (next.sessionPhase == ButterflyGardenSessionPhase.finished && !_saved) {
        _onFinished();
      }
      if (next.showSparkles && _particleKey.currentState != null) {
        _particleKey.currentState?.emit();
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(butterflyGardenSettingsProvider);
    ref.read(butterflyGardenControllerProvider.notifier).reset();
    ref.read(butterflyGardenControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playMusic(asset: 'audio/ambient_music.mp3');
    }
    _syncTicker(ButterflyGardenSessionPhase.playing);
  }

  void _syncTicker(ButterflyGardenSessionPhase phase) {
    if (phase == ButterflyGardenSessionPhase.playing) {
      _ticker ??= createTicker((_) {
        ref.read(butterflyGardenControllerProvider.notifier).tick(1 / 60);
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
    await ref.read(butterflyGardenControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(butterflyGardenControllerProvider.notifier).pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.dispose();
    _audio?.stopMusic();
    super.dispose();
  }

  Future<void> _showPauseMenu() async {
    ref.read(butterflyGardenControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () => ref.read(butterflyGardenControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(butterflyGardenControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () {
        ref.read(butterflyGardenControllerProvider.notifier).pause();
        context.push(AppRoutes.parentZone);
      },
    );
  }

  void _onTapButterfly(String id) {
    final settings = ref.read(butterflyGardenSettingsProvider);
    final butterfly = ref
        .read(butterflyGardenControllerProvider)
        .butterflies
        .where((b) => b.id == id)
        .firstOrNull;
    if (butterfly == null) return;

    final ok = ref.read(butterflyGardenControllerProvider.notifier).tapButterfly(id);
    if (!ok) return;

    if (settings.hapticsEnabled) {
      ref.read(hapticServiceProvider).trigger(HapticType.light);
    }
    if (settings.soundEnabled) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
      ref.read(audioServiceProvider).playSfx(SoundEffect.reward);
      ref.read(audioServiceProvider).playSfx(SoundEffect.coin);
      if (butterfly.isGolden) {
        ref.read(audioServiceProvider).playSfx(SoundEffect.levelComplete);
      }
    }
  }

  void _onTapBee(String id) {
    final settings = ref.read(butterflyGardenSettingsProvider);
    final ok = ref.read(butterflyGardenControllerProvider.notifier).tapBee(id);
    if (!ok) return;

    if (settings.hapticsEnabled) {
      ref.read(hapticServiceProvider).trigger(HapticType.selection);
    }
    if (settings.soundEnabled) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.buttonTap);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionPhase = ref.watch(
      butterflyGardenControllerProvider.select((s) => s.sessionPhase),
    );
    final settings = ref.watch(butterflyGardenSettingsProvider);
    final envPhase = ref.watch(
      butterflyGardenControllerProvider.select((s) => s.envPhase),
    );
    final showGolden = ref.watch(
      butterflyGardenControllerProvider.select((s) => s.showGoldenCelebration),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && sessionPhase != ButterflyGardenSessionPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: GardenBackground(
        envPhase: envPhase,
        reducedMotion: settings.reducedMotion,
        intensity: settings.animationIntensity,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    GardenHud(
                      remainingSeconds: ref.watch(
                        butterflyGardenControllerProvider
                            .select((s) => s.remainingSeconds),
                      ),
                      butterfliesCaught: ref.watch(
                        butterflyGardenControllerProvider
                            .select((s) => s.butterfliesCaught),
                      ),
                      coinsEarned: ref.watch(
                        butterflyGardenControllerProvider
                            .select((s) => s.coinsEarned),
                      ),
                      largerFonts: settings.largerTouchTargets,
                      onPause: _showPauseMenu,
                    ),
                    Expanded(
                      child: _GardenPlayArea(
                        particleKey: _particleKey,
                        onTapButterfly: _onTapButterfly,
                        onTapBee: _onTapBee,
                        largerTouch: settings.largerTouchTargets,
                      ),
                    ),
                  ],
                ),
                GameFeedbackOverlay(
                  message: ref.watch(
                    butterflyGardenControllerProvider.select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    butterflyGardenControllerProvider.select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    butterflyGardenControllerProvider.select((s) => s.showMascot),
                  ),
                ),
                if (showGolden)
                  IgnorePointer(
                    child: Container(
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.15),
                      child: const Center(
                        child: Text('✨🦋✨', style: TextStyle(fontSize: 72)),
                      ),
                    ),
                  ),
                if (sessionPhase == ButterflyGardenSessionPhase.paused)
                  const _PausedOverlay(),
                if (sessionPhase == ButterflyGardenSessionPhase.finished)
                  GardenVictoryOverlay(
                    result: ref
                        .read(butterflyGardenControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref.read(butterflyGardenControllerProvider.notifier).reset();
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
        color: const Color(0xFF7B1FA2).withValues(alpha: 0.55),
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

class _GardenPlayArea extends ConsumerWidget {
  const _GardenPlayArea({
    required this.particleKey,
    required this.onTapButterfly,
    required this.onTapBee,
    required this.largerTouch,
  });

  final GlobalKey<ParticleSystemState> particleKey;
  final void Function(String id) onTapButterfly;
  final void Function(String id) onTapBee;
  final bool largerTouch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final butterflies =
        ref.watch(butterflyGardenControllerProvider.select((s) => s.butterflies));
    final bees = ref.watch(butterflyGardenControllerProvider.select((s) => s.bees));
    final basket = ref.watch(butterflyGardenControllerProvider.select((s) => s.basket));

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(butterflyGardenControllerProvider.notifier).setPlayArea(
                Size(constraints.maxWidth, constraints.maxHeight),
              );
        });

        return ClipRect(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: ParticleSystem(
                    key: particleKey,
                    particleCount: 40,
                    autoStart: false,
                  ),
                ),
              ),
              ...butterflies.map(
                (b) => Positioned(
                  left: b.x - (largerTouch ? 38 : 34) * b.sizeScale,
                  top: b.y - (largerTouch ? 38 : 34) * b.sizeScale,
                  child: GardenButterflyWidget(
                    butterfly: b,
                    largerTouch: largerTouch,
                    onTap: () => onTapButterfly(b.id),
                  ),
                ),
              ),
              ...bees.map(
                (bee) => Positioned(
                  left: bee.x - (largerTouch ? 30 : 26),
                  top: bee.y - (largerTouch ? 30 : 26),
                  child: GardenBeeWidget(
                    bee: bee,
                    largerTouch: largerTouch,
                    onTap: () => onTapBee(bee.id),
                  ),
                ),
              ),
              Positioned(
                left: basket.x - (largerTouch ? 60 : 50),
                top: basket.y - (largerTouch ? 54 : 46),
                child: ButterflyBasketWidget(
                  basket: basket,
                  largerTouch: largerTouch,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
