import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/game_feedback_banner.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/shared/education_vocabulary.dart';
import 'package:my_tiny_thinker/games/shadow_match_adventure/controllers/shadow_match_controller.dart';
import 'package:my_tiny_thinker/games/shadow_match_adventure/models/shadow_match_models.dart';
import 'package:my_tiny_thinker/games/shadow_match_adventure/presentation/widgets/shadow_match_board.dart';
import 'package:my_tiny_thinker/games/shadow_match_adventure/presentation/widgets/shadow_match_hud.dart';
import 'package:my_tiny_thinker/games/shadow_match_adventure/repository/shadow_match_settings_repository.dart';

class ShadowMatchGameScreen extends ConsumerStatefulWidget {
  const ShadowMatchGameScreen({super.key});

  @override
  ConsumerState<ShadowMatchGameScreen> createState() =>
      _ShadowMatchGameScreenState();
}

class _ShadowMatchGameScreenState extends ConsumerState<ShadowMatchGameScreen>
    with WidgetsBindingObserver {
  final _particleKey = GlobalKey<ParticleSystemState>();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(shadowMatchControllerProvider, (prev, next) {
      if (next.phase == ShadowMatchPhase.finished && !_saved) {
        _onFinished();
      }
      if (next.showSparkles && next.phase == ShadowMatchPhase.celebrating) {
        _particleKey.currentState?.emit();
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(shadowMatchSettingsProvider);
    ref.read(shadowMatchControllerProvider.notifier).reset();
    ref.read(shadowMatchControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playMusic(asset: 'audio/ambient_music.mp3');
    }
  }

  Future<void> _onFinished() async {
    _saved = true;
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    await ref.read(shadowMatchControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(shadowMatchControllerProvider.notifier).pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(audioServiceProvider).stopMusic();
    super.dispose();
  }

  Future<void> _showPauseMenu() async {
    ref.read(shadowMatchControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () =>
          ref.read(shadowMatchControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(shadowMatchControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () {
        ref.read(shadowMatchControllerProvider.notifier).pause();
        context.push(AppRoutes.parentZone);
      },
    );
  }

  void _onDrop(String itemId, String shadowItemId) {
    final settings = ref.read(shadowMatchSettingsProvider);
    final ok = ref
        .read(shadowMatchControllerProvider.notifier)
        .tryMatch(itemId, shadowItemId);

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

    if (ok && settings.narrationEnabled) {
      final item = EducationVocabulary.byId(itemId);
      if (item != null) {
        // Voice narration placeholder — item name shown in feedback banner.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(
      shadowMatchControllerProvider.select((s) => s.phase),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && phase != ShadowMatchPhase.finished) {
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
                    ShadowMatchHud(
                      remainingSeconds: ref.watch(
                        shadowMatchControllerProvider
                            .select((s) => s.remainingSeconds),
                      ),
                      score: ref.watch(
                        shadowMatchControllerProvider.select((s) => s.score),
                      ),
                      coinsEarned: ref.watch(
                        shadowMatchControllerProvider
                            .select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        shadowMatchControllerProvider
                            .select((s) => s.starsEarned),
                      ),
                      onPause: _showPauseMenu,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            Text(
                              'Match the Shadows!',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Expanded(
                              flex: 5,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  gradient: AppGradients.welcomeCard,
                                  borderRadius:
                                      BorderRadius.circular(AppSpacing.radiusXl),
                                ),
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: AppSpacing.md,
                                  runSpacing: AppSpacing.md,
                                  children: ref
                                      .watch(shadowMatchControllerProvider
                                          .select((s) => s.shadows))
                                      .map(
                                        (slot) => ShadowSlotWidget(
                                          slot: slot,
                                          onAccept: (itemId) =>
                                              _onDrop(itemId, slot.itemId),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Expanded(
                              flex: 4,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.white.withValues(alpha: 0.88),
                                  borderRadius:
                                      BorderRadius.circular(AppSpacing.radiusXl),
                                ),
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: AppSpacing.md,
                                  runSpacing: AppSpacing.md,
                                  children: ref
                                      .watch(shadowMatchControllerProvider
                                          .select((s) => s.items))
                                      .map(
                                        (item) => DraggableObjectWidget(
                                          itemState: item,
                                        ),
                                      )
                                      .toList(),
                                ),
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
                    shadowMatchControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    shadowMatchControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    shadowMatchControllerProvider
                        .select((s) => s.showMascot),
                  ),
                  rewardShadowColor: const Color(0xFF5E35B1),
                ),
                if (phase == ShadowMatchPhase.paused) const _PausedOverlay(),
                if (phase == ShadowMatchPhase.finished)
                  ShadowMatchVictoryOverlay(
                    result: ref
                        .read(shadowMatchControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref.read(shadowMatchControllerProvider.notifier).reset();
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
        color: const Color(0xFF5E35B1).withValues(alpha: 0.55),
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
