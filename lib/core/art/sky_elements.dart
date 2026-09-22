import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Colors reused by the hand-drawn sun/cloud art (see below) and by several
/// character painters (blush cheeks, ink eyes, gold sparkles). Kept in one
/// place instead of being redefined as local hex literals in every file.
abstract final class SharedArtColors {
  /// Warm dark brown used for eyes/mouths on suns and some characters.
  static const ink = Color(0xFF6D4C41);

  /// Soft pink blush used on cheeks.
  static const blush = Color(0xFFFF8A80);

  /// Golden sparkle/highlight accent (dashes, stars).
  static const sparkle = Color(0xFFFFD84A);

  /// The sun's solid disc color.
  static const sunCore = Color(0xFFFFEE58);

  /// The sun's ray color.
  static const sunRay = Color(0xFFFFF176);

  /// Pale blue used for the shaded underside of a puffy cloud.
  static const cloudShade = Color(0xFFC9E3F5);
}

/// Draws a friendly smiling sun: soft outer glow, rays, a solid disc, a
/// highlight, a face (closed happy eyes and a smile) and blush cheeks.
///
/// [center] and [radius] (the disc's radius) are the only required inputs;
/// every other feature is sized proportionally to [radius] so the same
/// sun looks right at any scale. This replaces the many near-identical
/// hand-rolled "smiling sun" painters that used to live in each game's own
/// background file.
void paintSmilingSun(
  Canvas canvas,
  Offset center,
  double radius, {
  double rayPhase = 0,
  int rayCount = 12,
  bool rays = true,
  bool cheeks = true,
  Color faceColor = SharedArtColors.ink,
  Color rayColor = SharedArtColors.sunRay,
  Color coreColor = SharedArtColors.sunCore,
  double alpha = 1.0,
}) {
  canvas.drawCircle(
    center,
    radius * 1.95,
    Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x99FFF59D).withValues(alpha: alpha),
          const Color(0x00FFF59D),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.95)),
  );
  if (rays) {
    for (var i = 0; i < rayCount; i++) {
      final a = rayPhase + i * math.pi * 2 / rayCount;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        center + dir * radius * 1.08,
        center + dir * radius * 1.48,
        Paint()
          ..color = rayColor.withValues(alpha: 0.8 * alpha)
          ..strokeWidth = radius * 0.13
          ..strokeCap = StrokeCap.round,
      );
    }
  }
  canvas.drawCircle(center, radius, Paint()..color = coreColor.withValues(alpha: alpha));
  canvas.drawCircle(
    center + Offset(-radius * 0.26, -radius * 0.26),
    radius * 0.43,
    Paint()..color = Colors.white.withValues(alpha: 0.35 * alpha),
  );
  final face = Paint()..color = faceColor.withValues(alpha: alpha);
  canvas.drawCircle(center + Offset(-radius * 0.29, -radius * 0.09), radius * 0.08, face);
  canvas.drawCircle(center + Offset(radius * 0.29, -radius * 0.09), radius * 0.08, face);
  canvas.drawArc(
    Rect.fromCenter(center: center + Offset(0, radius * 0.16), width: radius * 0.57, height: radius * 0.37),
    0.2,
    math.pi - 0.4,
    false,
    Paint()
      ..color = faceColor.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.068
      ..strokeCap = StrokeCap.round,
  );
  if (cheeks) {
    final cheek = Paint()..color = SharedArtColors.blush.withValues(alpha: 0.6 * alpha);
    canvas.drawCircle(center + Offset(-radius * 0.58, radius * 0.15), radius * 0.15, cheek);
    canvas.drawCircle(center + Offset(radius * 0.58, radius * 0.15), radius * 0.15, cheek);
  }
}

/// Draws a fluffy white cloud made of overlapping circles and a rounded
/// base. This is the shape reused (with small size/shade tweaks) by most of
/// the game backgrounds in the app.
///
/// - [shaded] adds a pale-blue "underside" layer just behind the white body,
///   giving the cloud a little depth; turn it off for a flatter, cheaper look.
/// - [small] draws a simpler, smaller 4-circle cloud (no shade, no rounded
///   base) for distant/background clouds.
/// - [highlight] adds a soft white highlight streak across the top.
void paintPuffyCloud(
  Canvas canvas,
  Offset center,
  double scale, {
  bool shaded = true,
  bool small = false,
  bool highlight = false,
  double width = 96,
  Color shadeColor = SharedArtColors.cloudShade,
  double bodyAlpha = 0.97,
  double shadeAlpha = 1.0,
}) {
  if (small) {
    final paint = Paint()..color = Colors.white.withValues(alpha: bodyAlpha);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center + Offset(0, 8 * scale), width: 74 * scale, height: 22 * scale),
        Radius.circular(12 * scale),
      ),
      paint,
    );
    canvas.drawCircle(center + Offset(-14 * scale, 0), 15 * scale, paint);
    canvas.drawCircle(center + Offset(6 * scale, -8 * scale), 19 * scale, paint);
    canvas.drawCircle(center + Offset(24 * scale, 0), 13 * scale, paint);
    return;
  }

  void puffs(Paint p, double dy) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center + Offset(0, 12 * scale + dy), width: width * scale, height: 26 * scale),
        Radius.circular(13 * scale),
      ),
      p,
    );
    canvas.drawCircle(center + Offset(-22 * scale, 3 * scale + dy), 18 * scale, p);
    canvas.drawCircle(center + Offset(4 * scale, -8 * scale + dy), 25 * scale, p);
    canvas.drawCircle(center + Offset(30 * scale, 5 * scale + dy), 17 * scale, p);
  }

  if (shaded) {
    puffs(Paint()..color = shadeColor.withValues(alpha: shadeAlpha), 3 * scale);
  }
  puffs(Paint()..color = Colors.white.withValues(alpha: bodyAlpha), 0);

  if (highlight) {
    canvas.drawOval(
      Rect.fromCenter(center: center + Offset(-2 * scale, -20 * scale), width: 30 * scale, height: 10 * scale),
      Paint()..color = Colors.white.withValues(alpha: 0.7 * bodyAlpha),
    );
  }
}
