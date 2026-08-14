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
import 'package:my_tiny_thinker/games/clean_dirty_clothes_sort/controllers/clean_dirty_clothes_sort_controller.dart';
import 'package:my_tiny_thinker/games/clean_dirty_clothes_sort/models/clean_dirty_clothes_sort_models.dart';
import 'package:my_tiny_thinker/games/clean_dirty_clothes_sort/presentation/widgets/clothes_sort_board.dart';
import 'package:my_tiny_thinker/games/clean_dirty_clothes_sort/presentation/widgets/clothes_sort_hud.dart';
import 'package:my_tiny_thinker/games/clean_dirty_clothes_sort/presentation/widgets/laundry_room_background.dart';
import 'package:my_tiny_thinker/games/clean_dirty_clothes_sort/repository/clean_dirty_clothes_sort_settings_repository.dart';

class CleanDirtyClothesSortGameScreen extends ConsumerStatefulWidget {
  const CleanDirtyClothesSortGameScreen({super.key});

  @override
  ConsumerState<CleanDirtyClothesSortGameScreen> createState() =>
      _CleanDirtyClothesSortGameScreenState();
}

class _CleanDirtyClothesSortGameScreenState
    extends ConsumerState<CleanDirtyClothesSortGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _particleKey = GlobalKey<ParticleSystemState>();
  Ticker? _ticker;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(cleanDirtyClothesSortControllerProvider, (prev, next) {
      if (next.phase == LaundrySortPhase.finished && !_saved) {
        _onFinished();
      }
      if (next.showSparkles && next.phase == LaundrySortPhase.celebrating) {
        _particleKey.currentState?.emit();
      }
      if (next.showMilestone && next.phase == LaundrySortPhase.celebrating) {
        ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
      }
    });
  }

  Future<void> _start() async {
    if (!await ensureCanStartGame(context, ref, GameId.cleanDirtyClothesSort)) {
      return;
    }
    if (!mounted) return;
    _saved = false;
    final settings = ref.read(cleanDirtyClothesSortSettingsProvider);
    ref.read(cleanDirtyClothesSortControllerProvider.notifier).reset();
    ref.read(cleanDirtyClothesSortControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playGameMusic();
    }
    _ticker ??= createTicker((_) {
      ref.read(cleanDirtyClothesSortControllerProvider.notifier).tick(1 / 60);
    });
    if (!_ticker!.isActive) _ticker!.start();
  }

  Future<void> _onFinished() async {
    _saved = true;
    _ticker?.stop();
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    await ref.read(cleanDirtyClothesSortControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(cleanDirtyClothesSortControllerProvider.notifier).pause();
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
    ref.read(cleanDirtyClothesSortControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () =>
          ref.read(cleanDirtyClothesSortControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () async {
        final ctrl = ref.read(cleanDirtyClothesSortControllerProvider.notifier);
        await ctrl.saveResult();
        ctrl.reset();
        if (!mounted) return;
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(cleanDirtyClothesSortControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onDrop({required String itemId, required String targetId}) {
    final settings = ref.read(cleanDirtyClothesSortSettingsProvider);
    final ok = ref
        .read(cleanDirtyClothesSortControllerProvider.notifier)
        .tryDrop(itemId: itemId, targetId: targetId);

    if (settings.hapticsEnabled) {
      ref.read(hapticServiceProvider).trigger(
            ok ? HapticType.success : HapticType.light,
          );
    }
    if (settings.soundEnabled && ok) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
      ref.read(audioServiceProvider).playSfx(SoundEffect.reward);
      if (settings.coinRewardsEnabled) {
        ref.read(audioServiceProvider).playSfx(SoundEffect.coin);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(
      cleanDirtyClothesSortControllerProvider.select((s) => s.phase),
    );
    final settings = ref.watch(cleanDirtyClothesSortSettingsProvider);
    final envPhase = ref.watch(
      cleanDirtyClothesSortControllerProvider.select((s) => s.envPhase),
    );
    final roomGlow = ref.watch(
      cleanDirtyClothesSortControllerProvider.select((s) => s.roomGlow),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && phase != LaundrySortPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: LaundryRoomBackground(
        envPhase: envPhase,
        roomGlow: roomGlow,
        bubbleEffects: settings.bubbleEffects,
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
                        cleanDirtyClothesSortControllerProvider
                            .select((s) => s.remainingSeconds),
                      ),
                      unlimitedTime: settings.unlimitedTime,
                      coinsEarned: ref.watch(
                        cleanDirtyClothesSortControllerProvider
                            .select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        cleanDirtyClothesSortControllerProvider
                            .select((s) => s.starsEarned),
                      ),
                      largerFonts: settings.largerTouchTargets,
                      onPause: _showPauseMenu,
                    ),
                    Expanded(
                      child: ClothesSortBoard(
                        items: ref.watch(
                          cleanDirtyClothesSortControllerProvider
                              .select((s) => s.items),
                        ),
                        targets: ref.watch(
                          cleanDirtyClothesSortControllerProvider
                              .select((s) => s.targets),
                        ),
                        hoverTargetId: ref.watch(
                          cleanDirtyClothesSortControllerProvider
                              .select((s) => s.hoverTargetId),
                        ),
                        showNames: settings.narrationEnabled,
                        largerTouch: settings.largerTouchTargets,
                        leftHanded: settings.leftHandedLayout,
                        onDrop: _onDrop,
                        onHoverTarget: (id) => ref
                            .read(cleanDirtyClothesSortControllerProvider.notifier)
                            .setHoverTarget(id),
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
                    cleanDirtyClothesSortControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    cleanDirtyClothesSortControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    cleanDirtyClothesSortControllerProvider
                        .select((s) => s.showMilestone),
                  ),
                  rewardShadowColor: const Color(0xFF66BB6A),
                ),
                if (phase == LaundrySortPhase.paused)
                  GamePausedOverlay(
                    onResume: () => ref
                        .read(cleanDirtyClothesSortControllerProvider.notifier)
                        .resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (phase == LaundrySortPhase.finished)
                  LaundrySortVictoryOverlay(
                    title: ref
                        .read(cleanDirtyClothesSortControllerProvider.notifier)
                        .getVictoryTitle(),
                    result: ref
                        .read(cleanDirtyClothesSortControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref
                          .read(cleanDirtyClothesSortControllerProvider.notifier)
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
