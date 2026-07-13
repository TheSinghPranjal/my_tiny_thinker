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
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';

class AvatarSelectionScreen extends ConsumerStatefulWidget {
  const AvatarSelectionScreen({super.key});

  @override
  ConsumerState<AvatarSelectionScreen> createState() =>
      _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends ConsumerState<AvatarSelectionScreen> {
  String? _selected;

  Future<void> _finish() async {
    if (_selected != null) {
      await ref.read(onboardingProvider.notifier).selectAvatar(_selected!);
    }
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSkyBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Text(
                'Choose Your Buddy',
                style: context.textTheme.headlineMedium?.copyWith(
                  color: AppColors.white,
                  shadows: const [
                    Shadow(color: AppColors.skyBlueDark, blurRadius: 4),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  itemCount: kAvatars.length,
                  itemBuilder: (context, index) {
                    final (id, emoji, name) = kAvatars[index];
                    final isSelected = _selected == id;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selected = id);
                        ref.read(hapticServiceProvider).trigger(HapticType.light);
                        ref.read(audioServiceProvider).playSfx(SoundEffect.buttonTap);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.sunYellow
                              : AppColors.white.withValues(alpha: 0.9),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLg),
                          border: isSelected
                              ? Border.all(color: AppColors.orange, width: 3)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.skyBlue.withValues(alpha: 0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 40)),
                            Text(name, style: context.textTheme.labelMedium),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              TTButton(
                label: _selected == null ? 'Skip for Now' : 'Continue!',
                expanded: true,
                size: TTButtonSize.large,
                onPressed: _finish,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
