import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';

void navigateToGame(BuildContext context, GameId gameId) {
  switch (gameId) {
    case GameId.bubbleNumberPop:
      context.push(AppRoutes.bubbleSetup);
    case GameId.memoryGame:
      context.push(AppRoutes.memoryHub);
    case GameId.oddOneOut:
    case GameId.patternMatch:
    case GameId.colorMemory:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon!')),
      );
  }
}
