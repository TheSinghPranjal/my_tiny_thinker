import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/models/moon_rescue_models.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/presentation/widgets/astronaut_widget.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/presentation/widgets/rocket_widget.dart';

class MoonRescueBoard extends StatefulWidget {
  const MoonRescueBoard({
    super.key,
    required this.astronauts,
    required this.rocket,
    required this.capacity,
    required this.onPlayAreaSized,
    required this.onTapAstronaut,
    required this.onFlickAstronaut,
    required this.onTapRocket,
    this.largerTouch = true,
  });

  final List<MoonAstronaut> astronauts;
  final MoonRocket rocket;
  final int capacity;
  final ValueChanged<Size> onPlayAreaSized;
  final ValueChanged<String> onTapAstronaut;
  final void Function(String id, Offset delta) onFlickAstronaut;
  final VoidCallback onTapRocket;
  final bool largerTouch;

  @override
  State<MoonRescueBoard> createState() => _MoonRescueBoardState();
}

class _MoonRescueBoardState extends State<MoonRescueBoard> {
  String? _trackingId;
  Offset? _lastGlobal;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onPlayAreaSized(size);
        });

        final astroSize = widget.largerTouch ? 64.0 : 54.0;
        final rocketSize = widget.largerTouch ? 120.0 : 100.0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Rocket on moon pad
            Positioned(
              left: widget.rocket.x * size.width - rocketSize / 2,
              top: widget.rocket.y * size.height - rocketSize * 0.85,
              child: RocketWidget(
                rocket: widget.rocket,
                capacity: widget.capacity,
                size: rocketSize,
                onTap: widget.rocket.phase == RocketPhase.ready
                    ? widget.onTapRocket
                    : null,
              ),
            ),
            // Astronauts
            for (final a in widget.astronauts)
              if (a.phase != AstronautPhase.boarded &&
                  a.phase != AstronautPhase.boarding)
                Positioned(
                  left: a.x * size.width - astroSize / 2,
                  top: a.y * size.height - astroSize * 0.6,
                  child: GestureDetector(
                    onTap: a.phase == AstronautPhase.floating
                        ? () => widget.onTapAstronaut(a.id)
                        : null,
                    onPanStart: a.phase == AstronautPhase.floating
                        ? (d) {
                            _trackingId = a.id;
                            _lastGlobal = d.globalPosition;
                          }
                        : null,
                    onPanUpdate: a.phase == AstronautPhase.floating
                        ? (d) {
                            if (_trackingId != a.id || _lastGlobal == null) {
                              return;
                            }
                            final delta = d.globalPosition - _lastGlobal!;
                            _lastGlobal = d.globalPosition;
                            // Accumulate-ish: use current delta
                            if (delta.distance > 2) {
                              widget.onFlickAstronaut(a.id, delta * 8);
                              _trackingId = null;
                              _lastGlobal = null;
                            }
                          }
                        : null,
                    onPanEnd: (_) {
                      _trackingId = null;
                      _lastGlobal = null;
                    },
                    child: AstronautWidget(
                      astronaut: a,
                      size: astroSize,
                      highlighted: a.phase == AstronautPhase.pushed,
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}
