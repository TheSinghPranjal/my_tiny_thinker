import 'dart:ui';

/// Maps play-area coordinates to the visible water region in [DuckPondBackground].
///
/// The background paints water from 28%–72% of the full screen, but fish and the
/// duck are positioned inside the play area below the HUD. These helpers estimate
/// that offset so entities stay in the water, not on the grass.
abstract final class PondBounds {
  static const _fullWaterTop = 0.28;
  static const _fullWaterBottom = 0.68;
  static const _hudHeightRatio = 0.11;
  static const _horizontalMargin = 50.0;

  static double _estimatedTotalHeight(Size playArea) =>
      playArea.height / (1 - _hudHeightRatio);

  static double _estimatedHudHeight(Size playArea) =>
      _estimatedTotalHeight(playArea) * _hudHeightRatio;

  static double waterTop(Size playArea) {
    final total = _estimatedTotalHeight(playArea);
    final hud = _estimatedHudHeight(playArea);
    return (total * _fullWaterTop - hud).clamp(8.0, playArea.height * 0.35);
  }

  static double waterBottom(Size playArea) {
    final total = _estimatedTotalHeight(playArea);
    final hud = _estimatedHudHeight(playArea);
    return (total * _fullWaterBottom - hud).clamp(
      playArea.height * 0.35,
      playArea.height * 0.62,
    );
  }

  static double clampY(Size playArea, double y) =>
      y.clamp(waterTop(playArea) + 12, waterBottom(playArea) - 12);

  static double clampX(Size playArea, double x) =>
      x.clamp(_horizontalMargin, playArea.width - _horizontalMargin);

  static (double, double) clampPoint(Size playArea, double x, double y) =>
      (clampX(playArea, x), clampY(playArea, y));

  /// Normalized 0–1 depth within the water column (for shading).
  static double depthFactor(Size playArea, double y) {
    final top = waterTop(playArea);
    final bottom = waterBottom(playArea);
    if (bottom <= top) return 0.5;
    return ((y - top) / (bottom - top)).clamp(0.0, 1.0);
  }
}
