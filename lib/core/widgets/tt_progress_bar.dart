import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/tt_badge.dart';

class TTProgressBar extends StatelessWidget {
  const TTProgressBar({
    super.key,
    required this.progress,
    this.height = 12,
    this.label,
    this.showPercentage = false,
    this.gradient,
  });

  final double progress;
  final double height;
  final String? label;
  final bool showPercentage;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label!, style: context.textTheme.labelMedium),
                if (showPercentage)
                  Text(
                    '${(clamped * 100).round()}%',
                    style: context.textTheme.labelSmall,
                  ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                Container(color: AppColors.skyBlueLight.withValues(alpha: 0.3)),
                FractionallySizedBox(
                  widthFactor: clamped,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: gradient ?? AppGradients.rainbow,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusRound),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.skyBlue.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TTAnimatedProgressBar extends StatefulWidget {
  const TTAnimatedProgressBar({
    super.key,
    required this.current,
    required this.total,
    this.height = 14,
  });

  final int current;
  final int total;
  final double height;

  @override
  State<TTAnimatedProgressBar> createState() => _TTAnimatedProgressBarState();
}

class _TTAnimatedProgressBarState extends State<TTAnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: _progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  double get _progress =>
      widget.total > 0 ? widget.current / widget.total : 0;

  @override
  void didUpdateWidget(TTAnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.current != widget.current) {
      _previousProgress = _animation.value;
      _animation = Tween<double>(
        begin: _previousProgress,
        end: _progress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return TTProgressBar(
          progress: _animation.value,
          height: widget.height,
          label: '${widget.current} / ${widget.total}',
        );
      },
    );
  }
}

class TTXPBar extends StatelessWidget {
  const TTXPBar({
    super.key,
    required this.currentXp,
    required this.xpForLevel,
    required this.level,
  });

  final int currentXp;
  final int xpForLevel;
  final int level;

  @override
  Widget build(BuildContext context) {
    final progress = xpForLevel > 0 ? (currentXp % xpForLevel) / xpForLevel : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TTBadge(
              label: 'Lv. $level',
              color: AppColors.lavender,
            ),
            const Spacer(),
            Text(
              '$currentXp XP',
              style: context.textTheme.labelSmall,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        TTProgressBar(
          progress: progress,
          height: 8,
          gradient: AppGradients.bubblePurple,
        ),
      ],
    );
  }
}
