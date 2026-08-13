import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/widgets/game_feedback_banner.dart';
import 'package:my_tiny_thinker/core/widgets/game_paused_overlay.dart';
import 'package:my_tiny_thinker/core/widgets/game_session_hud.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/color_school_bags/presentation/widgets/playground_background.dart';
import 'package:my_tiny_thinker/games/learn_to_sort_food/controllers/learn_to_sort_food_controller.dart';
import 'package:my_tiny_thinker/games/learn_to_sort_food/models/learn_to_sort_food_models.dart';
import 'package:my_tiny_thinker/games/learn_to_sort_food/presentation/widgets/food_sort_board.dart';
import 'package:my_tiny_thinker/games/learn_to_sort_food/presentation/widgets/food_sort_hud.dart';
import 'package:my_tiny_thinker/games/learn_to_sort_food/repository/learn_to_sort_food_settings_repository.dart';

class LearnToSortFoodGameScreen extends ConsumerStatefulWidget {
  const LearnToSortFoodGameScreen({super.key});

  @override
  ConsumerState<LearnToSortFoodGameScreen> createState() =>
      _LearnToSortFoodGameScreenState();
}

class _LearnToSortFoodGameScreenState extends ConsumerState<LearnToSortFoodGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _particleKey = GlobalKey<ParticleSystemState>();
  Ticker? _ticker;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(learnToSortFoodControllerProvider, (prev, next) {
      if (next.phase == FoodSortPhase.finished && !_saved) {
        _onFinished();
      }
      if (next.showSparkles && next.phase == FoodSortPhase.celebrating) {
        _particleKey.currentState?.emit();
      }
      if (next.showMilestone && next.phase == FoodSortPhase.celebrating) {
        ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
      }
    });
  }

  Future<void> _start() async {
    if (!await ensureCanStartGame(context, ref, GameId.learnToSortFood)) {
      return;
    }
    if (!mounted) return;
    _saved = false;
    final settings = ref.read(learnToSortFoodSettingsProvider);
    ref.read(learnToSortFoodControllerProvider.notifier).reset();
    ref.read(learnToSortFoodControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playGameMusic();
    }
    _ticker ??= createTicker((_) {
      ref.read(learnToSortFoodControllerProvider.notifier).tick(1 / 60);
    });
    if (!_ticker!.isActive) _ticker!.start();
  }

  Future<void> _onFinished() async {
    _saved = true;
    _ticker?.stop();
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    await ref.read(learnToSortFoodControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(learnToSortFoodControllerProvider.notifier).pause();
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
    ref.read(learnToSortFoodControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () =>
          ref.read(learnToSortFoodControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () async {
        final ctrl = ref.read(learnToSortFoodControllerProvider.notifier);
        await ctrl.saveResult();
        ctrl.reset();
        if (!mounted) return;
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(learnToSortFoodControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onDrop({required String foodId, required String basketId}) {
    final settings = ref.read(learnToSortFoodSettingsProvider);
    final ok = ref.read(learnToSortFoodControllerProvider.notifier).tryDrop(
          foodId: foodId,
          basketId: basketId,
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
        ref.watch(learnToSortFoodControllerProvider.select((s) => s.phase));
    final settings = ref.watch(learnToSortFoodSettingsProvider);
    final envPhase =
        ref.watch(learnToSortFoodControllerProvider.select((s) => s.envPhase));
    final feedbackColor = ref.watch(
      learnToSortFoodControllerProvider.select((s) {
        final msg = s.feedbackMessage ?? '';
        if (msg.contains('JUNK')) return const Color(0xFFFB8C00);
        if (msg.contains('HEALTHY')) return const Color(0xFF43A047);
        return const Color(0xFF42A5F5);
      }),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && phase != FoodSortPhase.finished) {
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
                        learnToSortFoodControllerProvider
                            .select((s) => s.remainingSeconds),
                      ),
                      unlimitedTime: settings.unlimitedTime,
                      coinsEarned: ref.watch(
                        learnToSortFoodControllerProvider
                            .select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        learnToSortFoodControllerProvider
                            .select((s) => s.starsEarned),
                      ),
                      largerFonts: settings.largerTouchTargets,
                      onPause: _showPauseMenu,
                    ),
                    Expanded(
                      child: FoodSortBoard(
                        foods: ref.watch(
                          learnToSortFoodControllerProvider
                              .select((s) => s.foods),
                        ),
                        baskets: ref.watch(
                          learnToSortFoodControllerProvider
                              .select((s) => s.baskets),
                        ),
                        hoverBasketId: ref.watch(
                          learnToSortFoodControllerProvider
                              .select((s) => s.hoverBasketId),
                        ),
                        wrongHintText: ref.watch(
                          learnToSortFoodControllerProvider
                              .select((s) => s.wrongHintText),
                        ),
                        announcedName: ref.watch(
                          learnToSortFoodControllerProvider
                              .select((s) => s.spokenFoodName),
                        ),
                        announcedCategory: ref.watch(
                          learnToSortFoodControllerProvider
                              .select((s) => s.subFeedbackMessage),
                        ),
                        showFoodNames: settings.narrationEnabled,
                        largerTouch: settings.largerTouchTargets,
                        onDrop: _onDrop,
                        onHoverBasket: (id) => ref
                            .read(learnToSortFoodControllerProvider.notifier)
                            .setHoverBasket(id),
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
                    learnToSortFoodControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    learnToSortFoodControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    learnToSortFoodControllerProvider
                        .select((s) => s.showMascot),
                  ),
                  rewardShadowColor: feedbackColor,
                ),
                if (phase == FoodSortPhase.paused)
                  GamePausedOverlay(
                    onResume: () => ref
                        .read(learnToSortFoodControllerProvider.notifier)
                        .resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (phase == FoodSortPhase.finished)
                  FoodSortVictoryOverlay(
                    result: ref
                        .read(learnToSortFoodControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref.read(learnToSortFoodControllerProvider.notifier).reset();
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
