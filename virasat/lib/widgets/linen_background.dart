import 'dart:math' as math;
import 'package:flutter/material.dart';

class LinenBackground extends StatelessWidget {
  final Widget child;
  final Color color;

  const LinenBackground({
    super.key,
    required this.child,
    this.color = const Color(0xFFF7F1E8),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base color
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(color: color),
          ),
        ),
        // Linen grain texture simulated with subtle noise overlay
        Positioned.fill(
          child: CustomPaint(
            painter: _LinenGrainPainter(opacity: 0.04),
          ),
        ),
        // Radial warm glow
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0x15C8922A),
                    Colors.transparent,
                  ],
                  radius: 1.2,
                  center: Alignment(0.0, -0.3),
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _LinenGrainPainter extends CustomPainter {
  final double opacity;

  _LinenGrainPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()
      ..color = Color.fromRGBO(139, 90, 40, opacity)
      ..strokeWidth = 0.5;

    for (int i = 0; i < 3000; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      paint.strokeWidth = random.nextDouble() * 1.0 + 0.3;

      // Draw short horizontal lines for linen weave effect
      final length = random.nextDouble() * 4 + 2;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + length, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LinenGrainPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}
