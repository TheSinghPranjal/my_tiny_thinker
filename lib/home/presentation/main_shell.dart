import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/tt_badge.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    (AppRoutes.home, Icons.home_rounded, 'Home'),
    (AppRoutes.games, Icons.sports_esports_rounded, 'Games'),
    (AppRoutes.rewards, Icons.emoji_events_rounded, 'Rewards'),
    (AppRoutes.profile, Icons.face_rounded, 'Profile'),
    (AppRoutes.parents, Icons.family_restroom_rounded, 'Parents'),
  ];

  int _currentIndex(String location) {
    for (var i = 0; i < _destinations.length; i++) {
      if (location.startsWith(_destinations[i].$1)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _currentIndex(location);
    final profile = ref.watch(profileProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.skyBlue.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLg),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: AppSpacing.bottomNavHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_destinations.length, (index) {
                final (route, icon, label) = _destinations[index];
                final selected = index == currentIndex;
                return _NavItem(
                  icon: icon,
                  label: label,
                  selected: selected,
                  badge: index == 2 && profile.stars > 0
                      ? '${profile.stars}'
                      : null,
                  onTap: () {
                    ref.read(audioServiceProvider).playHomeMusic();
                    context.go(route);
                  },
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    if (widget.selected) _controller.value = 1;
  }

  @override
  void didUpdateWidget(_NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
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
    final color = widget.selected ? AppColors.skyBlueDark : AppColors.textSecondary;
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 1, end: 1.2).animate(
                CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(widget.icon, color: color, size: AppSpacing.iconMd),
                  if (widget.badge != null)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: TTBadge(
                        label: widget.badge!,
                        color: AppColors.sunYellow,
                        textColor: AppColors.textPrimary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              widget.label,
              style: context.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
