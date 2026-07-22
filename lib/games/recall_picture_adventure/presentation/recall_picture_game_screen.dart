import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_feedback_banner.dart';
import 'package:my_tiny_thinker/core/widgets/game_paused_overlay.dart';
import 'package:my_tiny_thinker/core/widgets/game_session_hud.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/recall_picture_adventure/controllers/recall_picture_controller.dart';
import 'package:my_tiny_thinker/games/recall_picture_adventure/models/recall_picture_models.dart';
import 'package:my_tiny_thinker/games/recall_picture_adventure/presentation/widgets/recall_picture_background.dart';
import 'package:my_tiny_thinker/games/recall_picture_adventure/presentation/widgets/recall_picture_board.dart';
import 'package:my_tiny_thinker/games/recall_picture_adventure/repository/recall_picture_settings_repository.dart';

class RecallPictureGameScreen extends ConsumerStatefulWidget {
  const RecallPictureGameScreen({super.key});

  @override
  ConsumerState<RecallPictureGameScreen> createState() =>
      _RecallPictureGameScreenState();
}

class _RecallPictureGameScreenState
    extends ConsumerState<RecallPictureGameScreen>
    with WidgetsBindingObserver {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
    ref.listenManual(recallPictureControllerProvider, (prev, next) {
      if (next.phase == RecallPicturePhase.finished &&
          prev?.phase != RecallPicturePhase.finished) {
        _onFinished();
      }
      if (next.bounceCorrect && !(prev?.bounceCorrect ?? false)) {
        ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
        ref.read(hapticServiceProvider).trigger(HapticType.light);
      }
    });
  }

  Future<void> _start() async {
    _saved = false;
    final settings = ref.read(recallPictureSettingsProvider);
    ref.read(recallPictureControllerProvider.notifier).reset();
    ref.read(recallPictureControllerProvider.notifier).startGame(settings);
    ref.read(audioServiceProvider).playGameMusic();
  }

  Future<void> _onFinished() async {
    if (_saved) return;
    _saved = true;
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    await ref.read(recallPictureControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(recallPictureControllerProvider.notifier).pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(audioServiceProvider).playHomeMusic();
    super.dispose();
  }

  Future<void> _showPauseMenu() async {
    ref.read(recallPictureControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () =>
          ref.read(recallPictureControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(recallPictureControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(recallPictureControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onAnswer(String optionId) {
    final ok =
        ref.read(recallPictureControllerProvider.notifier).answer(optionId);
    if (ok) {
      // Correct SFX handled via bounceCorrect listener for bounce sync.
    } else {
      ref.read(audioServiceProvider).playSfx(SoundEffect.buttonTap);
      ref.read(hapticServiceProvider).trigger(HapticType.selection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(
      recallPictureControllerProvider.select((s) => s.phase),
    );
    final scene = ref.watch(
      recallPictureControllerProvider.select((s) => s.scene),
    );
    final celebrating = phase == RecallPicturePhase.celebrating;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && phase != RecallPicturePhase.finished) {
          await _showPauseMenu();
        }
      },
      child: RecallPictureBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    GameSessionHud(
                      remainingSeconds: ref.watch(
                        recallPictureControllerProvider
                            .select((s) => s.remainingSeconds),
                      ),
                      coinsEarned: ref.watch(
                        recallPictureControllerProvider
                            .select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        recallPictureControllerProvider
                            .select((s) => s.starsEarned),
                      ),
                      onPause: _showPauseMenu,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Round ${ref.watch(recallPictureControllerProvider.select((s) => s.roundsCompleted)) + 1}'
                        '  ·  Correct ${ref.watch(recallPictureControllerProvider.select((s) => s.correctCount))}'
                        '${ref.watch(recallPictureControllerProvider.select((s) => s.combo)) > 1 ? '  ·  Combo x${ref.watch(recallPictureControllerProvider.select((s) => s.combo))}' : ''}',
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
                        child: phase == RecallPicturePhase.countdown
                            ? Center(
                                child: Text(
                                  '${ref.watch(recallPictureControllerProvider.select((s) => s.countdown))}',
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
                            : scene == null
                                ? const SizedBox.shrink()
                                : RecallPictureBoard(
                                    scene: scene,
                                    question: ref.watch(
                                      recallPictureControllerProvider
                                          .select((s) => s.question),
                                    ),
                                    phase: phase,
                                    selectedOptionId: ref.watch(
                                      recallPictureControllerProvider
                                          .select((s) => s.selectedOptionId),
                                    ),
                                    wrongOptionId: ref.watch(
                                      recallPictureControllerProvider
                                          .select((s) => s.wrongOptionId),
                                    ),
                                    bounceCorrect: ref.watch(
                                      recallPictureControllerProvider
                                          .select((s) => s.bounceCorrect),
                                    ),
                                    onAnswer: _onAnswer,
                                  ),
                      ),
                    ),
                  ],
                ),
                if (celebrating &&
                    ref.watch(
                      recallPictureControllerProvider
                          .select((s) => s.bounceCorrect),
                    ))
                  const _CelebrationBurst(),
                GameFeedbackOverlay(
                  message: ref.watch(
                    recallPictureControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    recallPictureControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  rewardShadowColor: AppColors.softPurple,
                ),
                if (phase == RecallPicturePhase.paused)
                  GamePausedOverlay(
                    onResume: () => ref
                        .read(recallPictureControllerProvider.notifier)
                        .resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (phase == RecallPicturePhase.finished)
                  RecallPictureVictoryOverlay(
                    result: ref
                        .read(recallPictureControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref
                          .read(recallPictureControllerProvider.notifier)
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

class _CelebrationBurst extends StatelessWidget {
  const _CelebrationBurst();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.4, end: 1.2),
          duration: const Duration(milliseconds: 900),
          builder: (context, scale, _) {
            return Opacity(
              opacity: (1.4 - scale).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: scale,
                child: const Text(
                  '✨🎉⭐🎊✨',
                  style: TextStyle(fontSize: 42),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
