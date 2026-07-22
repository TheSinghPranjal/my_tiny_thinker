import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_feedback_banner.dart';
import 'package:my_tiny_thinker/core/widgets/game_paused_overlay.dart';
import 'package:my_tiny_thinker/core/widgets/game_session_hud.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/classic_card_memory/controllers/classic_card_memory_controller.dart';
import 'package:my_tiny_thinker/games/classic_card_memory/models/classic_card_memory_models.dart';
import 'package:my_tiny_thinker/games/classic_card_memory/presentation/widgets/classic_memory_background.dart';
import 'package:my_tiny_thinker/games/classic_card_memory/presentation/widgets/classic_memory_board.dart';
import 'package:my_tiny_thinker/games/classic_card_memory/repository/classic_card_memory_settings_repository.dart';

class ClassicCardMemoryGameScreen extends ConsumerStatefulWidget {
  const ClassicCardMemoryGameScreen({super.key});

  @override
  ConsumerState<ClassicCardMemoryGameScreen> createState() =>
      _ClassicCardMemoryGameScreenState();
}

class _ClassicCardMemoryGameScreenState
    extends ConsumerState<ClassicCardMemoryGameScreen>
    with WidgetsBindingObserver {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
    ref.listenManual(classicCardMemoryControllerProvider, (prev, next) {
      if (next.phase == ClassicMemoryPhase.finished &&
          prev?.phase != ClassicMemoryPhase.finished) {
        _onFinished();
      }
    });
  }

  Future<void> _start() async {
    if (!await ensureCanStartGame(
      context,
      ref,
      GameId.classicCardMemory,
    )) {
      return;
    }
    if (!mounted) return;
    _saved = false;
    final settings = ref.read(classicCardMemorySettingsProvider);
    ref.read(classicCardMemoryControllerProvider.notifier).reset();
    ref.read(classicCardMemoryControllerProvider.notifier).startGame(settings);
    ref.read(audioServiceProvider).playGameMusic();
  }

  Future<void> _onFinished() async {
    if (_saved) return;
    _saved = true;
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    await ref.read(classicCardMemoryControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(classicCardMemoryControllerProvider.notifier).pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(audioServiceProvider).playHomeMusic();
    super.dispose();
  }

  Future<void> _showPauseMenu() async {
    ref.read(classicCardMemoryControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () =>
          ref.read(classicCardMemoryControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(classicCardMemoryControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(classicCardMemoryControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onFlip(int index) {
    final before = ref.read(classicCardMemoryControllerProvider);
    ref.read(classicCardMemoryControllerProvider.notifier).flipCard(index);
    final after = ref.read(classicCardMemoryControllerProvider);

    if (after.matches > before.matches) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
      ref.read(hapticServiceProvider).trigger(HapticType.light);
    } else if (after.mistakes > before.mistakes) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.wrong);
      ref.read(hapticServiceProvider).trigger(HapticType.selection);
    } else {
      ref.read(audioServiceProvider).playSfx(SoundEffect.buttonTap);
      ref.read(hapticServiceProvider).trigger(HapticType.selection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(
      classicCardMemoryControllerProvider.select((s) => s.phase),
    );
    final category = ref.watch(
      classicCardMemoryControllerProvider.select((s) => s.category),
    );
    final pairCount = ref.watch(
      classicCardMemoryControllerProvider.select((s) => s.settings.pairCount),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && phase != ClassicMemoryPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: ClassicMemoryPlaygroundBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    GameSessionHud(
                      remainingSeconds: ref.watch(
                        classicCardMemoryControllerProvider
                            .select((s) => s.remainingSeconds),
                      ),
                      coinsEarned: ref.watch(
                        classicCardMemoryControllerProvider
                            .select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        classicCardMemoryControllerProvider
                            .select((s) => s.starsEarned),
                      ),
                      onPause: _showPauseMenu,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${category.emoji}  ${category.displayName}'
                        '  ·  $pairCount pairs'
                        '  ·  Round ${ref.watch(classicCardMemoryControllerProvider.select((s) => s.roundsCompleted)) + 1}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Color(0xFF4527A0),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: phase == ClassicMemoryPhase.countdown
                            ? Center(
                                child: Text(
                                  '${ref.watch(classicCardMemoryControllerProvider.select((s) => s.countdown))}',
                                  style: const TextStyle(
                                    fontSize: 96,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Color(0xFF7E57C2),
                                        blurRadius: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ClassicMemoryBoard(
                                cards: ref.watch(
                                  classicCardMemoryControllerProvider
                                      .select((s) => s.cards),
                                ),
                                pairCount: pairCount,
                                onFlip: _onFlip,
                              ),
                      ),
                    ),
                  ],
                ),
                GameFeedbackOverlay(
                  message: ref.watch(
                    classicCardMemoryControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    classicCardMemoryControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  rewardShadowColor: AppColors.softPurple,
                ),
                if (phase == ClassicMemoryPhase.paused)
                  GamePausedOverlay(
                    onResume: () => ref
                        .read(classicCardMemoryControllerProvider.notifier)
                        .resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (phase == ClassicMemoryPhase.finished)
                  ClassicMemoryVictoryOverlay(
                    result: ref
                        .read(classicCardMemoryControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref
                          .read(classicCardMemoryControllerProvider.notifier)
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
