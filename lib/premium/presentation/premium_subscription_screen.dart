import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/premium/premium_provider.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';

class PremiumSubscriptionScreen extends ConsumerWidget {
  const PremiumSubscriptionScreen({super.key});

  static const _benefits = [
    ('♾️', 'Unlimited Game Play'),
    ('🎛️', 'Unlimited Parent Control Customization'),
    ('🛤️', 'Unlimited Learning Path Sessions'),
    ('🆕', 'Early Access to New Games'),
    ('⭐', 'Exclusive Premium Learning Games'),
    ('📚', 'New Educational Content Every Month'),
    ('🎁', 'Unlimited Rewards'),
    ('✨', 'Premium Animations'),
    ('🦊', 'Exclusive Characters'),
    ('🚀', 'Priority Feature Updates'),
    ('🔓', 'No Gameplay Restrictions'),
    ('🌈', 'Future Premium Content Included'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    return AnimatedSkyBackground(
      showGrass: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          title: const Text('TinyThink Premium'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            TTCard(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFE082), Color(0xFFFFB74D), Color(0xFFFF8A65)],
              ),
              child: Column(
                children: [
                  const Text('👑', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Unlock the Full TinyThink Experience',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Guide joyful learning with unlimited play, '
                    'custom Parent Controls, and Learning Path adventures.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.95),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (isPremium) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        'You have Premium ✨',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Why Premium?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            ..._benefits.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: TTCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Text(b.$1, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          b.$2,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.mintGreen),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Choose a Plan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            _PlanCard(
              title: '1 Month',
              price: '\$4.99',
              subtitle: 'Flexible monthly learning',
              highlighted: false,
              onBuy: () => _placeholderPurchase(context),
            ),
            const SizedBox(height: AppSpacing.md),
            _PlanCard(
              title: '6 Months',
              price: '\$22.99',
              subtitle: 'Save 23%',
              badge: 'Popular',
              highlighted: false,
              onBuy: () => _placeholderPurchase(context),
            ),
            const SizedBox(height: AppSpacing.md),
            _PlanCard(
              title: '12 Months',
              price: '\$39.99',
              subtitle: 'Best Value · Save 33%',
              badge: 'Best Value',
              highlighted: true,
              onBuy: () => _placeholderPurchase(context),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Payments via Google Play Billing and Apple StoreKit '
              'will connect here in a future release.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.85),
                  ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  void _placeholderPurchase(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Purchase placeholder — billing coming soon!'),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.onBuy,
    this.badge,
    this.highlighted = false,
  });

  final String title;
  final String price;
  final String subtitle;
  final String? badge;
  final bool highlighted;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: AppColors.sunYellow.withValues(alpha: 0.55),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: TTCard(
        gradient: highlighted
            ? const LinearGradient(
                colors: [Color(0xFFFFF59D), Color(0xFFFFCC80), Color(0xFFFFAB91)],
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  price,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.orange,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            TTButton(
              label: 'Subscribe',
              expanded: true,
              onPressed: onBuy,
            ),
          ],
        ),
      ),
    );
  }
}
