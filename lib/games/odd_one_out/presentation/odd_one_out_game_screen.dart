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
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/game_paused_overlay.dart';
import 'package:my_tiny_thinker/core/widgets/game_session_hud.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/odd_one_out/controllers/odd_one_out_controller.dart';
import 'package:my_tiny_thinker/games/odd_one_out/logic/odd_one_out_logic.dart';
import 'package:my_tiny_thinker/games/odd_one_out/models/odd_one_out_models.dart';
import 'package:my_tiny_thinker/games/odd_one_out/presentation/widgets/odd_one_out_hud.dart';
import 'package:my_tiny_thinker/games/odd_one_out/repository/odd_one_out_settings_repository.dart';

class OddOneOutGameScreen extends ConsumerStatefulWidget {
  const OddOneOutGameScreen({super.key});

  @override
  ConsumerState<OddOneOutGameScreen> createState() => _OddOneOutGameScreenState();
}

class _OddOneOutGameScreenState extends ConsumerState<OddOneOutGameScreen>
    with WidgetsBindingObserver {
  bool _saved = false;
  final _particleKey = GlobalKey<ParticleSystemState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(oddOneOutControllerProvider, (prev, next) {
      if (next.phase == OddOnePhase.finished && !_saved) {
        _onFinished();
      }
      if (next.showSparkles) {
        _particleKey.currentState?.emit();
      }
    });
  }

  Future<void> _start() async {
    if (!await ensureCanStartGame(
      context,
      ref,
      GameId.oddOneOut,
    )) {
      return;
    }
    if (!mounted) return;
    _saved = false;
    final settings = ref.read(oddOneOutSettingsProvider);
    ref.read(oddOneOutControllerProvider.notifier).reset();
    ref.read(oddOneOutControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playGameMusic();
    }
  }

  Future<void> _onFinished() async {
    _saved = true;
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    await ref.read(oddOneOutControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(oddOneOutControllerProvider.notifier).pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(audioServiceProvider).playHomeMusic();
    super.dispose();
  }

  Future<void> _showPauseMenu() async {
    ref.read(oddOneOutControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () => ref.read(oddOneOutControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(oddOneOutControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(oddOneOutControllerProvider);
    final settings = ref.watch(oddOneOutSettingsProvider);
    final phase = state.phase;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && phase != OddOnePhase.finished) {
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
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      GameSessionHud(
                        remainingSeconds: state.remainingSeconds,
                        coinsEarned: state.score,
                        starsEarned: state.streak,
                        onPause: _showPauseMenu,
                      ),
                      if (OddOneOutScoring.streakLabel(state.streak).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text(
                            OddOneOutScoring.streakLabel(state.streak),
                            style: context.textTheme.labelMedium?.copyWith(
                              color: AppColors.lavender,
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Tap the odd one out!',
                        style: context.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Expanded(
                        child: Stack(
                          children: [
                            GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: state.gridSize,
                                crossAxisSpacing: AppSpacing.sm,
                                mainAxisSpacing: AppSpacing.sm,
                              ),
                              itemCount: state.items.length,
                              itemBuilder: (context, i) {
                                final item = state.items[i];
                                return _OddItemTile(
                                  item: item,
                                  isWrong: state.wrongItemId == item.id,
                                  showHint: state.showHint && item.isOdd,
                                  reducedMotion: settings.reducedMotion,
                                  onTap: () {
                                    if (settings.soundEnabled) {
                                      if (item.isOdd) {
                                        ref
                                            .read(audioServiceProvider)
                                            .playSfx(SoundEffect.correct);
                                      } else {
                                        ref
                                            .read(audioServiceProvider)
                                            .playSfx(SoundEffect.wrong);
                                      }
                                    }
                                    if (settings.hapticsEnabled) {
                                      if (item.isOdd) {
                                        ref
                                            .read(hapticServiceProvider)
                                            .trigger(HapticType.success);
                                      } else {
                                        ref
                                            .read(hapticServiceProvider)
                                            .trigger(HapticType.error);
                                      }
                                    }
                                    ref
                                        .read(oddOneOutControllerProvider.notifier)
                                        .selectItem(item.id);
                                  },
                                );
                              },
                            ),
                            IgnorePointer(
                              child: ParticleSystem(
                                key: _particleKey,
                                particleCount: 20,
                                autoStart: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (phase == OddOnePhase.paused)
                  GamePausedOverlay(
                    onResume: () =>
                        ref.read(oddOneOutControllerProvider.notifier).resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (phase == OddOnePhase.finished)
                  OddOneOutVictoryOverlay(
                    result: ref.read(oddOneOutControllerProvider.notifier).getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref.read(oddOneOutControllerProvider.notifier).reset();
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

class _OddItemTile extends StatelessWidget {
  const _OddItemTile({
    required this.item,
    required this.onTap,
    this.isWrong = false,
    this.showHint = false,
    this.reducedMotion = false,
  });

  final OddOneItem item;
  final VoidCallback onTap;
  final bool isWrong;
  final bool showHint;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    final tile = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: reducedMotion ? 0 : 200),
        decoration: BoxDecoration(
          gradient: AppGradients.welcomeCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isWrong
                ? AppColors.error
                : showHint
                    ? AppColors.sunYellow
                    : AppColors.white,
            width: showHint || isWrong ? 3 : 2,
          ),
          boxShadow: showHint
              ? [
                  BoxShadow(
                    color: AppColors.sunYellow.withValues(alpha: 0.6),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Transform.rotate(
            angle: item.rotation,
            child: Transform.scale(
              scale: item.scale,
              child: Text(
                item.display,
                style: TextStyle(fontSize: context.isTablet ? 40 : 32),
              ),
            ),
          ),
        ),
      ),
    );

    if (reducedMotion) return tile;
    return ShakeAnimation(trigger: isWrong, child: tile);
  }
}
