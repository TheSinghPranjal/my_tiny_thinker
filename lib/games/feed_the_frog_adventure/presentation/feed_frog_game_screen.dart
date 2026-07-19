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
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/controllers/feed_frog_controller.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/models/feed_frog_models.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/presentation/widgets/feed_frog_hero.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/presentation/widgets/feed_frog_hud.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/presentation/widgets/feed_pond_background.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/presentation/widgets/insect_widget.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/repository/feed_frog_settings_repository.dart';

class FeedFrogGameScreen extends ConsumerStatefulWidget {
  const FeedFrogGameScreen({super.key});

  @override
  ConsumerState<FeedFrogGameScreen> createState() => _FeedFrogGameScreenState();
}

class _FeedFrogGameScreenState extends ConsumerState<FeedFrogGameScreen>
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

    ref.listenManual(feedFrogControllerProvider, (prev, next) {
      _syncTicker(next.sessionPhase);
      if (next.sessionPhase == FeedFrogSessionPhase.finished && !_saved) {
        _onFinished();
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(feedFrogSettingsProvider);
    ref.read(feedFrogControllerProvider.notifier).reset();
    ref.read(feedFrogControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      _audio?.playMusic(asset: 'audio/ambient_music.mp3');
    }
    _syncTicker(FeedFrogSessionPhase.playing);
  }

  void _syncTicker(FeedFrogSessionPhase phase) {
    if (phase == FeedFrogSessionPhase.playing) {
      _ticker ??= createTicker((_) {
        ref.read(feedFrogControllerProvider.notifier).tick(1 / 60);
      });
      if (!_ticker!.isActive) _ticker!.start();
    } else {
      _ticker?.stop();
    }
  }

  Future<void> _onFinished() async {
    _saved = true;
    _ticker?.stop();
    _audio?.playSfx(SoundEffect.victory);
    await ref.read(feedFrogControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(feedFrogControllerProvider.notifier).pause();
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
    ref.read(feedFrogControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () => ref.read(feedFrogControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(feedFrogControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(feedFrogControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onTapInsect(String id) {
    final settings = ref.read(feedFrogSettingsProvider);
    final ok = ref.read(feedFrogControllerProvider.notifier).tapInsect(id);
    if (!ok) return;
    if (settings.hapticsEnabled) {
      ref.read(hapticServiceProvider).trigger(HapticType.light);
    }
    if (settings.soundEnabled) {
      _audio?.playSfx(SoundEffect.buttonTap);
      _audio?.playSfx(SoundEffect.correct);
      _audio?.playSfx(SoundEffect.reward);
      _audio?.playSfx(SoundEffect.coin);
    }
    _particleKey.currentState?.emit();
  }

  @override
  Widget build(BuildContext context) {
    final sessionPhase = ref.watch(
      feedFrogControllerProvider.select((s) => s.sessionPhase),
    );
    final settings = ref.watch(feedFrogSettingsProvider);
    final nightFactor = ref.watch(
      feedFrogControllerProvider.select((s) => s.nightFactor),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && sessionPhase != FeedFrogSessionPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: FeedPondBackground(
        nightFactor: nightFactor,
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
                        feedFrogControllerProvider.select((s) => s.remainingSeconds),
                      ),
                      coinsEarned: ref.watch(
                        feedFrogControllerProvider.select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        feedFrogControllerProvider.select((s) => s.starsEarned),
                      ),
                      largerFonts: settings.largerTouchTargets,
                      onPause: _showPauseMenu,
                    ),
                    Expanded(
                      child: _PlayArea(
                        particleKey: _particleKey,
                        onTapInsect: _onTapInsect,
                        highContrast: settings.highContrast,
                        largerTouch: settings.largerTouchTargets,
                      ),
                    ),
                  ],
                ),
                GameFeedbackOverlay(
                  message: ref.watch(
                    feedFrogControllerProvider.select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    feedFrogControllerProvider.select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    feedFrogControllerProvider.select((s) => s.showMascot),
                  ),
                ),
                if (sessionPhase == FeedFrogSessionPhase.paused)
                  GamePausedOverlay(
                    onResume: () => ref.read(feedFrogControllerProvider.notifier).resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (sessionPhase == FeedFrogSessionPhase.finished)
                  FeedFrogVictoryOverlay(
                    result: ref.read(feedFrogControllerProvider.notifier).getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref.read(feedFrogControllerProvider.notifier).reset();
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
    required this.particleKey,
    required this.onTapInsect,
    required this.highContrast,
    required this.largerTouch,
  });

  final GlobalKey<ParticleSystemState> particleKey;
  final void Function(String id) onTapInsect;
  final bool highContrast;
  final bool largerTouch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insects = ref.watch(feedFrogControllerProvider.select((s) => s.insects));
    final frogX = ref.watch(feedFrogControllerProvider.select((s) => s.frogX));
    final frogY = ref.watch(feedFrogControllerProvider.select((s) => s.frogY));
    final frogPhase = ref.watch(feedFrogControllerProvider.select((s) => s.frogPhase));
    final animPhase = ref.watch(feedFrogControllerProvider.select((s) => s.frogAnimPhase));
    final blink = ref.watch(feedFrogControllerProvider.select((s) => s.frogBlinkTimer));
    final tongueProgress = ref.watch(
      feedFrogControllerProvider.select((s) => s.tongueProgress),
    );
    final tipX = ref.watch(feedFrogControllerProvider.select((s) => s.tongueTipX));
    final tipY = ref.watch(feedFrogControllerProvider.select((s) => s.tongueTipY));
    final nightFactor = ref.watch(feedFrogControllerProvider.select((s) => s.nightFactor));
    final showSparkles = ref.watch(
      feedFrogControllerProvider.select((s) => s.showSparkles),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(feedFrogControllerProvider.notifier).setPlayArea(
                Size(constraints.maxWidth, constraints.maxHeight),
              );
        });

        final feeding = frogPhase == FrogFeedPhase.tongueExtend ||
            frogPhase == FrogFeedPhase.tongueRetract;

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
              ...insects.map(
                (insect) {
                  final half = InsectWidget.layoutSize(
                        largerTouch,
                        isFirefly: insect.isFirefly,
                      ) /
                      2;
                  return Positioned(
                    left: insect.x - half - 10,
                    top: insect.y - half - 10,
                    child: InsectWidget(
                      insect: insect,
                      nightFactor: nightFactor,
                      largerTouch: largerTouch,
                      onTap: () => onTapInsect(insect.id),
                    ),
                  );
                },
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: FrogTonguePainter(
                      frogX: frogX,
                      frogY: frogY,
                      tipX: tipX,
                      tipY: tipY,
                      progress: tongueProgress,
                      visible: feeding,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: FeedFrogHero(
                    frogX: frogX,
                    frogY: frogY,
                    animPhase: animPhase,
                    blinkTimer: blink,
                    phase: frogPhase,
                    highContrast: highContrast,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
