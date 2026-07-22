import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/animations/bounce_animation.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_feedback_banner.dart';
import 'package:my_tiny_thinker/core/widgets/game_paused_overlay.dart';
import 'package:my_tiny_thinker/core/widgets/game_session_hud.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/animal_sounds/controllers/animal_sounds_controller.dart';
import 'package:my_tiny_thinker/games/animal_sounds/models/animal_sounds_models.dart';
import 'package:my_tiny_thinker/games/animal_sounds/presentation/widgets/animal_sounds_background.dart';
import 'package:my_tiny_thinker/games/animal_sounds/presentation/widgets/animal_sounds_hud.dart';
import 'package:my_tiny_thinker/games/animal_sounds/repository/animal_sounds_settings_repository.dart';

class AnimalSoundsGameScreen extends ConsumerStatefulWidget {
  const AnimalSoundsGameScreen({super.key});

  @override
  ConsumerState<AnimalSoundsGameScreen> createState() =>
      _AnimalSoundsGameScreenState();
}

class _AnimalSoundsGameScreenState
    extends ConsumerState<AnimalSoundsGameScreen> with WidgetsBindingObserver {
  final _particleKey = GlobalKey<ParticleSystemState>();
  bool _saved = false;
  String? _lastPlayedQuestionId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(animalSoundsControllerProvider, (prev, next) {
      if (next.phase == AnimalSoundsPhase.finished && !_saved) {
        _onFinished();
      }
      if (next.showSparkles && next.phase == AnimalSoundsPhase.celebrating) {
        _particleKey.currentState?.emit();
      }
      final correctId = next.question?.correct.id;
      if (next.phase == AnimalSoundsPhase.playing &&
          correctId != null &&
          correctId != _lastPlayedQuestionId &&
          next.settings.autoPlaySound &&
          next.settings.soundEnabled) {
        _lastPlayedQuestionId = correctId;
        _playAnimalSound(next.question!.correct.soundAsset);
      }
    });
  }

  Future<void> _start() async {
    if (!await ensureCanStartGame(
      context,
      ref,
      GameId.animalSounds,
    )) {
      return;
    }
    if (!mounted) return;
    _saved = false;
    _lastPlayedQuestionId = null;
    final settings = ref.read(animalSoundsSettingsProvider);
    ref.read(animalSoundsControllerProvider.notifier).reset();
    ref.read(animalSoundsControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playGameMusic();
    }
  }

  Future<void> _onFinished() async {
    _saved = true;
    ref.read(audioServiceProvider).stopClip();
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    await ref.read(animalSoundsControllerProvider.notifier).saveResult();
  }

  void _playAnimalSound(String assetPath) {
    final settings = ref.read(animalSoundsSettingsProvider);
    if (!settings.soundEnabled) return;
    ref.read(audioServiceProvider).playClip(assetPath);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(animalSoundsControllerProvider.notifier).pause();
      ref.read(audioServiceProvider).stopClip();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(audioServiceProvider).stopClip();
    ref.read(audioServiceProvider).playHomeMusic();
    super.dispose();
  }

  Future<void> _showPauseMenu() async {
    ref.read(animalSoundsControllerProvider.notifier).pause();
    ref.read(audioServiceProvider).stopClip();
    await TTPauseDialog.show(
      context,
      onResume: () =>
          ref.read(animalSoundsControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(animalSoundsControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(animalSoundsControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onSelect(String animalId) {
    final settings = ref.read(animalSoundsSettingsProvider);
    final ok =
        ref.read(animalSoundsControllerProvider.notifier).selectOption(animalId);

    if (settings.hapticsEnabled) {
      ref.read(hapticServiceProvider).trigger(
            ok ? HapticType.success : HapticType.medium,
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
      animalSoundsControllerProvider.select((s) => s.phase),
    );
    final question = ref.watch(
      animalSoundsControllerProvider.select((s) => s.question),
    );
    final celebrating = phase == AnimalSoundsPhase.celebrating;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && phase != AnimalSoundsPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: AnimalSoundsBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    GameSessionHud(
                      remainingSeconds: ref.watch(
                        animalSoundsControllerProvider
                            .select((s) => s.remainingSeconds),
                      ),
                      coinsEarned: ref.watch(
                        animalSoundsControllerProvider
                            .select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        animalSoundsControllerProvider
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
                                  Text(
                                    'Who made that sound?',
                                    textAlign: TextAlign.center,
                                    style:
                                        context.textTheme.titleLarge?.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w800,
                                      shadows: const [
                                        Shadow(
                                          color: Color(0xFF1B5E20),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  _SpeakerButton(
                                    enabled: phase ==
                                            AnimalSoundsPhase.playing ||
                                        phase == AnimalSoundsPhase.celebrating,
                                    onTap: () => _playAnimalSound(
                                      question.correct.soundAsset,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Tap to hear again!',
                                    style:
                                        context.textTheme.titleSmall?.copyWith(
                                      color: AppColors.white
                                          .withValues(alpha: 0.9),
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
                                            (option) => _AnimalOptionCard(
                                              option: option,
                                              enabled: phase ==
                                                  AnimalSoundsPhase.playing,
                                              onTap: () => _onSelect(
                                                option.animal.id,
                                              ),
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
                    animalSoundsControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    animalSoundsControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  showMascot: celebrating,
                  rewardShadowColor: AppColors.orange,
                ),
                if (phase == AnimalSoundsPhase.ready && question != null)
                  GamePausedOverlay(
                    onResume: () => ref
                        .read(animalSoundsControllerProvider.notifier)
                        .resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (phase == AnimalSoundsPhase.finished)
                  AnimalSoundsVictoryOverlay(
                    result: ref
                        .read(animalSoundsControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref
                          .read(animalSoundsControllerProvider.notifier)
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

class _SpeakerButton extends StatefulWidget {
  const _SpeakerButton({
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_SpeakerButton> createState() => _SpeakerButtonState();
}

class _SpeakerButtonState extends State<_SpeakerButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return PulseAnimation(
      child: GestureDetector(
        onTapDown: widget.enabled
            ? (_) => setState(() => _pressed = true)
            : null,
        onTapUp: widget.enabled
            ? (_) {
                setState(() => _pressed = false);
                widget.onTap();
              }
            : null,
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFCC80), Color(0xFFFF8A65)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withValues(alpha: 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: AppColors.white, width: 4),
            ),
            child: const Icon(
              Icons.volume_up_rounded,
              size: 56,
              color: Color(0xFF5D4037),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimalOptionCard extends StatelessWidget {
  const _AnimalOptionCard({
    required this.option,
    required this.enabled,
    required this.onTap,
  });

  final AnimalOption option;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final animal = option.animal;
    return AnimatedScale(
      scale: option.highlight ? 1.06 : option.shake ? 0.94 : 1.0,
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
                color: option.highlight
                    ? AppColors.sunYellow
                    : option.shake
                        ? AppColors.grassGreen
                        : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: option.highlight
                      ? AppColors.sunYellow.withValues(alpha: 0.5)
                      : AppColors.skyBlue.withValues(alpha: 0.2),
                  blurRadius: option.highlight ? 14 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(animal.emoji, style: const TextStyle(fontSize: 52)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  animal.name,
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
