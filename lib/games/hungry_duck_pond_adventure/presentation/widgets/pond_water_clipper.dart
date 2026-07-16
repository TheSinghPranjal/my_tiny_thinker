import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/logic/pond_bounds.dart';

/// Clips game entities to the visible water band so nothing renders on the grass.
class PondWaterClipper extends CustomClipper<Rect> {
  PondWaterClipper({required this.playAreaSize});

  final Size playAreaSize;

  @override
  Rect getClip(Size size) {
    // Extra top room so the duck's head can sit above the water line.
    final top = PondBounds.waterTop(playAreaSize) - 46;
    final bottom = PondBounds.waterBottom(playAreaSize) + 20;
    return Rect.fromLTRB(0, top, playAreaSize.width, bottom);
  }

  @override
  bool shouldReclip(covariant PondWaterClipper oldClipper) =>
      oldClipper.playAreaSize != playAreaSize;
}
