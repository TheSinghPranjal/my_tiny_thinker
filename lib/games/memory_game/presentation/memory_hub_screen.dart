import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/responsive_layout.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/memory_game/controllers/memory_session_controller.dart';
import 'package:my_tiny_thinker/games/memory_game/models/memory_models.dart';
import 'package:my_tiny_thinker/core/widgets/setup_meadow_background.dart';
import 'package:my_tiny_thinker/games/memory_game/presentation/widgets/memory_game_widgets.dart';
import 'package:my_tiny_thinker/games/memory_game/presentation/widgets/memory_hud.dart';
import 'package:my_tiny_thinker/games/memory_game/presentation/widgets/memory_statistics_panel.dart';

class MemoryHubScreen extends ConsumerWidget {
  const MemoryHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(memoryHubStatsProvider);
    final profile = ref.watch(profileProvider);

    return SetupMeadowBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ResponsivePadding(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.sm,
                      bottom: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        _CircleIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => context.pop(),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            '🧠 Memory Games',
                            style: context.textTheme.headlineLarge,
                          ),
                        ),
                        _CircleIconButton(
                          icon: Icons.bar_chart_rounded,
                          onTap: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => MemoryStatisticsPanel(stats: stats),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: TTCard(
                    child: Row(
                      children: [
                        const MascotWidget(size: 64, waving: true),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Memory Toy Room!',
                                style: context.textTheme.headlineMedium,
                              ),
                              Text(
                                'Pick a memory challenge!',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
                const SliverToBoxAdapter(
                  child: TTCard(
                    child: SkillsDevelopedSection(
                      skills: [
                        'Memory',
                        'Concentration',
                        'Visual Recall',
                        'Attention',
                        'Problem Solving',
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
                SliverToBoxAdapter(
                  child: ResponsiveGrid(
                    itemCount: MemoryMiniGameType.hubGames.length,
                    phoneColumns: 2,
                    tabletColumns: 3,
                    childAspectRatio: 0.82,
                    itemBuilder: (context, index) {
                      final type = MemoryMiniGameType.hubGames[index];
                      final miniStats = stats.statsFor(type);
                      final locked = !miniStats.isUnlocked;

                      return MemoryMiniGameCard(
                        gameType: type,
                        stats: miniStats,
                        isLocked: locked,
                        onPlay: () => _openSetup(context, ref, type),
                        onUnlock: () => _unlockGame(context, ref, type, profile.coins),
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openSetup(BuildContext context, WidgetRef ref, MemoryMiniGameType type) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (sheetContext) {
        var config = MemoryGameConfig(gameType: type);
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return MemorySetupSheet(
              gameType: type,
              config: config,
              onConfigChanged: (c) => setSheetState(() => config = c),
              onStart: () async {
                if (!await ensureCanStartGame(
                  context,
                  ref,
                  GameId.memoryGame,
                )) {
                  return;
                }
                if (!context.mounted) return;
                Navigator.pop(sheetContext);
                ref.read(memorySessionProvider.notifier).reset();
                context.push(AppRoutes.memoryPlay, extra: config);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _unlockGame(
    BuildContext context,
    WidgetRef ref,
    MemoryMiniGameType type,
    int coins,
  ) async {
    if (type.unlockCost == 0) return;
    if (coins < type.unlockCost) {
      await TTDialog.show(
        context: context,
        title: 'Not Enough Coins',
        emoji: '🪙',
        message: 'You need ${type.unlockCost} coins to unlock this game.',
        primaryLabel: 'OK',
      );
      return;
    }
    final ok = await ref.read(memoryHubStatsProvider.notifier).unlockGame(
          type,
          coins,
        );
    if (ok && context.mounted) {
      await ref.read(profileProvider.notifier).addCoins(-type.unlockCost);
      if (context.mounted) _openSetup(context, ref, type);
    }
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 24, color: const Color(0xFF455A64)),
        ),
      ),
    );
  }
}
