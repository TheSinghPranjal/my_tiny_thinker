import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({
    super.key,
    required this.onComplete,
    this.messages = const [
      'Counting bubbles...',
      'Finding rainbows...',
      'Warming up your brain...',
      'Getting games ready...',
    ],
  });

  final VoidCallback onComplete;
  final List<String> messages;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _runController;
  int _messageIndex = 0;
  double _progress = 0;
  Timer? _messageTimer;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _runController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _messageTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % widget.messages.length;
        });
      }
    });

    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      setState(() => _progress = math.min(_progress + 0.02, 1.0));
      if (_progress >= 1.0) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 300), widget.onComplete);
      }
    });
  }

  @override
  void dispose() {
    _runController.dispose();
    _messageTimer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSkyBackground(
      showGrass: false,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _runController,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(_runController.value * 20 - 10, 0),
                  child: const MascotWidget(size: 120, waving: true),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'TinyThink',
              style: context.textTheme.displayMedium?.copyWith(
                color: AppColors.white,
                shadows: const [
                  Shadow(color: AppColors.skyBlueDark, blurRadius: 8),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 10,
                  backgroundColor: AppColors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation(AppColors.sunYellow),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                widget.messages[_messageIndex],
                key: ValueKey(_messageIndex),
                style: context.textTheme.bodyLarge?.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
