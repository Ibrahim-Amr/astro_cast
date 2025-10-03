import 'package:flutter/material.dart';
import 'dart:math';

class SpaceAnimatedBackground extends StatefulWidget {
  @override
  _SpaceAnimatedBackgroundState createState() => _SpaceAnimatedBackgroundState();
}

class _SpaceAnimatedBackgroundState extends State<SpaceAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A0E21),
                Color(0xFF1D1F33),
                Color(0xFF0A0E21),
              ],
            ),
          ),
          child: CustomPaint(
            painter: _SpaceBackgroundPainter(_controller.value),
          ),
        );
      },
    );
  }
}

class _SpaceBackgroundPainter extends CustomPainter {
  final double animationValue;

  _SpaceBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final random = Random();
    for (int i = 0; i < 100; i++) {
      final x = size.width * random.nextDouble();
      final y = size.height * random.nextDouble();
      final radius = 0.5 + (random.nextDouble() * 1.5);
      final twinkle = (sin(animationValue * 2 * pi + i) + 1) / 2;

      canvas.drawCircle(
          Offset(x, y),
          radius * twinkle,
          starPaint..color = Colors.white.withOpacity(0.6 * twinkle)
      );
    }

    final nebulaPaint = Paint()
      ..style = PaintingStyle.fill;

    nebulaPaint.shader = RadialGradient(
      colors: [
        const Color(0xFF6C63FF).withOpacity(0.1),
        const Color(0xFF6C63FF).withOpacity(0.05),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromCircle(
      center: Offset(size.width * 0.3, size.height * 0.2),
      radius: size.width * 0.3,
    ));
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.2),
      size.width * 0.3,
      nebulaPaint,
    );

    nebulaPaint.shader = RadialGradient(
      colors: [
        const Color(0xFFFF6584).withOpacity(0.08),
        const Color(0xFFFF6584).withOpacity(0.04),
        Colors.transparent,
      ],
      stops: const [0.0, 0.6, 1.0],
    ).createShader(Rect.fromCircle(
      center: Offset(size.width * 0.7, size.height * 0.7),
      radius: size.width * 0.4,
    ));
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.7),
      size.width * 0.4,
      nebulaPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}