import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ParticlesBackground extends StatefulWidget {
  final Widget child;

  const ParticlesBackground({super.key, required this.child});

  @override
  State<ParticlesBackground> createState() => _ParticlesBackgroundState();
}

class _ParticlesBackgroundState extends State<ParticlesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final int count = 50;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 10))
      ..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      final rng = Random();
      for (var i = 0; i < count; i++) {
        _particles.add(_Particle(
          x: rng.nextDouble() * size.width,
          y: rng.nextDouble() * size.height,
          radius: rng.nextDouble() * 2 + 1,
          speedY: rng.nextDouble() * 0.5 + 0.2,
          speedX: rng.nextDouble() * 0.4 - 0.2,
          alpha: rng.nextDouble() * 0.6 + 0.1,
        ));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              if (_particles.isNotEmpty) {
                final size = MediaQuery.of(context).size;
                for (var p in _particles) {
                  p.y -= p.speedY;
                  p.x += p.speedX;
                  if (p.y < 0) {
                    p.y = size.height;
                    p.x = Random().nextDouble() * size.width;
                  }
                  if (p.x < 0) p.x = size.width;
                  if (p.x > size.width) p.x = 0;
                }
              }
              return CustomPaint(
                painter: _ParticlePainter(_particles),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Particle {
  double x, y, radius, speedY, speedX, alpha;
  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speedY,
    required this.speedX,
    required this.alpha,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var p in particles) {
      paint.color = AppColors.primary.withValues(alpha: p.alpha);
      canvas.drawCircle(Offset(p.x, p.y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
