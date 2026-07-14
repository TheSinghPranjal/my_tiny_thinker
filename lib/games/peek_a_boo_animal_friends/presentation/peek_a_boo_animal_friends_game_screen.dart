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
import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/controllers/peek_a_boo_animal_friends_controller.dart';
import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/models/peek_a_boo_animal_friends_models.dart';
import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/presentation/widgets/animal_widget.dart';
import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/presentation/widgets/bush_widget.dart';
import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/presentation/widgets/peek_a_boo_background.dart';
import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/presentation/widgets/peek_a_boo_hud.dart';
import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/repository/peek_a_boo_animal_friends_settings_repository.dart';

class PeekABooGameScreen extends ConsumerStatefulWidget {
  const PeekABooGameScreen({super.key});

  @override
  ConsumerState<PeekABooGameScreen> createState() => _PeekABooGameScreenState();
}

class _PeekABooGameScreenState extends ConsumerState<PeekABooGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Ticker? _ticker;
  final _particleKey = GlobalKey<ParticleSystemState>();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(peekABooControllerProvider, (prev, next) {
      _syncTicker(next.sessionPhase);
      if (next.sessionPhase == PeekABooSessionPhase.finished && !_saved) {
        _onFinished();
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(peekABooSettingsProvider);
    ref.read(peekABooControllerProvider.notifier).reset();
    ref.read(peekABooControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playMusic(asset: 'audio/ambient_music.mp3');
    }
    _syncTicker(PeekABooSessionPhase.playing);
  }

  void _syncTicker(PeekABooSessionPhase phase) {
    if (phase == PeekABooSessionPhase.playing) {
      _ticker ??= createTicker((_) {
        ref.read(peekABooControllerProvider.notifier).tick(1 / 60);
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
    await ref.read(peekABooControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(peekABooControllerProvider.notifier).pause();
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
    ref.read(peekABooControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () => ref.read(peekABooControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(peekABooControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () {
        ref.read(peekABooControllerProvider.notifier).pause();
        context.push(AppRoutes.parentZone);
      },
    );
  }

  void _onTapBush(String bushId) {
    final settings = ref.read(peekABooSettingsProvider);
    final ok = ref.read(peekABooControllerProvider.notifier).tapBush(bushId);
    if (!ok) return;

    final state = ref.read(peekABooControllerProvider);
    final hadAnimal = state.lastAnnouncement != null;

    if (settings.hapticsEnabled) {
      ref.read(hapticServiceProvider).trigger(HapticType.light);
    }
    if (settings.soundEnabled) {
      ref.read(audioServiceProvider).playSfx(
            hadAnimal ? SoundEffect.correct : SoundEffect.buttonTap,
          );
      if (hadAnimal) {
        ref.read(audioServiceProvider).playSfx(SoundEffect.reward);
        ref.read(audioServiceProvider).playSfx(SoundEffect.coin);
      }
    }
    if (hadAnimal) {
      _particleKey.currentState?.emit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionPhase = ref.watch(
      peekABooControllerProvider.select((s) => s.sessionPhase),
    );
    final settings = ref.watch(peekABooSettingsProvider);

    final announcement = ref.watch(
      peekABooControllerProvider.select((s) => s.lastAnnouncement),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && sessionPhase != PeekABooSessionPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: PeekABooBackground(
        reducedMotion: settings.reducedMotion,
        intensity: settings.animationIntensity,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    PeekABooHud(
                      remainingSeconds: ref.watch(
                        peekABooControllerProvider
                            .select((s) => s.remainingSeconds),
                      ),
                      discoveriesCount: ref.watch(
                        peekABooControllerProvider
                            .select((s) => s.discoveriesCount),
                      ),
                      coinsEarned: ref.watch(
                        peekABooControllerProvider.select((s) => s.coinsEarned),
                      ),
                      largerFonts: settings.largerFonts,
                      onPause: _showPauseMenu,
                    ),
                    Expanded(
                      child: _PlayArea(
                        particleKey: _particleKey,
                        onTapBush: _onTapBush,
                        highContrast: settings.highContrast,
                      ),
                    ),
                  ],
                ),
                GameFeedbackOverlay(
                  message: ref.watch(
                    peekABooControllerProvider.select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    peekABooControllerProvider.select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    peekABooControllerProvider.select((s) => s.showMascot),
                  ),
                ),
                if (announcement != null)
                  Positioned(
                    top: 96,
                    left: 24,
                    right: 24,
                    child: IgnorePointer(
                      child: AnnouncementBubble(text: announcement),
                    ),
                  ),
                if (sessionPhase == PeekABooSessionPhase.paused)
                  const _PausedOverlay(),
                if (sessionPhase == PeekABooSessionPhase.finished)
                  PeekABooVictoryOverlay(
                    result: ref.read(peekABooControllerProvider.notifier).getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref.read(peekABooControllerProvider.notifier).reset();
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
        color: const Color(0xFF1565C0).withValues(alpha: 0.55),
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
    required this.onTapBush,
    required this.highContrast,
  });

  final GlobalKey<ParticleSystemState> particleKey;
  final void Function(String bushId) onTapBush;
  final bool highContrast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bushes = ref.watch(peekABooControllerProvider.select((s) => s.bushes));
    final animals = ref.watch(peekABooControllerProvider.select((s) => s.animals));
    final showSparkles = ref.watch(
      peekABooControllerProvider.select((s) => s.showSparkles),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(peekABooControllerProvider.notifier).setPlayArea(
                Size(constraints.maxWidth, constraints.maxHeight),
              );
        });

        return ClipRect(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              if (showSparkles)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ParticleSystem(
                      key: particleKey,
                      particleCount: 28,
                      autoStart: false,
                    ),
                  ),
                ),
              ...bushes.map(
                (b) => Positioned(
                  left: b.centerX - b.width / 2,
                  top: b.centerY - b.height / 2,
                  child: BushWidget(
                    bush: b,
                    highContrast: highContrast,
                    onTap: () => onTapBush(b.id),
                  ),
                ),
              ),
              ...animals
                  .where((a) => a.phase != AnimalPhase.hidden && a.phase != AnimalPhase.gone)
                  .map(
                    (a) => Positioned(
                      left: a.x - 56,
                      top: a.y - 56,
                      child: AnimalWidget(animal: a),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}
