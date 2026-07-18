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
import 'package:my_tiny_thinker/core/widgets/game_paused_overlay.dart';
import 'package:my_tiny_thinker/games/bunny_hop_adventure/controllers/bunny_hop_controller.dart';
import 'package:my_tiny_thinker/games/bunny_hop_adventure/models/bunny_hop_models.dart';
import 'package:my_tiny_thinker/games/bunny_hop_adventure/presentation/widgets/bunny_hop_hud.dart';
import 'package:my_tiny_thinker/games/bunny_hop_adventure/presentation/widgets/bunny_hop_widgets.dart';
import 'package:my_tiny_thinker/games/bunny_hop_adventure/presentation/widgets/river_background.dart';
import 'package:my_tiny_thinker/games/bunny_hop_adventure/repository/bunny_hop_settings_repository.dart';

class BunnyHopGameScreen extends ConsumerStatefulWidget {
  const BunnyHopGameScreen({super.key});

  @override
  ConsumerState<BunnyHopGameScreen> createState() => _BunnyHopGameScreenState();
}

class _BunnyHopGameScreenState extends ConsumerState<BunnyHopGameScreen>
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

    ref.listenManual(bunnyHopControllerProvider, (prev, next) {
      _syncTicker(next.sessionPhase);
      if (next.sessionPhase == BunnyHopSessionPhase.finished && !_saved) {
        _onFinished();
      }
      if (prev != null && next.showSparkles) {
        _particleKey.currentState?.emit();
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(bunnyHopSettingsProvider);
    ref.read(bunnyHopControllerProvider.notifier).reset();
    ref.read(bunnyHopControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playMusic(asset: 'audio/ambient_music.mp3');
    }
    _syncTicker(BunnyHopSessionPhase.playing);
  }

  void _syncTicker(BunnyHopSessionPhase phase) {
    if (phase == BunnyHopSessionPhase.playing) {
      _ticker ??= createTicker((_) {
        ref.read(bunnyHopControllerProvider.notifier).tick(1 / 60);
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
    await ref.read(bunnyHopControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(bunnyHopControllerProvider.notifier).pause();
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
    ref.read(bunnyHopControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () => ref.read(bunnyHopControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(bunnyHopControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(bunnyHopControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onTap() {
    final settings = ref.read(bunnyHopSettingsProvider);
    final ok = ref.read(bunnyHopControllerProvider.notifier).tapHop();
    if (!ok) return;

    if (settings.hapticsEnabled) {
      ref.read(hapticServiceProvider).trigger(HapticType.light);
    }
    if (settings.soundEnabled) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.buttonTap);
    }
  }

  void _onTapWithFeedback() {
    _onTap();
    final settings = ref.read(bunnyHopSettingsProvider);
    final state = ref.read(bunnyHopControllerProvider);
    if (state.showSparkles) {
      if (settings.hapticsEnabled) {
        ref.read(hapticServiceProvider).trigger(HapticType.success);
      }
      if (settings.soundEnabled) {
        ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
        ref.read(audioServiceProvider).playSfx(SoundEffect.reward);
        ref.read(audioServiceProvider).playSfx(SoundEffect.coin);
      }
      _particleKey.currentState?.emit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionPhase = ref.watch(
      bunnyHopControllerProvider.select((s) => s.sessionPhase),
    );
    final settings = ref.watch(bunnyHopSettingsProvider);
    final envPhase = ref.watch(bunnyHopControllerProvider.select((s) => s.envPhase));
    final showCarrot = ref.watch(
      bunnyHopControllerProvider.select((s) => s.showCarrotCelebration),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && sessionPhase != BunnyHopSessionPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFB3E5FC),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  BunnyHopHud(
                    remainingSeconds: ref.watch(
                      bunnyHopControllerProvider.select((s) => s.remainingSeconds),
                    ),
                    totalHops: ref.watch(
                      bunnyHopControllerProvider.select((s) => s.totalHops),
                    ),
                    coinsEarned: ref.watch(
                      bunnyHopControllerProvider.select((s) => s.coinsEarned),
                    ),
                    onPause: _showPauseMenu,
                    largerFonts: settings.largerTouchTargets,
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _onTapWithFeedback,
                      child: _PlayArea(
                        envPhase: envPhase,
                        reducedMotion: settings.reducedMotion,
                        intensity: settings.animationIntensity,
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 72,
                left: 0,
                right: 0,
                child: GameFeedbackOverlay(
                  message: ref.watch(
                    bunnyHopControllerProvider.select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    bunnyHopControllerProvider.select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    bunnyHopControllerProvider.select((s) => s.showMascot),
                  ),
                ),
              ),
              if (showCarrot)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: AppColors.sunYellow.withValues(alpha: 0.1),
                    ),
                  ),
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
              if (sessionPhase == BunnyHopSessionPhase.paused)
                GamePausedOverlay(
                  onResume: () =>
                      ref.read(bunnyHopControllerProvider.notifier).resume(),
                  onOpenMenu: _showPauseMenu,
                ),
              if (sessionPhase == BunnyHopSessionPhase.finished)
                BunnyHopVictoryOverlay(
                  result: ref.read(bunnyHopControllerProvider.notifier).getResult(),
                  onPlayAgain: _start,
                  onHome: () {
                    ref.read(bunnyHopControllerProvider.notifier).reset();
                    context.go(AppRoutes.home);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayArea extends ConsumerWidget {
  const _PlayArea({
    required this.envPhase,
    required this.reducedMotion,
    required this.intensity,
  });

  final double envPhase;
  final bool reducedMotion;
  final double intensity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pads = ref.watch(bunnyHopControllerProvider.select((s) => s.lilyPads));
    final bunny = ref.watch(bunnyHopControllerProvider.select((s) => s.bunny));
    final carrot = ref.watch(bunnyHopControllerProvider.select((s) => s.carrot));
    final settings = ref.watch(bunnyHopSettingsProvider);
    final showMascot = ref.watch(bunnyHopControllerProvider.select((s) => s.showMascot));
    final inactivity = ref.watch(bunnyHopControllerProvider.select((s) => s.inactivityTimer));
    final canTap = ref.watch(bunnyHopControllerProvider.select((s) => s.canTap));
    final sessionPhase = ref.watch(
      bunnyHopControllerProvider.select((s) => s.sessionPhase),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(bunnyHopControllerProvider.notifier).setPlayArea(
                Size(constraints.maxWidth, constraints.maxHeight),
              );
        });

        return Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            RiverPlayScene(
              envPhase: envPhase,
              reducedMotion: reducedMotion,
              intensity: intensity,
            ),
            ...pads.map((p) => LilyPadWidget(pad: p)),
            CarrotWidget(carrot: carrot),
            BunnyWidget(
              bunny: bunny,
              largerTouch: settings.largerTouchTargets,
            ),
            if (sessionPhase == BunnyHopSessionPhase.playing && canTap)
              Positioned(
                left: 0,
                right: 0,
                bottom: 28,
                child: Center(
                  child: _TapHint(
                    hopping: bunny.phase == BunnyPhase.hopping,
                    pulse: inactivity > 3,
                  ),
                ),
              ),
            if (showMascot || inactivity > 8)
              Positioned(
                left: 16,
                bottom: 80,
                child: MascotWidget(
                  size: 64,
                  waving: showMascot || inactivity > 12,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TapHint extends StatelessWidget {
  const _TapHint({required this.hopping, required this.pulse});

  final bool hopping;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    final scale = pulse ? 1.06 : 1.0;
    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF43A047).withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          hopping ? 'Hop hop! 🐰' : 'Tap to hop! 👆',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E7D32),
          ),
        ),
      ),
    );
  }
}
