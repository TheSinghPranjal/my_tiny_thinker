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
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/controllers/hungry_teddy_controller.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/logic/hungry_teddy_logic.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/models/hungry_teddy_models.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/presentation/widgets/cupcake_widget.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/presentation/widgets/party_background.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/presentation/widgets/party_visitor_widget.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/presentation/widgets/teddy_hud.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/presentation/widgets/teddy_widget.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/repository/hungry_teddy_settings_repository.dart';

class HungryTeddyGameScreen extends ConsumerStatefulWidget {
  const HungryTeddyGameScreen({super.key});

  @override
  ConsumerState<HungryTeddyGameScreen> createState() => _HungryTeddyGameScreenState();
}

class _HungryTeddyGameScreenState extends ConsumerState<HungryTeddyGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Ticker? _ticker;
  final _particleKey = GlobalKey<ParticleSystemState>();
  final _playAreaKey = GlobalKey();
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

    ref.listenManual(hungryTeddyControllerProvider, (prev, next) {
      _syncTicker(next.sessionPhase);
      if (next.sessionPhase == HungryTeddySessionPhase.finished && !_saved) {
        _onFinished();
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(hungryTeddySettingsProvider);
    ref.read(hungryTeddyControllerProvider.notifier).reset();
    ref.read(hungryTeddyControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playMusic(asset: 'audio/ambient_music.mp3');
    }
    _syncTicker(HungryTeddySessionPhase.playing);
  }

  void _syncTicker(HungryTeddySessionPhase phase) {
    if (phase == HungryTeddySessionPhase.playing) {
      _ticker ??= createTicker((_) {
        ref.read(hungryTeddyControllerProvider.notifier).tick(1 / 60);
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
    await ref.read(hungryTeddyControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(hungryTeddyControllerProvider.notifier).pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.dispose();
    _audio?.stopMusic();
    super.dispose();
  }

  Offset? _toPlayAreaLocal(Offset global) {
    final box = _playAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    return box.globalToLocal(global);
  }

  Future<void> _showPauseMenu() async {
    ref.read(hungryTeddyControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () => ref.read(hungryTeddyControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(hungryTeddyControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () {
        ref.read(hungryTeddyControllerProvider.notifier).pause();
        context.push(AppRoutes.parentZone);
      },
    );
  }

  void _onDragStart(String id, DragStartDetails details) {
    final local = _toPlayAreaLocal(details.globalPosition);
    if (local == null) return;
    final settings = ref.read(hungryTeddySettingsProvider);
    final ok = ref.read(hungryTeddyControllerProvider.notifier).startDrag(id, local);
    if (!ok) return;
    if (settings.hapticsEnabled) {
      ref.read(hapticServiceProvider).trigger(HapticType.light);
    }
    if (settings.soundEnabled) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.buttonTap);
    }
  }

  void _onDragUpdate(String id, DragUpdateDetails details) {
    final local = _toPlayAreaLocal(details.globalPosition);
    if (local == null) return;
    ref.read(hungryTeddyControllerProvider.notifier).updateDrag(id, local);
  }

  void _onDragEnd(String id, DragEndDetails details) {
    final settings = ref.read(hungryTeddySettingsProvider);
    ref.read(hungryTeddyControllerProvider.notifier).endDrag(id);
    final state = ref.read(hungryTeddyControllerProvider);
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

  void _onTapVisitor(String id) {
    final settings = ref.read(hungryTeddySettingsProvider);
    final ok = ref.read(hungryTeddyControllerProvider.notifier).tapVisitor(id);
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
      hungryTeddyControllerProvider.select((s) => s.sessionPhase),
    );
    final settings = ref.watch(hungryTeddySettingsProvider);
    final evening = ref.watch(hungryTeddyControllerProvider.select((s) => s.eveningFactor));
    final envPhase = ref.watch(hungryTeddyControllerProvider.select((s) => s.envPhase));
    final showGolden = ref.watch(
      hungryTeddyControllerProvider.select((s) => s.showGoldenCelebration),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && sessionPhase != HungryTeddySessionPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: PartyBackground(
        eveningFactor: evening,
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
                    TeddyHud(
                      remainingSeconds: ref.watch(
                        hungryTeddyControllerProvider.select((s) => s.remainingSeconds),
                      ),
                      cupcakesFed: ref.watch(
                        hungryTeddyControllerProvider.select((s) => s.cupcakesFed),
                      ),
                      coinsEarned: ref.watch(
                        hungryTeddyControllerProvider.select((s) => s.coinsEarned),
                      ),
                      onPause: _showPauseMenu,
                      largerFonts: settings.largerTouchTargets,
                    ),
                    Expanded(
                      child: _PlayArea(
                        key: _playAreaKey,
                        onDragStart: _onDragStart,
                        onDragUpdate: _onDragUpdate,
                        onDragEnd: _onDragEnd,
                        onTapVisitor: _onTapVisitor,
                        particleKey: _particleKey,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 72,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: GameFeedbackOverlay(
                      message: ref.watch(
                        hungryTeddyControllerProvider.select((s) => s.feedbackMessage),
                      ),
                      rewardText: ref.watch(
                        hungryTeddyControllerProvider.select((s) => s.lastRewardText),
                      ),
                      showMascot: ref.watch(
                        hungryTeddyControllerProvider.select((s) => s.showMascot),
                      ),
                    ),
                  ),
                ),
                if (showGolden)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: AppColors.sunYellow.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                if (sessionPhase == HungryTeddySessionPhase.finished)
                  TeddyVictoryOverlay(
                    result: ref.read(hungryTeddyControllerProvider.notifier).getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref.read(hungryTeddyControllerProvider.notifier).reset();
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
    super.key,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onTapVisitor,
    required this.particleKey,
  });

  final void Function(String id, DragStartDetails details) onDragStart;
  final void Function(String id, DragUpdateDetails details) onDragUpdate;
  final void Function(String id, DragEndDetails details) onDragEnd;
  final void Function(String id) onTapVisitor;
  final GlobalKey<ParticleSystemState> particleKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cupcakes = ref.watch(hungryTeddyControllerProvider.select((s) => s.cupcakes));
    final teddy = ref.watch(hungryTeddyControllerProvider.select((s) => s.teddy));
    final visitors = ref.watch(hungryTeddyControllerProvider.select((s) => s.visitors));
    final evening = ref.watch(hungryTeddyControllerProvider.select((s) => s.eveningFactor));
    final settings = ref.watch(hungryTeddySettingsProvider);
    final showSparkles = ref.watch(hungryTeddyControllerProvider.select((s) => s.showSparkles));
    final draggingId = ref.watch(hungryTeddyControllerProvider.select((s) => s.draggingCupcakeId));
    final cupcakesFed = ref.watch(hungryTeddyControllerProvider.select((s) => s.cupcakesFed));
    final inactivity = ref.watch(hungryTeddyControllerProvider.select((s) => s.inactivityTimer));

    return LayoutBuilder(
      builder: (context, constraints) {
        final area = Size(constraints.maxWidth, constraints.maxHeight);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(hungryTeddyControllerProvider.notifier).setPlayArea(area);
        });

        final (mouthX, mouthY) = HungryTeddyLogic.teddyMouth(area);
        final isDragging = draggingId != null;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            CupcakeTableWidget(eveningFactor: evening),
            if (isDragging)
              Positioned(
                left: mouthX - 70,
                top: mouthY - 70,
                child: IgnorePointer(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFF80AB).withValues(alpha: 0.75),
                        width: 3,
                      ),
                      color: const Color(0xFFFFE082).withValues(alpha: 0.18),
                    ),
                    child: const Center(
                      child: Text('🧸', style: TextStyle(fontSize: 36)),
                    ),
                  ),
                ),
              ),
            ...visitors.map(
              (v) => PartyVisitorWidget(
                visitor: v,
                onTap: () => onTapVisitor(v.id),
              ),
            ),
            TeddyWidget(
              teddy: teddy,
              largerTouch: settings.largerTouchTargets,
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: ParticleSystem(
                  key: particleKey,
                  particleCount: 24,
                  autoStart: false,
                ),
              ),
            ),
            if (cupcakesFed == 0 && inactivity < 6 && draggingId == null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('👆', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Text(
                          'Drag a cupcake to Teddy!',
                          style: TextStyle(
                            fontSize: settings.largerTouchTargets ? 18 : 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6A1B9A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('🧁', style: TextStyle(fontSize: 22)),
                      ],
                    ),
                  ),
                ),
              ),
            ...cupcakes.map(
              (c) => CupcakeWidget(
                cupcake: c,
                largerTouch: settings.largerTouchTargets,
                onDragStart: (d) => onDragStart(c.id, d),
                onDragUpdate: (d) => onDragUpdate(c.id, d),
                onDragEnd: (d) => onDragEnd(c.id, d),
              ),
            ),
            if (showSparkles)
              Positioned(
                left: teddy.x - 40,
                top: teddy.y - 60,
                child: const IgnorePointer(
                  child: Text('✨', style: TextStyle(fontSize: 32)),
                ),
              ),
          ],
        );
      },
    );
  }
}
