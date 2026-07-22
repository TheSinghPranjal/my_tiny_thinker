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
import 'package:my_tiny_thinker/core/widgets/game_feedback_banner.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/core/widgets/game_paused_overlay.dart';
import 'package:my_tiny_thinker/games/color_school_bags/controllers/color_school_bags_controller.dart';
import 'package:my_tiny_thinker/games/color_school_bags/models/color_school_bags_models.dart';
import 'package:my_tiny_thinker/games/color_school_bags/presentation/widgets/playground_background.dart';
import 'package:my_tiny_thinker/games/color_school_bags/presentation/widgets/sort_bags_board.dart';
import 'package:my_tiny_thinker/games/color_school_bags/presentation/widgets/sort_bags_hud.dart';
import 'package:my_tiny_thinker/games/color_school_bags/repository/color_school_bags_settings_repository.dart';

class ColorSchoolBagsGameScreen extends ConsumerStatefulWidget {
  const ColorSchoolBagsGameScreen({super.key});

  @override
  ConsumerState<ColorSchoolBagsGameScreen> createState() =>
      _ColorSchoolBagsGameScreenState();
}

class _ColorSchoolBagsGameScreenState
    extends ConsumerState<ColorSchoolBagsGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _particleKey = GlobalKey<ParticleSystemState>();
  Ticker? _ticker;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(colorSchoolBagsControllerProvider, (prev, next) {
      if (next.phase == SortBagsPhase.finished && !_saved) {
        _onFinished();
      }
      if (next.showSparkles && next.phase == SortBagsPhase.celebrating) {
        _particleKey.currentState?.emit();
      }
    });
  }

  Future<void> _start() async {
    if (!await ensureCanStartGame(
      context,
      ref,
      GameId.colorSchoolBags,
    )) {
      return;
    }
    if (!mounted) return;
    _saved = false;
    final settings = ref.read(colorSchoolBagsSettingsProvider);
    ref.read(colorSchoolBagsControllerProvider.notifier).reset();
    ref.read(colorSchoolBagsControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playGameMusic();
    }
    _ticker ??= createTicker((_) {
      ref.read(colorSchoolBagsControllerProvider.notifier).tick(1 / 60);
    });
    if (!_ticker!.isActive) _ticker!.start();
  }

  Future<void> _onFinished() async {
    _saved = true;
    _ticker?.stop();
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    await ref.read(colorSchoolBagsControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(colorSchoolBagsControllerProvider.notifier).pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.dispose();
    ref.read(audioServiceProvider).playHomeMusic();
    super.dispose();
  }

  Future<void> _showPauseMenu() async {
    ref.read(colorSchoolBagsControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () =>
          ref.read(colorSchoolBagsControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () async {
        final ctrl = ref.read(colorSchoolBagsControllerProvider.notifier);
        await ctrl.saveResult();
        ctrl.reset();
        if (!mounted) return;
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(colorSchoolBagsControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onDrop({required String bookId, required String bagId}) {
    final settings = ref.read(colorSchoolBagsSettingsProvider);
    final ok = ref.read(colorSchoolBagsControllerProvider.notifier).tryDrop(
          bookId: bookId,
          bagId: bagId,
        );

    if (settings.hapticsEnabled) {
      ref.read(hapticServiceProvider).trigger(
            ok ? HapticType.success : HapticType.light,
          );
    }
    if (settings.soundEnabled) {
      ref.read(audioServiceProvider).playSfx(
            ok ? SoundEffect.correct : SoundEffect.wrong,
          );
      if (ok) {
        ref.read(audioServiceProvider).playSfx(SoundEffect.reward);
        ref.read(audioServiceProvider).playSfx(SoundEffect.coin);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase =
        ref.watch(colorSchoolBagsControllerProvider.select((s) => s.phase));
    final settings = ref.watch(colorSchoolBagsSettingsProvider);
    final envPhase =
        ref.watch(colorSchoolBagsControllerProvider.select((s) => s.envPhase));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && phase != SortBagsPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: PlaygroundBackground(
        envPhase: envPhase,
        reducedMotion: settings.reducedMotion,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    GameSessionHud(
                      remainingSeconds: ref.watch(
                        colorSchoolBagsControllerProvider.select((s) => s.remainingSeconds),
                      ),
                      unlimitedTime: settings.unlimitedTime,
                      coinsEarned: ref.watch(
                        colorSchoolBagsControllerProvider.select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        colorSchoolBagsControllerProvider.select((s) => s.starsEarned),
                      ),
                      largerFonts: settings.largerTouchTargets,
                      onPause: _showPauseMenu,
                    ),
                    Expanded(
                      child: SortBagsBoard(
                        books: ref.watch(
                          colorSchoolBagsControllerProvider
                              .select((s) => s.books),
                        ),
                        backpacks: ref.watch(
                          colorSchoolBagsControllerProvider
                              .select((s) => s.backpacks),
                        ),
                        hoverBagId: ref.watch(
                          colorSchoolBagsControllerProvider
                              .select((s) => s.hoverBagId),
                        ),
                        largerTouch: settings.largerTouchTargets,
                        onDrop: _onDrop,
                        onHoverBag: (id) => ref
                            .read(colorSchoolBagsControllerProvider.notifier)
                            .setHoverBag(id),
                      ),
                    ),
                  ],
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: ParticleSystem(
                      key: _particleKey,
                      particleCount: 40,
                      autoStart: false,
                    ),
                  ),
                ),
                GameFeedbackOverlay(
                  message: ref.watch(
                    colorSchoolBagsControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    colorSchoolBagsControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    colorSchoolBagsControllerProvider
                        .select((s) => s.showMascot),
                  ),
                  rewardShadowColor: const Color(0xFF42A5F5),
                ),
                if (phase == SortBagsPhase.paused) GamePausedOverlay(
                    onResume: () => ref.read(colorSchoolBagsControllerProvider.notifier).resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (phase == SortBagsPhase.finished)
                  SortBagsVictoryOverlay(
                    result: ref
                        .read(colorSchoolBagsControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref
                          .read(colorSchoolBagsControllerProvider.notifier)
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

