import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/providers/onboarding_provider.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/widgets/loading_screen.dart';

class AppLoadingGate extends ConsumerWidget {
  const AppLoadingGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LoadingScreen(
      onComplete: () {
        final complete = ref.read(onboardingProvider).isComplete;
        context.go(complete ? AppRoutes.home : AppRoutes.welcome);
      },
    );
  }
}
