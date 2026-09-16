import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_tiny_thinker/core/animations/bounce_animation.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/setup_meadow_background.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
import 'package:my_tiny_thinker/games/color_memory/controllers/color_memory_controller.dart';
import 'package:my_tiny_thinker/games/color_memory/models/color_memory_models.dart';

class ColorMemorySetupScreen extends ConsumerWidget {
  const ColorMemorySetupScreen({super.key});

  static const _navy = Color(0xFF3E4A59);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var config = ref.watch(colorMemoryConfigProvider);
    final hints = ref.watch(settingsProvider).hintsEnabled;

    return SetupMeadowBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 3,
                    shadowColor: Colors.black26,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => context.pop(),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 26,
                          color: Color(0xFF455A64),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            const Text('🌈', style: TextStyle(fontSize: 56)),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Color Memory',
                              style: GoogleFonts.fredoka(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: _navy,
                                shadows: const [
                                  Shadow(color: Colors.white, blurRadius: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TTCard(
                        gradient: AppGradients.welcomeCard,
                        child: Row(
                          children: [
                            const Text('👀', style: TextStyle(fontSize: 28)),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Watch the colors glow, then repeat the sequence!',
                                style: context.textTheme.titleMedium?.copyWith(
                                  color: _navy,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _SectionLabel('Difficulty'),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final d in ColorMemoryDifficulty.values)
                            _OptionPill(
                              label: d.name.capitalize,
                              selected: config.difficulty == d,
                              gradient: AppGradients.bubbleBlue,
                              onTap: () {
                                config = config.copyWith(difficulty: d);
                                ref
                                    .read(colorMemoryConfigProvider.notifier)
                                    .state = config;
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _SectionLabel('Color Theme'),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final t in ColorMemoryTheme.values)
                            _OptionPill(
                              label: '${t.tiles.first} ${t.label}',
                              selected: config.theme == t,
                              gradient: AppGradients.bubblePink,
                              onTap: () {
                                config = config.copyWith(theme: t);
                                ref
                                    .read(colorMemoryConfigProvider.notifier)
                                    .state = config;
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      TTButton(
                        label: 'Start Game!',
                        expanded: true,
                        size: TTButtonSize.large,
                        onPressed: () async {
                          if (!await ensureCanStartGame(
                            context,
                            ref,
                            GameId.colorMemory,
                          )) {
                            return;
                          }
                          if (!context.mounted) return;
                          ref.read(colorMemoryConfigProvider.notifier).state =
                              config.copyWith(hintsEnabled: hints);
                          context.push(AppRoutes.colorMemoryGame);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: ColorMemorySetupScreen._navy,
      ),
    );
  }
}

class _OptionPill extends StatelessWidget {
  const _OptionPill({
    required this.label,
    required this.selected,
    required this.gradient,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BounceTapWrapper(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? gradient : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
          border: Border.all(
            color: selected ? Colors.white : AppColors.skyBlue.withValues(alpha: 0.35),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (selected ? AppColors.skyBlueDark : Colors.black)
                  .withValues(alpha: selected ? 0.28 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : ColorMemorySetupScreen._navy,
          ),
        ),
      ),
    );
  }
}
