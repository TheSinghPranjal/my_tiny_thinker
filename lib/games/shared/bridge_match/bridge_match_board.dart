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
    final permanent = <(Offset, Offset, Color)>[];
    for (final conn in widget.connections) {
      final a = _centerOf(_keyFor(conn.leftId));
      final b = _centerOf(_keyFor(conn.rightId));
      if (a != null && b != null) {
        permanent.add((a, b, widget.colorForConnection(conn.colorKey)));
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
                  permanent: permanent,
                  dragStart: _dragStart,
                  dragEnd: _dragCurrent,
                  fadeStart: _fadeStart,
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
  });

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

  @override
  void paint(Canvas canvas, Size size) {
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
