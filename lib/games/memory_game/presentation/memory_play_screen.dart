import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/ascending_descending/presentation/widgets/game_hud_widgets.dart';
import 'package:my_tiny_thinker/games/memory_game/controllers/memory_session_controller.dart';
import 'package:my_tiny_thinker/games/memory_game/logic/memory_game_logic.dart';
import 'package:my_tiny_thinker/games/memory_game/models/memory_models.dart';
import 'package:my_tiny_thinker/games/memory_game/presentation/widgets/animated_toy_room_background.dart';
import 'package:my_tiny_thinker/games/memory_game/presentation/widgets/memory_hud.dart';
import 'package:my_tiny_thinker/games/memory_game/presentation/widgets/memory_mini_game_views.dart';

class MemoryPlayScreen extends ConsumerStatefulWidget {
  const MemoryPlayScreen({super.key, this.initialConfig});

  final MemoryGameConfig? initialConfig;

  @override
  ConsumerState<MemoryPlayScreen> createState() => _MemoryPlayScreenState();
}

class _MemoryPlayScreenState extends ConsumerState<MemoryPlayScreen>
    with WidgetsBindingObserver {
  bool _resultShown = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  void _init() {
    if (_initialized) return;
    _initialized = true;
    final config = widget.initialConfig ??
        (GoRouterState.of(context).extra as MemoryGameConfig?);
    if (config != null) {
      ref.read(memorySessionProvider.notifier).initSession(config);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(memorySessionProvider.notifier).pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<bool> _onPause() async {
    ref.read(memorySessionProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () => ref.read(memorySessionProvider.notifier).resume(),
      onRestart: () {
        _resultShown = false;
        final config = ref.read(memorySessionProvider).config;
        if (config != null) {
          ref.read(memorySessionProvider.notifier).reset();
          ref.read(memorySessionProvider.notifier).initSession(config);
        }
      },
      onHome: () {
        ref.read(memorySessionProvider.notifier).reset();
        context.go(AppRoutes.memoryHub);
      },
    );
    return false;
  }

  void _checkEnd(MemorySessionState state) {
    if (_resultShown) return;
    if (state.phase != MemoryPhase.victory &&
        state.phase != MemoryPhase.gameOver) {
      return;
    }
    _resultShown = true;
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    ref.read(hapticServiceProvider).trigger(HapticType.heavy);

    final controller = ref.read(memorySessionProvider.notifier);
    controller.saveResult();

    MemoryVictoryDialog.show(
      context,
      result: controller.getResult(),
      onPlayAgain: () {
        _resultShown = false;
        final config = state.config;
        if (config != null) {
          ref.read(memorySessionProvider.notifier).reset();
          ref.read(memorySessionProvider.notifier).initSession(config);
        }
      },
      onHome: () {
        ref.read(memorySessionProvider.notifier).reset();
        context.go(AppRoutes.memoryHub);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memorySessionProvider);
    final config = state.config;

    ref.listen(memorySessionProvider, (_, next) => _checkEnd(next));

    if (config == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final totalRounds = MemoryDifficultyConfig.roundsToWin(config.difficulty);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _onPause();
      },
      child: AnimatedToyRoomBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.pause_rounded),
              onPressed: _onPause,
            ),
            title: Text('${config.gameType.emoji} ${config.gameType.displayName}'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Center(
                  child: Text(
                    MemoryDifficultyConfig.label(config.difficulty),
                    style: context.textTheme.labelMedium,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  MemoryHud(
                    score: state.score,
                    round: state.round,
                    totalRounds: totalRounds,
                    combo: state.combo,
                    feedback: state.feedbackMessage,
                    isCorrect: state.isCorrectFeedback,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: MemoryMiniGameView(
                      state: state,
                      controller: ref.read(memorySessionProvider.notifier),
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
}
