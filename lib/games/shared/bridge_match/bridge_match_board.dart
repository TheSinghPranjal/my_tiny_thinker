import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Stable two-column bridge board: cards stay locked in fixed slots.
/// Connection lines are painted in an overlay and never affect layout.
class BridgeMatchBoard extends StatefulWidget {
  const BridgeMatchBoard({
    super.key,
    required this.leftIds,
    required this.rightIds,
    required this.connections,
    required this.leftBuilder,
    required this.rightBuilder,
    required this.colorForConnection,
    required this.onConnect,
    this.slotSize = 78,
    this.canDragLeft,
    this.canTargetRight,
    this.softLines = false,
  });

  final List<String> leftIds;
  final List<String> rightIds;
  final List<({String leftId, String rightId, int colorKey})> connections;
  final Widget Function(String id, {required bool selected}) leftBuilder;
  final Widget Function(String id, {required bool highlighted}) rightBuilder;
  final Color Function(int colorKey) colorForConnection;
  final void Function({required String leftId, required String rightId}) onConnect;
  final double slotSize;
  final bool Function(String id)? canDragLeft;
  final bool Function(String id)? canTargetRight;

  /// Glossy "tube" connections with star knobs on the card edges, instead of
  /// the classic thin line between card centres.
  final bool softLines;

  @override
  State<BridgeMatchBoard> createState() => _BridgeMatchBoardState();
}

