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
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/controllers/hungry_duck_controller.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/models/hungry_duck_models.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/presentation/widgets/duck_pond_background.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/presentation/widgets/duck_pond_hud.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/presentation/widgets/duck_widget.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/presentation/widgets/pond_fish_widget.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/presentation/widgets/pond_visitor_widget.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/presentation/widgets/pond_water_clipper.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/repository/hungry_duck_settings_repository.dart';

class HungryDuckGameScreen extends ConsumerStatefulWidget {
  const HungryDuckGameScreen({super.key});

  @override
  ConsumerState<HungryDuckGameScreen> createState() => _HungryDuckGameScreenState();
}

class _HungryDuckGameScreenState extends ConsumerState<HungryDuckGameScreen>
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
    ref.listenManual(hungryDuckControllerProvider, (prev, next) {
      _syncTicker(next.sessionPhase);
      if (next.sessionPhase == HungryDuckSessionPhase.finished && !_saved) _onFinished();
      if (next.showSparkles) _particleKey.currentState?.emit();
      if (prev != null &&
          next.fishCaught > prev.fishCaught &&
          ref.read(hungryDuckSettingsProvider).soundEnabled) {
        ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
        ref.read(audioServiceProvider).playSfx(SoundEffect.reward);
        ref.read(audioServiceProvider).playSfx(SoundEffect.coin);
        if (next.goldenCaught > prev.goldenCaught) {
          ref.read(audioServiceProvider).playSfx(SoundEffect.levelComplete);
        }
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(hungryDuckSettingsProvider);
    ref.read(hungryDuckControllerProvider.notifier).reset();
    ref.read(hungryDuckControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playMusic(asset: 'audio/ambient_music.mp3');
    }
    _syncTicker(HungryDuckSessionPhase.playing);
  }

  void _syncTicker(HungryDuckSessionPhase phase) {
    if (phase == HungryDuckSessionPhase.playing) {
      _ticker ??= createTicker((_) {
        ref.read(hungryDuckControllerProvider.notifier).tick(1 / 60);
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
    await ref.read(hungryDuckControllerProvider.notifier).saveResult();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.dispose();
    _audio?.stopMusic();
    super.dispose();
  }

  Future<void> _showPauseMenu() async {
    ref.read(hungryDuckControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () => ref.read(hungryDuckControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(hungryDuckControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () {
        ref.read(hungryDuckControllerProvider.notifier).pause();
        context.push(AppRoutes.parentZone);
      },
    );
  }

  void _onTapFish(String id) {
    final settings = ref.read(hungryDuckSettingsProvider);
    final ok = ref.read(hungryDuckControllerProvider.notifier).tapFish(id);
    if (!ok) return;
    if (settings.hapticsEnabled) ref.read(hapticServiceProvider).trigger(HapticType.light);
    if (settings.soundEnabled) ref.read(audioServiceProvider).playSfx(SoundEffect.buttonTap);
  }

  void _onTapVisitor(String id) {
    final settings = ref.read(hungryDuckSettingsProvider);
    final ok = ref.read(hungryDuckControllerProvider.notifier).tapVisitor(id);
    if (!ok) return;
    if (settings.hapticsEnabled) ref.read(hapticServiceProvider).trigger(HapticType.selection);
    if (settings.soundEnabled) ref.read(audioServiceProvider).playSfx(SoundEffect.buttonTap);
  }

  @override
  Widget build(BuildContext context) {
    final sessionPhase = ref.watch(hungryDuckControllerProvider.select((s) => s.sessionPhase));
    final settings = ref.watch(hungryDuckSettingsProvider);
    final sunset = ref.watch(hungryDuckControllerProvider.select((s) => s.sunsetFactor));
    final envPhase = ref.watch(hungryDuckControllerProvider.select((s) => s.envPhase));
    final showGolden = ref.watch(hungryDuckControllerProvider.select((s) => s.showGoldenCelebration));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && sessionPhase != HungryDuckSessionPhase.finished) await _showPauseMenu();
      },
      child: DuckPondBackground(
        sunsetFactor: sunset,
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
                    DuckPondHud(
                      remainingSeconds: ref.watch(
                          hungryDuckControllerProvider.select((s) => s.remainingSeconds)),
                      fishCaught: ref.watch(
                          hungryDuckControllerProvider.select((s) => s.fishCaught)),
                      coinsEarned: ref.watch(
                          hungryDuckControllerProvider.select((s) => s.coinsEarned)),
                      largerFonts: settings.largerTouchTargets,
                      onPause: _showPauseMenu,
                    ),
                    Expanded(
                      child: _PondPlayArea(
                        particleKey: _particleKey,
                        onTapFish: _onTapFish,
                        onTapVisitor: _onTapVisitor,
                        largerTouch: settings.largerTouchTargets,
                      ),
                    ),
                  ],
                ),
                GameFeedbackOverlay(
                  message: ref.watch(hungryDuckControllerProvider.select((s) => s.feedbackMessage)),
                  rewardText: ref.watch(hungryDuckControllerProvider.select((s) => s.lastRewardText)),
                  showMascot: ref.watch(hungryDuckControllerProvider.select((s) => s.showMascot)),
                ),
                if (showGolden)
                  IgnorePointer(
                    child: Container(
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.12),
                      child: const Center(child: Text('✨🐟✨', style: TextStyle(fontSize: 72))),
                    ),
                  ),
                if (sessionPhase == HungryDuckSessionPhase.paused) const _PausedOverlay(),
                if (sessionPhase == HungryDuckSessionPhase.finished)
                  DuckPondVictoryOverlay(
                    result: ref.read(hungryDuckControllerProvider.notifier).getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref.read(hungryDuckControllerProvider.notifier).reset();
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
          child: Text('Paused',
              style: TextStyle(color: AppColors.white, fontSize: 36, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

class _PondPlayArea extends ConsumerWidget {
  const _PondPlayArea({
    required this.particleKey,
    required this.onTapFish,
    required this.onTapVisitor,
    required this.largerTouch,
  });

  final GlobalKey<ParticleSystemState> particleKey;
  final void Function(String id) onTapFish;
  final void Function(String id) onTapVisitor;
  final bool largerTouch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fish = ref.watch(hungryDuckControllerProvider.select((s) => s.fish));
    final duck = ref.watch(hungryDuckControllerProvider.select((s) => s.duck));
    final visitors = ref.watch(hungryDuckControllerProvider.select((s) => s.visitors));

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(hungryDuckControllerProvider.notifier).setPlayArea(
                Size(constraints.maxWidth, constraints.maxHeight),
              );
        });
        return ClipRect(
          clipper: PondWaterClipper(
            playAreaSize: Size(constraints.maxWidth, constraints.maxHeight),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: ParticleSystem(key: particleKey, particleCount: 20, autoStart: false),
                ),
              ),
              ...fish.map(
                (f) => Positioned(
                  left: f.x - (largerTouch ? 38 : 34),
                  top: f.y - (largerTouch ? 26 : 22),
                  child: RepaintBoundary(
                    child: PondFishWidget(
                      fish: f,
                      largerTouch: largerTouch,
                      onTap: () => onTapFish(f.id),
                    ),
                  ),
                ),
              ),
              ...visitors.map(
                (v) => Positioned(
                  left: v.x - (largerTouch ? 28 : 24),
                  top: v.y - (largerTouch ? 28 : 24),
                  child: RepaintBoundary(
                    child: PondVisitorWidget(
                      visitor: v,
                      largerTouch: largerTouch,
                      onTap: () => onTapVisitor(v.id),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: duck.x - DuckWidget.layoutSize(largerTouch) / 2,
                top: duck.y - DuckWidget.layoutSize(largerTouch) / 2,
                child: RepaintBoundary(
                  child: DuckWidget(duck: duck, largerTouch: largerTouch),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
