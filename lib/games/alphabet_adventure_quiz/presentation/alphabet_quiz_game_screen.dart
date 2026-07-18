import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/animations/bounce_animation.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/game_feedback_banner.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/core/widgets/game_paused_overlay.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/controllers/alphabet_quiz_controller.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/models/alphabet_quiz_models.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/presentation/widgets/alphabet_quiz_hud.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/repository/alphabet_quiz_settings_repository.dart';

class AlphabetQuizGameScreen extends ConsumerStatefulWidget {
  const AlphabetQuizGameScreen({super.key});

  @override
  ConsumerState<AlphabetQuizGameScreen> createState() =>
      _AlphabetQuizGameScreenState();
}

class _AlphabetQuizGameScreenState extends ConsumerState<AlphabetQuizGameScreen>
    with WidgetsBindingObserver {
  final _particleKey = GlobalKey<ParticleSystemState>();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(alphabetQuizControllerProvider, (prev, next) {
      if (next.phase == AlphabetQuizPhase.finished && !_saved) {
        _onFinished();
      }
      if (next.showSparkles && next.phase == AlphabetQuizPhase.celebrating) {
        _particleKey.currentState?.emit();
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(alphabetQuizSettingsProvider);
    ref.read(alphabetQuizControllerProvider.notifier).reset();
    ref.read(alphabetQuizControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playMusic(asset: 'audio/ambient_music.mp3');
    }
  }

  Future<void> _onFinished() async {
    _saved = true;
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    await ref.read(alphabetQuizControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(alphabetQuizControllerProvider.notifier).pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(audioServiceProvider).stopMusic();
    super.dispose();
  }

  Future<void> _showPauseMenu() async {
    ref.read(alphabetQuizControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () =>
          ref.read(alphabetQuizControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(alphabetQuizControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(alphabetQuizControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onSelect(String itemId) {
    final settings = ref.read(alphabetQuizSettingsProvider);
    final ok =
        ref.read(alphabetQuizControllerProvider.notifier).selectOption(itemId);

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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(
      alphabetQuizControllerProvider.select((s) => s.phase),
    );
    final question = ref.watch(
      alphabetQuizControllerProvider.select((s) => s.question),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && phase != AlphabetQuizPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: AnimatedSkyBackground(
        showGrass: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    AlphabetQuizHud(
                      remainingSeconds: ref.watch(
                        alphabetQuizControllerProvider
                            .select((s) => s.remainingSeconds),
                      ),
                      score: ref.watch(
                        alphabetQuizControllerProvider.select((s) => s.score),
                      ),
                      coinsEarned: ref.watch(
                        alphabetQuizControllerProvider
                            .select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        alphabetQuizControllerProvider
                            .select((s) => s.starsEarned),
                      ),
                      onPause: _showPauseMenu,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: question == null
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                                children: [
                                  PulseAnimation(
                                    child: TTCard(
                                      gradient: AppGradients.rainbow,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: AppSpacing.xl,
                                        horizontal: AppSpacing.xxl,
                                      ),
                                      child: Text(
                                        question.letter,
                                        style: context.textTheme.displayLarge
                                            ?.copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 96,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    question.prompt.split('!').first,
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  Expanded(
                                    child: GridView.count(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: AppSpacing.md,
                                      mainAxisSpacing: AppSpacing.md,
                                      children: question.options
                                          .map(
                                            (option) => _OptionCard(
                                              option: option,
                                              enabled: phase ==
                                                  AlphabetQuizPhase.playing,
                                              onTap: () =>
                                                  _onSelect(option.itemId),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: ParticleSystem(
                      key: _particleKey,
                      particleCount: 28,
                      autoStart: false,
                    ),
                  ),
                ),
                GameFeedbackOverlay(
                  message: ref.watch(
                    alphabetQuizControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    alphabetQuizControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    alphabetQuizControllerProvider
                        .select((s) => s.showMascot),
                  ),
                  rewardShadowColor: AppColors.orange,
                ),
                if (phase == AlphabetQuizPhase.paused) GamePausedOverlay(
                    onResume: () => ref.read(alphabetQuizControllerProvider.notifier).resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (phase == AlphabetQuizPhase.finished)
                  AlphabetQuizVictoryOverlay(
                    result: ref
                        .read(alphabetQuizControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref.read(alphabetQuizControllerProvider.notifier).reset();
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

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.enabled,
    required this.onTap,
  });

  final AlphabetOption option;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final item = option.item;
    return AnimatedScale(
      scale: option.glow ? 1.06 : option.shake ? 0.94 : 1.0,
      duration: const Duration(milliseconds: 180),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(
                color: option.glow
                    ? AppColors.sunYellow
                    : option.shake
                        ? AppColors.candyPink
                        : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: option.glow
                      ? AppColors.sunYellow.withValues(alpha: 0.45)
                      : AppColors.skyBlue.withValues(alpha: 0.2),
                  blurRadius: option.glow ? 14 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item?.emoji ?? '?', style: const TextStyle(fontSize: 52)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item?.name ?? '',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

