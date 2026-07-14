import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_feedback_banner.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/controllers/ocean_fish_controller.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/models/ocean_fish_models.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/presentation/widgets/fish_widget.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/presentation/widgets/ocean_background.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/presentation/widgets/ocean_hud.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/repository/ocean_fish_settings_repository.dart';

class OceanFishGameScreen extends ConsumerStatefulWidget {
  const OceanFishGameScreen({super.key});

  @override
  ConsumerState<OceanFishGameScreen> createState() =>
      _OceanFishGameScreenState();
}

class _OceanFishGameScreenState extends ConsumerState<OceanFishGameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Ticker? _ticker;
  final _particleKey = GlobalKey<ParticleSystemState>();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());

    ref.listenManual(oceanFishControllerProvider, (prev, next) {
      _syncTicker(next.phase);
      if (next.phase == OceanFishPhase.finished && !_saved) {
        _onFinished();
      }
    });
  }

  void _start() {
    _saved = false;
    final settings = ref.read(oceanFishSettingsProvider);
    ref.read(oceanFishControllerProvider.notifier).reset();
    ref.read(oceanFishControllerProvider.notifier).startGame(settings);
    ref.read(audioServiceProvider).playMusic(asset: 'audio/ambient_music.mp3');
    _syncTicker(OceanFishPhase.playing);
  }

  void _syncTicker(OceanFishPhase phase) {
    if (phase == OceanFishPhase.playing) {
      _ticker ??= createTicker((_) {
        ref.read(oceanFishControllerProvider.notifier).tick(1 / 60);
      });
      if (!_ticker!.isActive) _ticker!.start();
    } else {
      _ticker?.stop();
    }
  }

  Future<void> _onFinished() async {
    _saved = true;
    _ticker?.stop();
    ref.read(audioServiceProvider).playSfx(SoundEffect.victory);
    await ref.read(oceanFishControllerProvider.notifier).saveResult();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(oceanFishControllerProvider.notifier).pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.dispose();
    ref.read(audioServiceProvider).stopMusic();
    super.dispose();
  }

  Future<void> _showPauseMenu() async {
    ref.read(oceanFishControllerProvider.notifier).pause();
    await TTPauseDialog.show(
      context,
      onResume: () => ref.read(oceanFishControllerProvider.notifier).resume(),
      onRestart: () => _start(),
      onHome: () {
        ref.read(oceanFishControllerProvider.notifier).reset();
        context.go(AppRoutes.home);
      },
    );
  }

  void _onTapFish(String id, FishEntity fish) {
    final ok = ref.read(oceanFishControllerProvider.notifier).tapFish(id);
    if (!ok) return;
    ref.read(audioServiceProvider).playSfx(SoundEffect.bubblePop);
    ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
    ref.read(hapticServiceProvider).trigger(HapticType.light);
    _particleKey.currentState?.emit(origin: Offset(fish.x, fish.y));
    ref.read(audioServiceProvider).playSfx(SoundEffect.coin);
  }

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(
      oceanFishControllerProvider.select((s) => s.phase),
    );
    final settings = ref.watch(oceanFishSettingsProvider);
    final highContrast = ref.watch(settingsProvider.select((s) => s.highContrast));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && phase != OceanFishPhase.finished) {
          await _showPauseMenu();
        }
      },
      child: OceanBackground(
        bubbleDensity: settings.bubbleDensity,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    OceanFishHud(
                      remainingSeconds: ref.watch(
                        oceanFishControllerProvider
                            .select((s) => s.remainingSeconds),
                      ),
                      fishTapped: ref.watch(
                        oceanFishControllerProvider
                            .select((s) => s.fishTapped),
                      ),
                      coinsEarned: ref.watch(
                        oceanFishControllerProvider
                            .select((s) => s.coinsEarned),
                      ),
                      onPause: _showPauseMenu,
                    ),
                    Expanded(
                      child: _FishPlayArea(
                        particleKey: _particleKey,
                        highContrast: highContrast,
                        onTap: _onTapFish,
                      ),
                    ),
                  ],
                ),
                GameFeedbackOverlay(
                  message: ref.watch(
                    oceanFishControllerProvider
                        .select((s) => s.feedbackMessage),
                  ),
                  rewardText: ref.watch(
                    oceanFishControllerProvider
                        .select((s) => s.lastRewardText),
                  ),
                  showMascot: ref.watch(
                    oceanFishControllerProvider
                        .select((s) => s.showMascotCelebrate),
                  ),
                  rewardShadowColor: AppColors.skyBlueDark,
                ),
                if (phase == OceanFishPhase.paused)
                  const _PausedOverlay(),
                if (phase == OceanFishPhase.finished)
                  OceanVictoryOverlay(
                    result: ref
                        .read(oceanFishControllerProvider.notifier)
                        .getResult(),
                    onPlayAgain: _start,
                    onHome: () {
                      ref.read(oceanFishControllerProvider.notifier).reset();
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
        color: const Color(0xFF01579B).withValues(alpha: 0.55),
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

class _FishPlayArea extends ConsumerWidget {
  const _FishPlayArea({
    required this.particleKey,
    required this.highContrast,
    required this.onTap,
  });

  final GlobalKey<ParticleSystemState> particleKey;
  final bool highContrast;
  final void Function(String id, FishEntity fish) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fish = ref.watch(
      oceanFishControllerProvider.select((s) => s.fish),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(oceanFishControllerProvider.notifier).setPlayArea(
                Size(constraints.maxWidth, constraints.maxHeight),
              );
        });

        return ClipRect(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              ...fish.map(
                (f) => FishWidget(
                  key: ValueKey(f.id),
                  fish: f,
                  highContrast: highContrast,
                  onTap: () => onTap(f.id, f),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: ParticleSystem(
                    key: particleKey,
                    particleCount: 28,
                    autoStart: false,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