class _BridgeMatchBoardState extends State<BridgeMatchBoard>
    with SingleTickerProviderStateMixin {
  final _boardKey = GlobalKey();
  final Map<String, GlobalKey> _cardKeys = {};

  String? _dragLeftId;
  Offset? _dragStart;
  Offset? _dragCurrent;
  String? _hoverRightId;
  Offset? _fadeStart;
  Offset? _fadeEnd;
  late final AnimationController _fadeController;
  int _lastConnectionCount = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void didUpdateWidget(covariant BridgeMatchBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.connections.length != _lastConnectionCount) {
      _lastConnectionCount = widget.connections.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  GlobalKey _keyFor(String id) => _cardKeys.putIfAbsent(id, GlobalKey.new);

  Offset? _centerOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    final board = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || board == null || !box.hasSize) return null;
    final global = box.localToGlobal(box.size.center(Offset.zero));
    return board.globalToLocal(global);
  }

  String? _hitRight(Offset local) {
    for (final id in widget.rightIds) {
      if (widget.canTargetRight != null && !widget.canTargetRight!(id)) {
        continue;
      }
      final key = _keyFor(id);
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      final board = _boardKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || board == null) continue;
      final topLeft = board.globalToLocal(box.localToGlobal(Offset.zero));
      final rect = (topLeft & box.size).inflate(14);
      if (rect.contains(local)) return id;
    }
    return null;
  }

  void _onPanStart(String leftId, DragStartDetails d) {
    if (widget.canDragLeft != null && !widget.canDragLeft!(leftId)) return;
    final board = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (board == null) return;
    final local = board.globalToLocal(d.globalPosition);
    final start = _centerOf(_keyFor(leftId)) ?? local;
    setState(() {
      _dragLeftId = leftId;
      _dragStart = start;
      _dragCurrent = local;
      _hoverRightId = null;
      _fadeStart = null;
      _fadeEnd = null;
    });
    _fadeController
      ..stop()
      ..value = 0;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final board = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (board == null || _dragLeftId == null) return;
    final local = board.globalToLocal(d.globalPosition);
    setState(() {
      _dragCurrent = local;
      _hoverRightId = _hitRight(local);
    });
  }

  void _onPanEnd(DragEndDetails _) {
    final leftId = _dragLeftId;
    final start = _dragStart;
    final end = _dragCurrent;
    final rightId = _hoverRightId;
    if (leftId == null || start == null || end == null) {
      setState(() {
        _dragLeftId = null;
        _dragStart = null;
        _dragCurrent = null;
        _hoverRightId = null;
      });
      return;
    }

    if (rightId != null) {
      widget.onConnect(leftId: leftId, rightId: rightId);
    }

    setState(() {
      _fadeStart = start;
      _fadeEnd = end;
      _dragLeftId = null;
      _dragStart = null;
      _dragCurrent = null;
      _hoverRightId = null;
    });
    _fadeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final slot = widget.slotSize + 12;
    // Soft lines attach to the facing card edges; classic lines to the centres.
    final edge = widget.softLines ? widget.slotSize / 2 : 0.0;
    final permanent = <(Offset, Offset, Color)>[];
    for (final conn in widget.connections) {
      final a = _centerOf(_keyFor(conn.leftId));
      final b = _centerOf(_keyFor(conn.rightId));
      if (a != null && b != null) {
        permanent.add((
          a.translate(edge, 0),
          b.translate(-edge, 0),
          widget.colorForConnection(conn.colorKey),
        ));
      }
    }

    return Container(
      key: _boardKey,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final id in widget.leftIds)
                      SizedBox(
                        height: slot,
                        child: Center(
                          child: KeyedSubtree(
                            key: _keyFor(id),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onPanStart: (d) => _onPanStart(id, d),
                              onPanUpdate: _onPanUpdate,
                              onPanEnd: _onPanEnd,
                              child: widget.leftBuilder(
                                id,
                                selected: id == _dragLeftId,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 28),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final id in widget.rightIds)
                      SizedBox(
                        height: slot,
                        child: Center(
                          child: KeyedSubtree(
                            key: _keyFor(id),
                            child: widget.rightBuilder(
                              id,
                              highlighted: id == _hoverRightId,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // Lines above cards; never participate in layout.
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: BridgeLinesPainter(
                  soft: widget.softLines,
                  permanent: permanent,
                  dragStart: _dragStart?.translate(edge, 0),
                  dragEnd: _dragCurrent,
                  fadeStart: _fadeStart?.translate(edge, 0),
                  fadeEnd: _fadeEnd,
                  fadeProgress: _fadeController.value,
                  sparklePhase:
                      DateTime.now().millisecondsSinceEpoch / 400.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BridgeLinesPainter extends CustomPainter {
  BridgeLinesPainter({
    required this.permanent,
    required this.dragStart,
    required this.dragEnd,
    required this.fadeStart,
    required this.fadeEnd,
    required this.fadeProgress,
    required this.sparklePhase,
    this.soft = false,
  });

  final bool soft;
  final List<(Offset, Offset, Color)> permanent;
  final Offset? dragStart;
  final Offset? dragEnd;
  final Offset? fadeStart;
  final Offset? fadeEnd;
  final double fadeProgress;
  final double sparklePhase;

  Path _curve(Offset a, Offset b) {
    final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
    final ctrl = mid.translate(0, -36);
    return Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, b.dx, b.dy);
  }

  void _drawSparkles(Canvas canvas, Path path, Color color) {
    for (final metric in path.computeMetrics()) {
      for (var t = 0.1; t < 1; t += 0.22) {
        final tan = metric.getTangentForOffset(metric.length * t);
        if (tan == null) continue;
        final pulse = 0.5 + 0.5 * math.sin(sparklePhase + t * 8);
        canvas.drawCircle(
          tan.position,
          2.2 + pulse * 1.4,
          Paint()..color = color.withValues(alpha: 0.7 * pulse),
        );
      }
    }
  }

  // --- Soft (tube) style --------------------------------------------------

  void _softTube(Canvas canvas, Path path, Color color) {
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Color.lerp(color, Colors.white, 0.15)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Color.lerp(color, Colors.white, 0.6)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path.shift(const Offset(0, -2)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round,
    );
  }

  void _starKnob(Canvas canvas, Offset c, Color color) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final a = -math.pi / 2 + i * math.pi / 5;
      final r = i.isEven ? 12.0 : 5.6;
      final p = Offset(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawCircle(
      c,
      14,
      Paint()
        ..color = color.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(path, Paint()..color = Color.lerp(color, Colors.white, 0.35)!);
  }

  void _twinkles(Canvas canvas, Path path, Color color) {
    for (final metric in path.computeMetrics()) {
      for (final (t, r) in [(0.3, 6.0), (0.55, 9.0), (0.75, 5.0)]) {
        final tan = metric.getTangentForOffset(metric.length * t);
        if (tan == null) continue;
        final pulse = 0.6 + 0.4 * math.sin(sparklePhase + t * 9);
        final c = tan.position.translate(0, -22 - r * 0.5);
        final rr = r * pulse;
        canvas.drawPath(
          Path()
            ..moveTo(c.dx, c.dy - rr)
            ..quadraticBezierTo(c.dx, c.dy, c.dx + rr, c.dy)
            ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + rr)
            ..quadraticBezierTo(c.dx, c.dy, c.dx - rr, c.dy)
            ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - rr),
          Paint()..color = Color.lerp(color, Colors.white, 0.4)!.withValues(alpha: 0.9),
        );
      }
    }
  }

  void _paintSoft(Canvas canvas) {
    for (final (a, b, color) in permanent) {
      final path = _curve(a, b);
      _softTube(canvas, path, color);
      _starKnob(canvas, a, color);
      _starKnob(canvas, b, color);
      _twinkles(canvas, path, color);
    }
    if (dragStart != null && dragEnd != null) {
      const blue = Color(0xFF7CC4F5);
      final path = _curve(dragStart!, dragEnd!);
      _softTube(canvas, path, blue);
      _starKnob(canvas, dragStart!, blue);
      _starKnob(canvas, dragEnd!, blue);
    }
    if (fadeStart != null && fadeEnd != null && fadeProgress < 1) {
      canvas.drawPath(
        _curve(fadeStart!, fadeEnd!),
        Paint()
          ..color = const Color(0xFF90CAF9).withValues(alpha: (1 - fadeProgress) * 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (soft) {
      _paintSoft(canvas);
      return;
    }
    for (final (a, b, color) in permanent) {
      final path = _curve(a, b);
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(a, 7, Paint()..color = color);
      canvas.drawCircle(b, 7, Paint()..color = color);
      canvas.drawCircle(a, 3.5, Paint()..color = Colors.white);
      canvas.drawCircle(b, 3.5, Paint()..color = Colors.white);
      _drawSparkles(canvas, path, color);
    }

    if (dragStart != null && dragEnd != null) {
      final path = _curve(dragStart!, dragEnd!);
      canvas.drawPath(
        path,
        Paint()
          ..shader = ui.Gradient.linear(
            dragStart!,
            dragEnd!,
            const [
              Color(0xFFFF8A80),
              Color(0xFFFFF59D),
              Color(0xFF80DEEA),
              Color(0xFFCE93D8),
            ],
            const [0.0, 1 / 3, 2 / 3, 1.0],
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round,
      );
      _drawSparkles(canvas, path, const Color(0xFFFFF176));
    }

    if (fadeStart != null && fadeEnd != null && fadeProgress < 1) {
      canvas.drawPath(
        _curve(fadeStart!, fadeEnd!),
        Paint()
          ..color = const Color(0xFF90CAF9)
              .withValues(alpha: (1 - fadeProgress) * 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BridgeLinesPainter oldDelegate) => true;
}
