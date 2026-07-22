import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/responsive_layout.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/memory_game/controllers/memory_session_controller.dart';
import 'package:my_tiny_thinker/games/memory_game/models/memory_models.dart';
import 'package:my_tiny_thinker/games/memory_game/presentation/widgets/animated_toy_room_background.dart';
import 'package:my_tiny_thinker/games/memory_game/presentation/widgets/memory_game_widgets.dart';
import 'package:my_tiny_thinker/games/memory_game/presentation/widgets/memory_hud.dart';
import 'package:my_tiny_thinker/games/memory_game/presentation/widgets/memory_statistics_panel.dart';

class MemoryHubScreen extends ConsumerWidget {
  const MemoryHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(memoryHubStatsProvider);
    final profile = ref.watch(profileProvider);

    return AnimatedToyRoomBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          title: const Text('🧠 Memory Games'),
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded),
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => MemoryStatisticsPanel(stats: stats),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: ResponsivePadding(
            child: CustomScrollView(
              slivers: [
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
              onStart: () {
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
