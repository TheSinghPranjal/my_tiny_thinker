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
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/controllers/hungry_monkey_controller.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/models/hungry_monkey_models.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/presentation/widgets/apple_widget.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/presentation/widgets/banana_tree_widget.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/presentation/widgets/banana_widget.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/presentation/widgets/jungle_background.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/presentation/widgets/monkey_hud.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/presentation/widgets/monkey_widget.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/repository/hungry_monkey_settings_repository.dart';

class HungryMonkeyGameScreen extends ConsumerStatefulWidget {
  const HungryMonkeyGameScreen({super.key});

  @override
  ConsumerState<HungryMonkeyGameScreen> createState() =>
      _HungryMonkeyGameScreenState();
}

class _HungryMonkeyGameScreenState extends ConsumerState<HungryMonkeyGameScreen>
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

    ref.listenManual(hungryMonkeyControllerProvider, (prev, next) {
      _syncTicker(next.sessionPhase);
      if (next.sessionPhase == HungryMonkeySessionPhase.finished && !_saved) {
        _onFinished();
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(hungryMonkeySettingsProvider);
    ref.read(hungryMonkeyControllerProvider.notifier).reset();
    ref.read(hungryMonkeyControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playGameMusic();
    }
    _syncTicker(HungryMonkeySessionPhase.playing);
  }

  void _syncTicker(HungryMonkeySessionPhase phase) {
    if (phase == HungryMonkeySessionPhase.playing) {
      _ticker ??= createTicker((_) {
        ref.read(hungryMonkeyControllerProvider.notifier).tick(1 / 60);
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
    await ref.read(hungryMonkeyControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(hungryMonkeyControllerProvider.notifier).pause();
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
    ref.read(hungryMonkeyControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () => ref.read(hungryMonkeyControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(hungryMonkeyControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(hungryMonkeyControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onTapBanana(String id) {
    final settings = ref.read(hungryMonkeySettingsProvider);
    final ok = ref.read(hungryMonkeyControllerProvider.notifier).tapBanana(id);
    if (!ok) return;

    if (settings.hapticsEnabled) {
      ref.read(hapticServiceProvider).trigger(HapticType.light);
    }
    if (settings.soundEnabled) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
      ref.read(audioServiceProvider).playSfx(SoundEffect.reward);
      ref.read(audioServiceProvider).playSfx(SoundEffect.coin);
    }
    if (ref.read(hungryMonkeyControllerProvider).showSparkles) {
      _particleKey.currentState?.emit();
    }
  }

  void _onTapApple(String id) {
    final settings = ref.read(hungryMonkeySettingsProvider);
    final ok = ref.read(hungryMonkeyControllerProvider.notifier).tapApple(id);
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
      hungryMonkeyControllerProvider.select((s) => s.sessionPhase),
    );
    final settings = ref.watch(hungryMonkeySettingsProvider);
    final envPhase = ref.watch(
      hungryMonkeyControllerProvider.select((s) => s.envPhase),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && sessionPhase != HungryMonkeySessionPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: JungleBackground(
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
                        hungryMonkeyControllerProvider.select((s) => s.remainingSeconds),
                      ),
                      coinsEarned: ref.watch(
                        hungryMonkeyControllerProvider.select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        hungryMonkeyControllerProvider.select((s) => s.starsEarned),
                      ),
                      largerFonts: settings.largerTouchTargets,
                      onPause: _showPauseMenu,
                    ),
                    Expanded(
                      child: _JunglePlayArea(
                        particleKey: _particleKey,
                        onTapBanana: _onTapBanana,
                        onTapApple: _onTapApple,
                        largerTouch: settings.largerTouchTargets,
                        reducedMotion: settings.reducedMotion,
                      ),
                    ),
                  ],
                ),
                GameFeedbackOverlay(
                  message: ref.watch(
                    hungryMonkeyControllerProvider.select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    hungryMonkeyControllerProvider.select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    hungryMonkeyControllerProvider.select((s) => s.showMascot),
                  ),
                ),
                if (sessionPhase == HungryMonkeySessionPhase.paused)
                  GamePausedOverlay(
                    onResume: () => ref.read(hungryMonkeyControllerProvider.notifier).resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (sessionPhase == HungryMonkeySessionPhase.finished)
                  MonkeyVictoryOverlay(
                    result:
                        ref.read(hungryMonkeyControllerProvider.notifier).getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref.read(hungryMonkeyControllerProvider.notifier).reset();
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


class _JunglePlayArea extends ConsumerWidget {
  const _JunglePlayArea({
    required this.particleKey,
    required this.onTapBanana,
    required this.onTapApple,
    required this.largerTouch,
    required this.reducedMotion,
  });

  final GlobalKey<ParticleSystemState> particleKey;
  final void Function(String id) onTapBanana;
  final void Function(String id) onTapApple;
  final bool largerTouch;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bananas = ref.watch(hungryMonkeyControllerProvider.select((s) => s.bananas));
    final apples = ref.watch(hungryMonkeyControllerProvider.select((s) => s.apples));
    final monkey = ref.watch(hungryMonkeyControllerProvider.select((s) => s.monkey));
    final envPhase = ref.watch(hungryMonkeyControllerProvider.select((s) => s.envPhase));
    final showSparkles = ref.watch(
      hungryMonkeyControllerProvider.select((s) => s.showSparkles),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(hungryMonkeyControllerProvider.notifier).setPlayArea(
                Size(constraints.maxWidth, constraints.maxHeight),
              );
        });

        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return ClipRect(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: w * 0.02,
                // Sit the tree lower so the canopy crown isn't clipped by the HUD.
                top: h * 0.10,
                child: BananaTreeWidget(
                  width: w * 0.96,
                  height: h * 0.78,
                  envPhase: envPhase,
                  reducedMotion: reducedMotion,
                ),
              ),
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
              ...bananas.where((b) => b.phase == BananaPhase.onTree || b.phase == BananaPhase.growing).map(
                    (banana) => Positioned(
                      left: banana.x - (largerTouch ? 48 : 42),
                      top: banana.y - (largerTouch ? 48 : 42),
                      child: BananaWidget(
                        banana: banana,
                        largerTouch: largerTouch,
                        onTap: () => onTapBanana(banana.id),
                      ),
                    ),
                  ),
              ...bananas.where((b) => b.phase == BananaPhase.tapped || b.phase == BananaPhase.falling).map(
                    (banana) => Positioned(
                      left: banana.x - 28 * banana.sizeScale,
                      top: banana.y - 34 * banana.sizeScale,
                      child: FallingBananaWidget(banana: banana),
                    ),
                  ),
              ...apples.map(
                (apple) => Positioned(
                  left: apple.x - (largerTouch ? 34 : 30),
                  top: apple.y - (largerTouch ? 34 : 30),
                  child: AppleWidget(
                    apple: apple,
                    largerTouch: largerTouch,
                    onTap: () => onTapApple(apple.id),
                  ),
                ),
              ),
              Positioned(
                left: monkey.x - (largerTouch ? 80 : 70),
                top: monkey.y - (largerTouch ? 90 : 80),
                child: MonkeyWidget(monkey: monkey, largerTouch: largerTouch),
              ),
            ],
          ),
        );
      },
    );
  }
}
