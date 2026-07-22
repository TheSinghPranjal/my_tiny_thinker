import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/learning_path/learning_path_flow.dart';
import 'package:my_tiny_thinker/core/widgets/game_session_hud.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/rewards/reward_engine.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/widgets/game_feedback_banner.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/core/widgets/game_paused_overlay.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/controllers/alphabet_bridge_controller.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/logic/alphabet_bridge_logic.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/models/alphabet_bridge_models.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/presentation/widgets/alphabet_bridge_board.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/presentation/widgets/alphabet_garden_background.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/repository/alphabet_bridge_settings_repository.dart';

class AlphabetBridgeGameScreen extends ConsumerStatefulWidget {
  const AlphabetBridgeGameScreen({super.key});

  @override
  ConsumerState<AlphabetBridgeGameScreen> createState() =>
      _AlphabetBridgeGameScreenState();
}

class _AlphabetBridgeGameScreenState
    extends ConsumerState<AlphabetBridgeGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _particleKey = GlobalKey<ParticleSystemState>();
  Ticker? _ticker;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(alphabetBridgeControllerProvider, (prev, next) {
      if (next.phase == AlphabetBridgePhase.finished && !_saved) {
        _onFinished();
      }
      if (next.showSparkles &&
          (next.phase == AlphabetBridgePhase.celebrating ||
              next.showRoundBonus)) {
        _particleKey.currentState?.emit();
      }
    });
  }

  Future<void> _start() async {
    if (!await ensureCanStartGame(
      context,
      ref,
      GameId.alphabetBridgeAdventure,
    )) {
      return;
    }
    if (!mounted) return;
    _saved = false;
    final settings = ref.read(alphabetBridgeSettingsProvider);
    ref.read(alphabetBridgeControllerProvider.notifier).reset();
    ref.read(alphabetBridgeControllerProvider.notifier).startGame(settings);
    if (settings.musicEnabled) {
      ref.read(audioServiceProvider).playGameMusic();
    }
    _ticker ??= createTicker((_) {
      ref.read(alphabetBridgeControllerProvider.notifier).tick(1 / 60);
    });
    if (!_ticker!.isActive) _ticker!.start();
  }

  Future<void> _onFinished() async {
    if (_saved) return;
    _saved = true;
    _ticker?.stop();
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    final ctrl = ref.read(alphabetBridgeControllerProvider.notifier);
    await ctrl.saveResult();
    final result = ctrl.getResult();
    final reward = AlphabetBridgeLogic.toReward(result);
    final engine = ref.read(rewardEngineProvider);
    final summary = SessionRewardSummary(
      gameId: GameId.alphabetBridgeAdventure,
      message: engine.pickCelebrationMessage(),
      coins: reward.coins,
      xp: reward.xp,
      stars: reward.stars,
      achievementPoints: reward.isPerfect ? 25 : 10,
      bonusCoins: reward.isPerfect ? 8 : 0,
      totalScore: result.score,
      isPerfect: reward.isPerfect,
      isNewBest: reward.isNewBest,
    );
    if (!mounted) return;
    final settings = ref.read(alphabetBridgeSettingsProvider);
    await finishGameSession(
      context,
      ref,
      summary: summary,
      playSeconds: settings.sessionSeconds,
      onPlayAgain: _start,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(alphabetBridgeControllerProvider.notifier).pause();
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
    ref.read(alphabetBridgeControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () =>
          ref.read(alphabetBridgeControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () async {
        final ctrl = ref.read(alphabetBridgeControllerProvider.notifier);
        await ctrl.saveResult();
        ctrl.reset();
        if (!mounted) return;
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(alphabetBridgeControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onConnect({required String lowerId, required String upperId}) {
    final settings = ref.read(alphabetBridgeSettingsProvider);
    final ok = ref.read(alphabetBridgeControllerProvider.notifier).tryConnect(
          lowerId: lowerId,
          upperId: upperId,
        );

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
        ref.read(audioServiceProvider).playSfx(SoundEffect.coin);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase =
        ref.watch(alphabetBridgeControllerProvider.select((s) => s.phase));
    final settings = ref.watch(alphabetBridgeSettingsProvider);
    final envPhase =
        ref.watch(alphabetBridgeControllerProvider.select((s) => s.envPhase));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && phase != AlphabetBridgePhase.finished) {
          await _showPauseMenu();
        }
      },
      child: AlphabetGardenBackground(
        envPhase: envPhase,
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
                        alphabetBridgeControllerProvider.select((s) => s.remainingSeconds),
                      ),
                      unlimitedTime: settings.unlimitedTime,
                      coinsEarned: ref.watch(
                        alphabetBridgeControllerProvider.select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        alphabetBridgeControllerProvider.select((s) => s.starsEarned),
                      ),
                      largerFonts: settings.largerTouchTargets,
                      onPause: _showPauseMenu,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'little letters',
                            style: TextStyle(
                              color: const Color(0xFF4527A0).withValues(alpha: 0.85),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'BIG LETTERS',
                            style: TextStyle(
                              color: const Color(0xFF4527A0).withValues(alpha: 0.85),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: AlphabetBridgeBoard(
                        lowerCards: ref.watch(
                          alphabetBridgeControllerProvider
                              .select((s) => s.lowerCards),
                        ),
                        upperCards: ref.watch(
                          alphabetBridgeControllerProvider
                              .select((s) => s.upperCards),
                        ),
                        connections: ref.watch(
                          alphabetBridgeControllerProvider
                              .select((s) => s.connections),
                        ),
                        largerTouch: settings.largerTouchTargets,
                        onConnect: _onConnect,
                      ),
                    ),
                  ],
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: ParticleSystem(
                      key: _particleKey,
                      particleCount: 44,
                      autoStart: false,
                    ),
                  ),
                ),
                GameFeedbackOverlay(
                  message: ref.watch(
                    alphabetBridgeControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    alphabetBridgeControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    alphabetBridgeControllerProvider
                        .select((s) => s.showMascot),
                  ),
                  rewardShadowColor: const Color(0xFF7E57C2),
                ),
                if (phase == AlphabetBridgePhase.paused)
                  GamePausedOverlay(
                    onResume: () => ref.read(alphabetBridgeControllerProvider.notifier).resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

