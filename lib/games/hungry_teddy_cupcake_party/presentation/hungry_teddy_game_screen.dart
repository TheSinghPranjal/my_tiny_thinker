import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/widgets/game_session_hud.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_feedback_banner.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/core/widgets/game_paused_overlay.dart';
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

  Future<void> _start() async {
    if (!await ensureCanStartGame(
      context,
      ref,
      GameId.hungryTeddyCupcakeParty,
    )) {
      return;
    }
    if (!mounted) return;
    _saved = false;
    final settings = ref.read(hungryTeddySettingsProvider);
    ref.read(hungryTeddyControllerProvider.notifier).reset();
    ref.read(hungryTeddyControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playGameMusic();
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
    _audio?.playHomeMusic();
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
      onSettings: () async {
        ref.read(hungryTeddyControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
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
                    GameSessionHud(
                      remainingSeconds: ref.watch(
                        hungryTeddyControllerProvider.select((s) => s.remainingSeconds),
                      ),
                      coinsEarned: ref.watch(
                        hungryTeddyControllerProvider.select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        hungryTeddyControllerProvider.select((s) => s.starsEarned),
                      ),
                      largerFonts: settings.largerTouchTargets,
                      onPause: _showPauseMenu,
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
                if (sessionPhase == HungryTeddySessionPhase.paused)
                  GamePausedOverlay(
                    onResume: () =>
                        ref.read(hungryTeddyControllerProvider.notifier).resume(),
                    onOpenMenu: _showPauseMenu,
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
    final settings = ref.watch(hungryTeddySettingsProvider);
    final showSparkles = ref.watch(hungryTeddyControllerProvider.select((s) => s.showSparkles));
    final draggingId = ref.watch(hungryTeddyControllerProvider.select((s) => s.draggingCupcakeId));
    final elapsedSeconds = ref.watch(
      hungryTeddyControllerProvider.select((s) => s.elapsedSeconds),
    );
    final showDragHint = elapsedSeconds < 5;

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
            ...visitors.map(
              (v) => PartyVisitorWidget(
                visitor: v,
                onTap: () => onTapVisitor(v.id),
              ),
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
            TeddyWidget(
              teddy: teddy,
              largerTouch: settings.largerTouchTargets,
            ),
            if (isDragging)
              Positioned(
                left: mouthX - 78,
                top: mouthY - 78,
                child: IgnorePointer(
                  child: _FeedZoneGlow(),
                ),
              ),
            if (showDragHint &&
                draggingId == null &&
                teddy.phase == TeddyPhase.idle &&
                cupcakes.any((c) => c.canDrag))
              Positioned(
                left: 12,
                right: 12,
                top: area.height * 0.40,
                child: IgnorePointer(
                  child: _DragHint(larger: settings.largerTouchTargets),
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

class _FeedZoneGlow extends StatefulWidget {
  @override
  State<_FeedZoneGlow> createState() => _FeedZoneGlowState();
}

class _FeedZoneGlowState extends State<_FeedZoneGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        return Container(
          width: 156,
          height: 156,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Color.lerp(
                const Color(0xFFFF80AB),
                const Color(0xFFFFEB3B),
                t,
              )!.withValues(alpha: 0.85),
              width: 4,
            ),
            gradient: RadialGradient(
              colors: [
                const Color(0xFFFFE082).withValues(alpha: 0.35 + t * 0.15),
                const Color(0xFFFF80AB).withValues(alpha: 0.12),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF80AB).withValues(alpha: 0.35 + t * 0.2),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Text('😋', style: TextStyle(fontSize: 40)),
          ),
        );
      },
    );
  }
}

class _DragHint extends StatefulWidget {
  const _DragHint({required this.larger});

  final bool larger;

  @override
  State<_DragHint> createState() => _DragHintState();
}

class _DragHintState extends State<_DragHint> with SingleTickerProviderStateMixin {
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
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;
        return Transform.scale(
          scale: 0.98 + t * 0.06,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF80AB), Color(0xFFEA80FC), Color(0xFF82B1FF)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEC407A).withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('👆', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Drag a cupcake to Teddy!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: widget.larger ? 20 : 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('🧁🧸', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
