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
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/pattern_match/controllers/pattern_match_controller.dart';
import 'package:my_tiny_thinker/games/pattern_match/logic/pattern_match_logic.dart';
import 'package:my_tiny_thinker/games/pattern_match/models/pattern_match_models.dart';

class PatternMatchGameScreen extends ConsumerStatefulWidget {
  const PatternMatchGameScreen({super.key});

  @override
  ConsumerState<PatternMatchGameScreen> createState() =>
      _PatternMatchGameScreenState();
}

class _PatternMatchGameScreenState extends ConsumerState<PatternMatchGameScreen> {
  bool _started = false;
  bool _resultShown = false;
  final _particleKey = GlobalKey<ParticleSystemState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_started) {
        _started = true;
        ref.read(patternMatchControllerProvider.notifier).start(
              ref.read(patternMatchConfigProvider),
            );
      }
    });
  }

  Future<void> _pause() async {
    await TTPauseDialog.show(
      context,
      onResume: () {},
      onRestart: () {
        _resultShown = false;
        ref.read(patternMatchControllerProvider.notifier).start(
              ref.read(patternMatchConfigProvider),
            );
      },
      onHome: () {
        ref.read(patternMatchControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(patternMatchControllerProvider);

    ref.listen(patternMatchControllerProvider, (prev, next) {
      if (next.phase == PatternPhase.victory && !_resultShown) {
        _resultShown = true;
        ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
        ref.read(patternMatchControllerProvider.notifier).saveResult().then((_) {
          if (!mounted) return;
          _showVictory(
            ref.read(patternMatchControllerProvider.notifier).getResult(),
          );
        });
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _pause();
      },
      child: AnimatedSkyBackground(
        showGrass: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.pause_rounded),
              onPressed: _pause,
            ),
            title: Text('Round ${state.round}/${state.roundsTarget}'),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('⭐ ${state.score}', style: context.textTheme.titleMedium),
                      const SizedBox(width: AppSpacing.lg),
                      Text('🔥 ${state.streak}', style: context.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TTCard(
                    gradient: AppGradients.bubblePurple,
                    child: Column(
                      children: [
                        Text(
                          'What comes next?',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: AppSpacing.md,
                          alignment: WrapAlignment.center,
                          children: state.sequence.asMap().entries.map((e) {
                            final isMissing = e.key == state.missingIndex;
                            return PulseAnimation(
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.white.withValues(alpha: 0.9),
                                  borderRadius:
                                      BorderRadius.circular(AppSpacing.radiusMd),
                                ),
                                child: Center(
                                  child: Text(
                                    e.value,
                                    style: TextStyle(
                                      fontSize: isMissing ? 28 : 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Pick the answer:', style: context.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: Stack(
                      children: [
                        Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.md,
                          alignment: WrapAlignment.center,
                          children: state.options.map((opt) {
                            final isWrong = state.wrongOptionId == opt.id;
                            return ShakeAnimation(
                              trigger: isWrong,
                              child: BounceTapWrapper(
                                onTap: () {
                                  if (opt.id == state.correctOptionId) {
                                    ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
                                    ref.read(hapticServiceProvider).trigger(HapticType.success);
                                    _particleKey.currentState?.emit();
                                  } else {
                                    ref.read(audioServiceProvider).playSfx(SoundEffect.wrong);
                                    ref.read(hapticServiceProvider).trigger(HapticType.error);
                                  }
                                  ref
                                      .read(patternMatchControllerProvider.notifier)
                                      .selectOption(opt.id);
                                },
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: AppGradients.welcomeCard,
                                    borderRadius:
                                        BorderRadius.circular(AppSpacing.radiusLg),
                                    border: Border.all(
                                      color: isWrong
                                          ? AppColors.error
                                          : AppColors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      opt.display,
                                      style: const TextStyle(fontSize: 36),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        ParticleSystem(
                          key: _particleKey,
                          particleCount: 20,
                          autoStart: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showVictory(PatternMatchResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(result.isPerfect ? 'Pattern Master!' : 'Great Job!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Score: ${result.score}'),
            Text('Stars: ${'⭐' * result.stars}'),
            Text('Coins: +${result.coins}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(patternMatchControllerProvider.notifier).reset();
              context.pop();
            },
            child: const Text('Home'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resultShown = false;
              ref.read(patternMatchControllerProvider.notifier).start(
                    ref.read(patternMatchConfigProvider),
                  );
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }
}
