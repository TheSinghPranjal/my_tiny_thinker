import 'package:flutter/material.dart';

/// Shared meadow illustration used behind every game setup / Play screen.
///
/// One compressed asset replaces per-game CustomPaint character scenes on
/// those screens, which keeps the binary smaller and the look consistent.
class SetupMeadowBackground extends StatelessWidget {
  const SetupMeadowBackground({super.key, this.child});

  static const assetPath = 'assets/images/setup_meadow_background.jpg';

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFF81D4FA)),
        const Image(
          image: AssetImage(assetPath),
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.medium,
          gaplessPlayback: true,
        ),
        ?child,
      ],
    );
  }
}
