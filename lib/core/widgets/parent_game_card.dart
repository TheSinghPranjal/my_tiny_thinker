import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/game_config/game_catalog.dart';
import 'package:my_tiny_thinker/core/game_config/game_duration.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

/// Collapsible Parent Control card for a single game.
class ParentGameCard extends StatefulWidget {
  const ParentGameCard({
    super.key,
    required this.entry,
    required this.durationSeconds,
    required this.inLearningPath,
    required this.playsLabel,
    required this.isPremium,
    required this.expandedChild,
    this.accent,
  });

  final GameCatalogEntry entry;
  final int durationSeconds;
  final bool inLearningPath;
  final String playsLabel;
  final bool isPremium;
  final Widget expandedChild;
  final Color? accent;

  @override
  State<ParentGameCard> createState() => _ParentGameCardState();
}

class _ParentGameCardState extends State<ParentGameCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent ?? AppColors.skyBlue;
    final game = widget.entry.gameId;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(accent, Colors.white, 0.88)!,
            Color.lerp(accent, Colors.white, 0.94)!,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: accent.withValues(alpha: 0.28), width: 1.5),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accent, Color.lerp(accent, AppColors.orange, 0.4)!],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(game.emoji, style: const TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.displayName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.entry.category.label,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _Chip(
                              icon: Icons.timer_outlined,
                              label: GameDuration.label(widget.durationSeconds),
                              color: accent,
                            ),
                            _Chip(
                              icon: widget.inLearningPath
                                  ? Icons.route_rounded
                                  : Icons.route_outlined,
                              label: widget.inLearningPath ? 'In Path' : 'Off Path',
                              color: widget.inLearningPath
                                  ? AppColors.grassGreen
                                  : AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(Icons.expand_more_rounded, color: accent),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnim,
            axisAlignment: -1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(color: accent.withValues(alpha: 0.2)),
                  Text(
                    widget.playsLabel,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  if (!widget.isPremium) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.softPurple.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(
                          color: AppColors.softPurple.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock_rounded, size: 18, color: AppColors.softPurple),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Available with TinyThink Premium',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.softPurple,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  IgnorePointer(
                    ignoring: !widget.isPremium,
                    child: Opacity(
                      opacity: widget.isPremium ? 1 : 0.72,
                      child: widget.expandedChild,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
