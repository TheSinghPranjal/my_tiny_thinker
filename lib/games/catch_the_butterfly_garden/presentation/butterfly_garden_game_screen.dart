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
      ref.read(audioServiceProvider).playGameMusic();
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
    _audio?.playHomeMusic();
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
      onSettings: () async {
        ref.read(butterflyGardenControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
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
                    GameSessionHud(
                      remainingSeconds: ref.watch(
                        butterflyGardenControllerProvider.select((s) => s.remainingSeconds),
                      ),
                      coinsEarned: ref.watch(
                        butterflyGardenControllerProvider.select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        butterflyGardenControllerProvider.select((s) => s.starsEarned),
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
                  GamePausedOverlay(
                    onResume: () => ref.read(butterflyGardenControllerProvider.notifier).resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
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
                (b) {
                  final half = GardenButterflyWidget.layoutSize(largerTouch, b.sizeScale) / 2;
                  return Positioned(
                    left: b.x - half - 8,
                    top: b.y - half - 8,
                    child: GardenButterflyWidget(
                      butterfly: b,
                      largerTouch: largerTouch,
                      onTap: () => onTapButterfly(b.id),
                    ),
                  );
                },
              ),
              ...bees.map(
                (bee) {
                  final half = GardenBeeWidget.layoutSize(largerTouch) / 2;
                  return Positioned(
                    left: bee.x - half,
                    top: bee.y - half,
                    child: GardenBeeWidget(
                      bee: bee,
                      largerTouch: largerTouch,
                      onTap: () => onTapBee(bee.id),
                    ),
                  );
                },
              ),
              Positioned(
                left: basket.x - ButterflyBasketWidget.layoutWidth(largerTouch) / 2,
                top: basket.y - ButterflyBasketWidget.layoutHeight(largerTouch) * 0.55,
                child: ButterflyBasketWidget(
                  basket: basket,
                  largerTouch: largerTouch,
                ),
              ),
              if (butterflies.any((b) => b.canTap))
                const Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: _TapHint(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TapHint extends StatefulWidget {
  const _TapHint();

  @override
  State<_TapHint> createState() => _TapHintState();
}

class _TapHintState extends State<_TapHint> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: FadeTransition(
        opacity: Tween(begin: 0.8, end: 1.0).animate(_c),
        child: ScaleTransition(
          scale: Tween(begin: 0.97, end: 1.04).animate(_c),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF66BB6A), Color(0xFF42A5F5), Color(0xFFAB47BC)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7B1FA2).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Tap butterflies! 🦋  Bees fly away! 🐝',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
