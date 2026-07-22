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
import 'package:my_tiny_thinker/games/number_memory/controllers/number_memory_controller.dart';
import 'package:my_tiny_thinker/games/number_memory/models/number_memory_models.dart';
import 'package:my_tiny_thinker/games/number_memory/presentation/widgets/number_memory_background.dart';
import 'package:my_tiny_thinker/games/number_memory/presentation/widgets/number_memory_board.dart';
import 'package:my_tiny_thinker/games/number_memory/repository/number_memory_settings_repository.dart';

class NumberMemoryGameScreen extends ConsumerStatefulWidget {
  const NumberMemoryGameScreen({super.key});

  @override
  ConsumerState<NumberMemoryGameScreen> createState() =>
      _NumberMemoryGameScreenState();
}

class _NumberMemoryGameScreenState extends ConsumerState<NumberMemoryGameScreen>
    with WidgetsBindingObserver {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
    ref.listenManual(numberMemoryControllerProvider, (prev, next) {
      if (next.phase == NumberMemoryPhase.finished &&
          prev?.phase != NumberMemoryPhase.finished) {
        _onFinished();
      }
      if (next.phase == NumberMemoryPhase.celebrating &&
          prev?.phase != NumberMemoryPhase.celebrating) {
        ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
        ref.read(hapticServiceProvider).trigger(HapticType.medium);
      }
    });
  }

  Future<void> _start() async {
    _saved = false;
    final settings = ref.read(numberMemorySettingsProvider);
    ref.read(numberMemoryControllerProvider.notifier).reset();
    ref.read(numberMemoryControllerProvider.notifier).startGame(settings);
    ref.read(audioServiceProvider).playGameMusic();
  }

  Future<void> _onFinished() async {
    if (_saved) return;
    _saved = true;
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    await ref.read(numberMemoryControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(numberMemoryControllerProvider.notifier).pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(audioServiceProvider).playHomeMusic();
    super.dispose();
  }

  Future<void> _showPauseMenu() async {
    ref.read(numberMemoryControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () =>
          ref.read(numberMemoryControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(numberMemoryControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(numberMemoryControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onDigit(String digit) {
    ref.read(numberMemoryControllerProvider.notifier).tapDigit(digit);
    ref.read(audioServiceProvider).playSfx(SoundEffect.buttonTap);
    ref.read(hapticServiceProvider).trigger(HapticType.selection);
  }

  void _onClear() {
    ref.read(numberMemoryControllerProvider.notifier).clearInput();
    ref.read(audioServiceProvider).playSfx(SoundEffect.buttonTap);
  }

  void _onSubmit() {
    final ok = ref.read(numberMemoryControllerProvider.notifier).submit();
    if (ok == null) return;
    if (ok) {
      // Correct SFX handled by celebrating listener.
      ref.read(hapticServiceProvider).trigger(HapticType.light);
    } else {
      // Gentle retry cue — never a harsh fail sound.
      ref.read(audioServiceProvider).playSfx(SoundEffect.buttonTap);
      ref.read(hapticServiceProvider).trigger(HapticType.selection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(
      numberMemoryControllerProvider.select((s) => s.phase),
    );
    final digitCount = ref.watch(
      numberMemoryControllerProvider.select((s) => s.settings.digitCount),
    );
    final celebrating = phase == NumberMemoryPhase.celebrating;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && phase != NumberMemoryPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: NumberMemoryBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    GameSessionHud(
                      remainingSeconds: ref.watch(
                        numberMemoryControllerProvider
                            .select((s) => s.remainingSeconds),
                      ),
                      coinsEarned: ref.watch(
                        numberMemoryControllerProvider
                            .select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        numberMemoryControllerProvider
                            .select((s) => s.starsEarned),
                      ),
                      onPause: _showPauseMenu,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Correct ${ref.watch(numberMemoryControllerProvider.select((s) => s.correctCount))}  ·  '
                        '$digitCount digits'
                        '${ref.watch(numberMemoryControllerProvider.select((s) => s.combo)) > 1 ? '  ·  Combo x${ref.watch(numberMemoryControllerProvider.select((s) => s.combo))}' : ''}',
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
                        child: phase == NumberMemoryPhase.countdown
                            ? Center(
                                child: Text(
                                  '${ref.watch(numberMemoryControllerProvider.select((s) => s.countdown))}',
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
                            : NumberMemoryBoard(
                                phase: phase,
                                targetNumber: ref.watch(
                                  numberMemoryControllerProvider
                                      .select((s) => s.targetNumber),
                                ),
                                input: ref.watch(
                                  numberMemoryControllerProvider
                                      .select((s) => s.input),
                                ),
                                digitCount: digitCount,
                                showShake: ref.watch(
                                  numberMemoryControllerProvider
                                      .select((s) => s.showShake),
                                ),
                                showErrorBorder: ref.watch(
                                  numberMemoryControllerProvider
                                      .select((s) => s.showErrorBorder),
                                ),
                                celebrating: celebrating,
                                onDigit: _onDigit,
                                onClear: _onClear,
                                onSubmit: _onSubmit,
                              ),
                      ),
                    ),
                  ],
                ),
                if (celebrating) const _CelebrationBurst(),
                GameFeedbackOverlay(
                  message: ref.watch(
                    numberMemoryControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    numberMemoryControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  rewardShadowColor: AppColors.softPurple,
                ),
                if (phase == NumberMemoryPhase.paused)
                  GamePausedOverlay(
                    onResume: () => ref
                        .read(numberMemoryControllerProvider.notifier)
                        .resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (phase == NumberMemoryPhase.finished)
                  NumberMemoryVictoryOverlay(
                    result: ref
                        .read(numberMemoryControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref
                          .read(numberMemoryControllerProvider.notifier)
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
