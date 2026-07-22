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
import 'package:my_tiny_thinker/games/complete_the_word_adventure/controllers/complete_word_controller.dart';
import 'package:my_tiny_thinker/games/complete_the_word_adventure/models/complete_word_models.dart';
import 'package:my_tiny_thinker/games/complete_the_word_adventure/presentation/widgets/complete_word_background.dart';
import 'package:my_tiny_thinker/games/complete_the_word_adventure/presentation/widgets/complete_word_board.dart';
import 'package:my_tiny_thinker/games/complete_the_word_adventure/repository/complete_word_settings_repository.dart';

class CompleteWordGameScreen extends ConsumerStatefulWidget {
  const CompleteWordGameScreen({super.key});

  @override
  ConsumerState<CompleteWordGameScreen> createState() =>
      _CompleteWordGameScreenState();
}

class _CompleteWordGameScreenState extends ConsumerState<CompleteWordGameScreen>
    with WidgetsBindingObserver {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
    ref.listenManual(completeWordControllerProvider, (prev, next) {
      if (next.phase == CompleteWordPhase.finished &&
          prev?.phase != CompleteWordPhase.finished) {
        _onFinished();
      }
      if (next.phase == CompleteWordPhase.celebrating &&
          prev?.phase != CompleteWordPhase.celebrating) {
        ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
        ref.read(hapticServiceProvider).trigger(HapticType.medium);
      }
    });
  }

  Future<void> _start() async {
    _saved = false;
    final settings = ref.read(completeWordSettingsProvider);
    ref.read(completeWordControllerProvider.notifier).reset();
    ref.read(completeWordControllerProvider.notifier).startGame(settings);
    ref.read(audioServiceProvider).playGameMusic();
  }

  Future<void> _onFinished() async {
    if (_saved) return;
    _saved = true;
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    await ref.read(completeWordControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(completeWordControllerProvider.notifier).pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(audioServiceProvider).playHomeMusic();
    super.dispose();
  }

  Future<void> _showPauseMenu() async {
    ref.read(completeWordControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () =>
          ref.read(completeWordControllerProvider.notifier).resume(),
      onRestart: _start,
      onHome: () {
        ref.read(completeWordControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
      onSettings: () async {
        ref.read(completeWordControllerProvider.notifier).pause();
        await context.push(AppRoutes.parentZone);
        if (!mounted) return;
        await _showPauseMenu();
      },
    );
  }

  void _onTapTile(String tileId) {
    final ok = ref.read(completeWordControllerProvider.notifier).tapTile(tileId);
    if (ok) {
      ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
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
      completeWordControllerProvider.select((s) => s.phase),
    );
    final word = ref.watch(
      completeWordControllerProvider.select((s) => s.currentWord),
    );
    final celebrating = phase == CompleteWordPhase.celebrating;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && phase != CompleteWordPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: CompleteWordAdventureBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    GameSessionHud(
                      remainingSeconds: ref.watch(
                        completeWordControllerProvider
                            .select((s) => s.remainingSeconds),
                      ),
                      coinsEarned: ref.watch(
                        completeWordControllerProvider
                            .select((s) => s.coinsEarned),
                      ),
                      starsEarned: ref.watch(
                        completeWordControllerProvider
                            .select((s) => s.starsEarned),
                      ),
                      onPause: _showPauseMenu,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Words ${ref.watch(completeWordControllerProvider.select((s) => s.wordsCompleted))}  ·  '
                        '${ref.watch(completeWordControllerProvider.select((s) => s.settings.wordLength.label))}'
                        '${ref.watch(completeWordControllerProvider.select((s) => s.combo)) > 1 ? '  ·  Combo x${ref.watch(completeWordControllerProvider.select((s) => s.combo))}' : ''}',
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
                        child: phase == CompleteWordPhase.countdown
                            ? Center(
                                child: Text(
                                  '${ref.watch(completeWordControllerProvider.select((s) => s.countdown))}',
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
                            : _PlayArea(
                                wordKey: word?.word ?? '',
                                emoji: word?.emoji ?? '📚',
                                celebrating: celebrating,
                                filled: ref.watch(
                                  completeWordControllerProvider
                                      .select((s) => s.filled),
                                ),
                                nextIndex: ref.watch(
                                  completeWordControllerProvider
                                      .select((s) => s.nextIndex),
                                ),
                                tiles: ref.watch(
                                  completeWordControllerProvider
                                      .select((s) => s.tiles),
                                ),
                                hintTileId: ref.watch(
                                  completeWordControllerProvider
                                      .select((s) => s.hintTileId),
                                ),
                                wrongTileId: ref.watch(
                                  completeWordControllerProvider
                                      .select((s) => s.wrongTileId),
                                ),
                                onTapTile: _onTapTile,
                              ),
                      ),
                    ),
                  ],
                ),
                if (celebrating) const _CelebrationBurst(),
                GameFeedbackOverlay(
                  message: ref.watch(
                    completeWordControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    completeWordControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  rewardShadowColor: AppColors.softPurple,
                ),
                if (phase == CompleteWordPhase.paused)
                  GamePausedOverlay(
                    onResume: () => ref
                        .read(completeWordControllerProvider.notifier)
                        .resume(),
                    onOpenMenu: _showPauseMenu,
                  ),
                if (phase == CompleteWordPhase.finished)
                  CompleteWordVictoryOverlay(
                    result: ref
                        .read(completeWordControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref
                          .read(completeWordControllerProvider.notifier)
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

class _PlayArea extends StatelessWidget {
  const _PlayArea({
    required this.wordKey,
    required this.emoji,
    required this.celebrating,
    required this.filled,
    required this.nextIndex,
    required this.tiles,
    required this.hintTileId,
    required this.wrongTileId,
    required this.onTapTile,
  });

  final String wordKey;
  final String emoji;
  final bool celebrating;
  final List<String> filled;
  final int nextIndex;
  final List<LetterTile> tiles;
  final String? hintTileId;
  final String? wrongTileId;
  final ValueChanged<String> onTapTile;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) {
        final offset = Tween<Offset>(
          begin: const Offset(0.12, 0),
          end: Offset.zero,
        ).animate(anim);
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(position: offset, child: child),
        );
      },
      child: Column(
        key: ValueKey(wordKey),
        children: [
          const Spacer(flex: 1),
          WordIllustrationBanner(emoji: emoji, celebrating: celebrating),
          const SizedBox(height: AppSpacing.lg),
          WordBlankRow(filled: filled, nextIndex: nextIndex),
          const Spacer(flex: 2),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final tile in tiles)
                AlphabetOptionTile(
                  tile: tile,
                  isHint: hintTileId == tile.id,
                  isWrong: wrongTileId == tile.id,
                  onTap: () => onTapTile(tile.id),
                ),
            ],
          ),
          const Spacer(flex: 2),
        ],
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
