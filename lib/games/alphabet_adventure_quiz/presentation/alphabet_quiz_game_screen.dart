import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/animations/bounce_animation.dart';
import 'package:my_tiny_thinker/core/widgets/game_session_hud.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_feedback_banner.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/core/widgets/game_paused_overlay.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/controllers/alphabet_quiz_controller.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/models/alphabet_quiz_models.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/presentation/widgets/alphabet_meadow_background.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/presentation/widgets/alphabet_quiz_hud.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/presentation/widgets/alphabet_quiz_widgets.dart';
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

  Future<void> _start() async {
    if (!await ensureCanStartGame(
      context,
      ref,
      GameId.alphabetAdventureQuiz,
    )) {
      return;
    }
    if (!mounted) return;
    _saved = false;
    final settings = ref.read(alphabetQuizSettingsProvider);
    ref.read(alphabetQuizControllerProvider.notifier).reset();
    ref.read(alphabetQuizControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playGameMusic();
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
    ref.read(audioServiceProvider).playHomeMusic();
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
      child: AlphabetMeadowBackground(
        reducedMotion: ref.watch(
          alphabetQuizSettingsProvider.select((s) => s.reducedMotion),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    GameSessionHud(
                      remainingSeconds: ref.watch(
                        alphabetQuizControllerProvider.select((s) => s.remainingSeconds),
                      ),
                      coinsEarned: ref.watch(
                        alphabetQuizControllerProvider.select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        alphabetQuizControllerProvider.select((s) => s.starsEarned),
                      ),
                      onPause: _showPauseMenu,
                    ),
                    Expanded(
                      child: question == null
                          ? const Center(child: CircularProgressIndicator())
                          : _QuizBody(
                              question: question,
                              enabled: phase == AlphabetQuizPhase.playing,
                              onSelect: _onSelect,
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

class _QuizBody extends StatelessWidget {
  const _QuizBody({
    required this.question,
    required this.enabled,
    required this.onSelect,
  });

  final AlphabetQuestion question;
  final bool enabled;
  final void Function(String itemId) onSelect;

  @override
  Widget build(BuildContext context) {
    // The answer word is revealed once the right picture has been chosen.
    final answered = question.options.any((o) => o.glow);
    final answerWord = answered
        ? question.options
            .firstWhere((o) => o.itemId == question.correctItemId,
                orElse: () => question.options.first)
            .item
            ?.name
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 12),
      child: Column(
        children: [
          const AlphabetTitleBanner(),
          const SizedBox(height: 6),
          PulseAnimation(child: AlphabetLetterTile(letter: question.letter)),
          const SizedBox(height: 10),
          AlphabetAnswerPill(letter: question.letter, word: answerWord),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                const gap = 14.0;
                final w = (c.maxWidth - gap) / 2;
                final h = (c.maxHeight - gap) / 2;
                return GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  crossAxisCount: 2,
                  crossAxisSpacing: gap,
                  mainAxisSpacing: gap,
                  childAspectRatio: w / h,
                  children: question.options.map((option) {
                    final item = option.item;
                    return AlphabetPictureCard(
                      emoji: item?.emoji ?? '?',
                      name: item?.name ?? '',
                      correct: option.glow,
                      wrong: option.shake,
                      enabled: enabled,
                      onTap: () => onSelect(option.itemId),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
