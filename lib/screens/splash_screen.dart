import 'package:flutter/material.dart';
import 'dart:math';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _orbitAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _orbitAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 1000),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Stack(
        children: [
          _buildSpaceBackground(),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPlanetAnimation(),

                const SizedBox(height: 40),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'WeatherWise Pro',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Space-Powered Weather Intelligence',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF6C63FF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Text(
                    'v1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Powered by Satellite Data & AI',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpaceBackground() {
    return AnimatedBuilder(
      animation: _orbitAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: _SpaceBackgroundPainter(_orbitAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildPlanetAnimation() {
    return Stack(
      alignment: Alignment.center,
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                colors: [
                  Color(0xFF6C63FF),
                  Color(0xFF4A43CC),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        ),

        Transform.rotate(
          angle: _orbitAnimation.value * 2 * pi,
          child: Transform.translate(
            offset: const Offset(80, 0),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6584),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6584).withOpacity(0.7),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),

        ScaleTransition(
          scale: _scaleAnimation,
          child: const Icon(
            Icons.thermostat,
            size: 40,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _SpaceBackgroundPainter extends CustomPainter {
  final double animationValue;

  _SpaceBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 50; i++) {
      final x = size.width * _starPositions[i][0];
      final y = size.height * _starPositions[i][1];
      final radius = 1 + (_starSizes[i] * animationValue);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    final nebulaPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF6C63FF).withOpacity(0.1),
          const Color(0xFF0A0E21).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.7, size.height * 0.3),
        radius: size.width * 0.4,
      ));

    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.3),
      size.width * 0.4,
      nebulaPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  final List<List<double>> _starPositions = [
    [0.1, 0.2], [0.8, 0.1], [0.3, 0.4], [0.7, 0.6], [0.2, 0.8],
    [0.9, 0.3], [0.4, 0.7], [0.6, 0.2], [0.1, 0.9], [0.8, 0.8],
    [0.3, 0.1], [0.7, 0.9], [0.2, 0.5], [0.9, 0.7], [0.4, 0.3],
    [0.6, 0.6], [0.1, 0.4], [0.8, 0.5], [0.3, 0.8], [0.7, 0.2],
    [0.2, 0.6], [0.9, 0.4], [0.4, 0.9], [0.6, 0.1], [0.1, 0.7],
    [0.8, 0.9], [0.3, 0.2], [0.7, 0.4], [0.2, 0.3], [0.9, 0.6],
    [0.4, 0.5], [0.6, 0.8], [0.1, 0.6], [0.8, 0.4], [0.3, 0.9],
    [0.7, 0.7], [0.2, 0.2], [0.9, 0.8], [0.4, 0.4], [0.6, 0.3],
    [0.1, 0.3], [0.8, 0.7], [0.3, 0.6], [0.7, 0.1], [0.2, 0.9],
    [0.9, 0.2], [0.4, 0.8], [0.6, 0.9], [0.1, 0.5], [0.8, 0.2]
  ];

  final List<double> _starSizes = [
    0.5, 1.0, 0.7, 1.2, 0.8, 1.1, 0.6, 0.9, 1.3, 0.7,
    1.0, 0.8, 1.1, 0.6, 0.9, 1.2, 0.7, 1.0, 0.8, 1.1,
    0.6, 0.9, 1.2, 0.7, 1.0, 0.8, 1.1, 0.6, 0.9, 1.2,
    0.7, 1.0, 0.8, 1.1, 0.6, 0.9, 1.2, 0.7, 1.0, 0.8,
    1.1, 0.6, 0.9, 1.2, 0.7, 1.0, 0.8, 1.1, 0.6, 0.9
  ];
}