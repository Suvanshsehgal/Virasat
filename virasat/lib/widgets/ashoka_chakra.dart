import 'dart:math' as math;
import 'package:flutter/material.dart';

class AshokaChakra extends StatefulWidget {
  final double size;
  final Color color;
  final bool animate;

  const AshokaChakra({
    super.key,
    this.size = 80,
    this.color = const Color(0xFFC8922A),
    this.animate = false,
  });

  @override
  State<AshokaChakra> createState() => _AshokaChakraState();
}

class _AshokaChakraState extends State<AshokaChakra>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _rotation;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 2000),
        vsync: this,
      )..repeat();
      _rotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
        CurvedAnimation(parent: _controller!, curve: Curves.linear),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotation ?? AlwaysStoppedAnimation(0),
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotation?.value ?? 0,
          child: CustomPaint(
            size: Size.square(widget.size),
            painter: _AshokaChakraPainter(color: widget.color),
          ),
        );
      },
    );
  }
}

class _AshokaChakraPainter extends CustomPainter {
  final Color color;

  _AshokaChakraPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    // Outer circle
    canvas.drawCircle(center, radius, paint);

    // Inner circle
    final innerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, radius * 0.2, innerPaint);

    // 24 spokes
    final spokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 24; i++) {
      final angle = (i * 15) * math.pi / 180;
      final startX = center.dx + radius * 0.2 * math.cos(angle);
      final startY = center.dy + radius * 0.2 * math.sin(angle);
      final endX = center.dx + radius * math.cos(angle);
      final endY = center.dy + radius * math.sin(angle);
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        spokePaint,
      );
    }

    // Small dots between spokes on inner ring (simplified representation)
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 24; i++) {
      final angle = (i * 15 + 7.5) * math.pi / 180;
      final dx = center.dx + radius * 0.12 * math.cos(angle);
      final dy = center.dy + radius * 0.12 * math.sin(angle);
      canvas.drawCircle(Offset(dx, dy), 0.8, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AshokaChakraPainter oldDelegate) =>
      oldDelegate.color != color;
}
