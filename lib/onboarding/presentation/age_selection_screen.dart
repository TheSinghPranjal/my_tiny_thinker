import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/models/age_group.dart';
import 'package:my_tiny_thinker/core/providers/onboarding_provider.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';

class AgeSelectionScreen extends ConsumerStatefulWidget {
  const AgeSelectionScreen({super.key});

  @override
  ConsumerState<AgeSelectionScreen> createState() =>
      _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends ConsumerState<AgeSelectionScreen> {
  AgeGroup? _selected;

  static const _colors = {
    AgeGroup.littleExplorers: AppColors.sunYellow,
    AgeGroup.tinyLearners: AppColors.mintGreen,
    AgeGroup.smartExplorers: AppColors.skyBlue,
    AgeGroup.brainMasters: AppColors.softPurple,
    AgeGroup.youngGeniuses: AppColors.orange,
  };

  Future<void> _select(AgeGroup group) async {
    setState(() => _selected = group);
    ref.read(hapticServiceProvider).trigger(HapticType.success);
    ref.read(audioServiceProvider).playSfx(SoundEffect.correct);
    await ref.read(onboardingProvider.notifier).selectAgeGroup(group);
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    context.go(AppRoutes.avatarSelection);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSkyBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Text(
                    'How old are you?',
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: AppColors.white,
                      shadows: const [
                        Shadow(color: AppColors.skyBlueDark, blurRadius: 4),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const MascotWidget(size: 64, waving: true),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: AgeGroup.values.length,
                itemBuilder: (context, index) {
                  final group = AgeGroup.values[index];
                  final color = _colors[group]!;
                  final isSelected = _selected == group;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: GestureDetector(
                      onTap: () => _select(group),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutBack,
                        transform: Matrix4.identity()
                          ..scaleByDouble(
                            isSelected ? 1.03 : 1.0,
                            isSelected ? 1.03 : 1.0,
                            isSelected ? 1.03 : 1.0,
                            1.0,
                          ),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.92),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusXl),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: isSelected ? 16 : 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: isSelected
                              ? Border.all(color: AppColors.white, width: 3)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Text(group.emoji,
                                style: const TextStyle(fontSize: 40)),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    group.title,
                                    style: context.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    group.ageRange,
                                    style: context.textTheme.titleMedium,
                                  ),
                                  Text(
                                    group.description,
                                    style: context.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Text('✨',
                                  style: TextStyle(fontSize: 28)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
