import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/widgets/game_feedback_banner.dart';
import 'package:my_tiny_thinker/core/widgets/game_paused_overlay.dart';
import 'package:my_tiny_thinker/core/widgets/game_session_hud.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/catch_the_fish/controllers/catch_the_fish_controller.dart';
import 'package:my_tiny_thinker/games/catch_the_fish/models/catch_the_fish_models.dart';
import 'package:my_tiny_thinker/games/catch_the_fish/presentation/widgets/catch_fish_widget.dart';
import 'package:my_tiny_thinker/games/catch_the_fish/presentation/widgets/catch_the_fish_hud.dart';
import 'package:my_tiny_thinker/games/catch_the_fish/presentation/widgets/fishing_boat_widget.dart';
import 'package:my_tiny_thinker/games/catch_the_fish/presentation/widgets/ocean_fishing_background.dart';
import 'package:my_tiny_thinker/games/catch_the_fish/repository/catch_the_fish_settings_repository.dart';

class CatchTheFishGameScreen extends ConsumerStatefulWidget {
  const CatchTheFishGameScreen({super.key});

  @override
  ConsumerState<CatchTheFishGameScreen> createState() =>
      _CatchTheFishGameScreenState();
}

class _CatchTheFishGameScreenState extends ConsumerState<CatchTheFishGameScreen>
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

    ref.listenManual(catchTheFishControllerProvider, (prev, next) {
      _syncTicker(next.sessionPhase);
      if (next.sessionPhase == CatchFishSessionPhase.finished && !_saved) {
        _onFinished();
      }
      if (next.showSparkles && _particleKey.currentState != null) {
        _particleKey.currentState?.emit();
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(catchTheFishSettingsProvider);
    ref.read(catchTheFishControllerProvider.notifier).reset();
    ref.read(catchTheFishControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playGameMusic();
    }
    _syncTicker(CatchFishSessionPhase.playing);
  }

  void _syncTicker(CatchFishSessionPhase phase) {
    if (phase == CatchFishSessionPhase.playing) {
      _ticker ??= createTicker((_) {
        ref.read(catchTheFishControllerProvider.notifier).tick(1 / 60);
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
    await ref.read(catchTheFishControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(catchTheFishControllerProvider.notifier).pause();
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
    ref.read(catchTheFishControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () =>
          ref.read(catchTheFishControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(catchTheFishControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(catchTheFishControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onTapFish(String id) {
    final settings = ref.read(catchTheFishSettingsProvider);
    final fish = ref
        .read(catchTheFishControllerProvider)
        .fish
        .where((f) => f.id == id)
        .firstOrNull;
    if (fish == null) return;

    final ok = ref.read(catchTheFishControllerProvider.notifier).tapFish(id);
    if (!ok) return;

    if (settings.hapticsEnabled) {
      ref.read(hapticServiceProvider).trigger(HapticType.light);
    }
    if (settings.soundEnabled) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
      ref.read(audioServiceProvider).playSfx(SoundEffect.reward);
      ref.read(audioServiceProvider).playSfx(SoundEffect.coin);
    }
    _particleKey.currentState?.emit(origin: Offset(fish.x, fish.y));
  }

  @override
  Widget build(BuildContext context) {
    final sessionPhase = ref.watch(
      catchTheFishControllerProvider.select((s) => s.sessionPhase),
    );
    final settings = ref.watch(catchTheFishSettingsProvider);
    final envPhase = ref.watch(
      catchTheFishControllerProvider.select((s) => s.envPhase),
    );
    final showCelebration = ref.watch(
      catchTheFishControllerProvider.select((s) => s.showCelebration),
    );
    final remainingSeconds = ref.watch(
      catchTheFishControllerProvider.select((s) => s.remainingSeconds),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && sessionPhase != CatchFishSessionPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: OceanFishingBackground(
        envPhase: envPhase,
        reducedMotion: settings.reducedMotion,
        showCelebration: showCelebration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    GameSessionHud(
                      remainingSeconds: remainingSeconds,
                      coinsEarned: ref.watch(
                        catchTheFishControllerProvider
                            .select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        catchTheFishControllerProvider
                            .select((s) => s.starsEarned),
                      ),
                      largerFonts: settings.largerTouchTargets,
                      accentColor: const Color(0xFF0288D1),
                      onPause: _showPauseMenu,
                    ),
                    Expanded(
                      child: _OceanPlayArea(
                        particleKey: _particleKey,
                        onTapFish: _onTapFish,
                        largerTouch: settings.largerTouchTargets,
                      ),
                    ),
                  ],
                ),
                GameFeedbackOverlay(
                  message: ref.watch(
                    catchTheFishControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    catchTheFishControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    catchTheFishControllerProvider
                        .select((s) => s.feedbackMessage != null),
                  ),
                ),
                if (showCelebration &&
                    sessionPhase == CatchFishSessionPhase.playing)
                  IgnorePointer(
                    child: Container(
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.12),
                      child: const Center(
                        child: Text('✨🎣✨', style: TextStyle(fontSize: 72)),
                      ),
                    ),
                  ),
                if (sessionPhase == CatchFishSessionPhase.paused)
                  GamePausedOverlay(
                    onResume: () => ref
                        .read(catchTheFishControllerProvider.notifier)
                        .resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (sessionPhase == CatchFishSessionPhase.finished)
                  CatchTheFishVictoryOverlay(
                    result: ref
                        .read(catchTheFishControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref
                          .read(catchTheFishControllerProvider.notifier)
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

class _OceanPlayArea extends ConsumerWidget {
  const _OceanPlayArea({
    required this.particleKey,
    required this.onTapFish,
    required this.largerTouch,
  });

  final GlobalKey<ParticleSystemState> particleKey;
  final void Function(String id) onTapFish;
  final bool largerTouch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fish =
        ref.watch(catchTheFishControllerProvider.select((s) => s.fish));
    final boatX =
        ref.watch(catchTheFishControllerProvider.select((s) => s.boatX));
    final boatY =
        ref.watch(catchTheFishControllerProvider.select((s) => s.boatY));
    final hookTargetFishId = ref.watch(
      catchTheFishControllerProvider.select((s) => s.hookTargetFishId),
    );

    final sortedFish = [...fish]
      ..sort((a, b) => a.y.compareTo(b.y));

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(catchTheFishControllerProvider.notifier).setPlayArea(
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
                    particleCount: 36,
                    autoStart: false,
                  ),
                ),
              ),
              FishingBoatWidget(
                boatX: boatX,
                boatY: boatY,
                hookTargetFishId: hookTargetFishId,
                fish: fish,
                largerTouch: largerTouch,
              ),
              ...sortedFish.map(
                (f) => CatchFishWidget(
                  fish: f,
                  largerTouch: largerTouch,
                  onTap: () => onTapFish(f.id),
                ),
              ),
              if (fish.any((f) => f.canTap))
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

class _TapHintState extends State<_TapHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
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
                  colors: [
                    Color(0xFF29B6F6),
                    Color(0xFF26C6DA),
                    Color(0xFF42A5F5),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0277BD).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Tap the fish! 🐠  Reel them in! 🎣',
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
