import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient - Light turquoise theme
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFFFF),      // White
                Color(0xFFF0FDFA),      // Very light turquoise
                Color(0xFFCCFBF1),      // Light turquoise mint
              ],
            ),
          ),
        ),
        
        // Animated gradient orbs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _OrbsPainter(_controller.value),
              size: Size.infinite,
            );
          },
        ),
        
        // Floating particles
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              painter: _ParticlesPainter(_particleController.value),
              size: Size.infinite,
            );
          },
        ),
        
        // Subtle texture overlay
        Opacity(
          opacity: 0.02,
          child: CustomPaint(
            painter: _NoisePainter(),
            size: Size.infinite,
          ),
        ),
      ],
    );
  }
}

class _OrbsPainter extends CustomPainter {
  final double progress;

  _OrbsPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Turquoise orb (top right)
    final orb1Center = Offset(
      size.width * 0.85 + math.sin(progress * math.pi * 2) * 30,
      size.height * 0.15 + math.cos(progress * math.pi * 2) * 20,
    );
    paint.shader = RadialGradient(
      colors: [
        AppColors.primary.withOpacity(0.25),
        AppColors.primary.withOpacity(0.10),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: orb1Center, radius: 220));
    canvas.drawCircle(orb1Center, 220, paint);

    // Cyan orb (bottom left)
    final orb2Center = Offset(
      size.width * 0.15 + math.cos(progress * math.pi * 2) * 25,
      size.height * 0.75 + math.sin(progress * math.pi * 2) * 30,
    );
    paint.shader = RadialGradient(
      colors: [
        AppColors.accent.withOpacity(0.20),
        AppColors.accent.withOpacity(0.08),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: orb2Center, radius: 200));
    canvas.drawCircle(orb2Center, 200, paint);

    // Soft pink orb (center-right)
    final orb3Center = Offset(
      size.width * 0.6 + math.sin(progress * math.pi * 2 + 1) * 40,
      size.height * 0.45 + math.cos(progress * math.pi * 2 + 1) * 35,
    );
    paint.shader = RadialGradient(
      colors: [
        AppColors.superLike.withOpacity(0.12),
        AppColors.superLike.withOpacity(0.04),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: orb3Center, radius: 160));
    canvas.drawCircle(orb3Center, 160, paint);
    
    // Additional light teal orb (bottom center)
    final orb4Center = Offset(
      size.width * 0.5 + math.cos(progress * math.pi * 2 + 2) * 35,
      size.height * 0.9 + math.sin(progress * math.pi * 2 + 2) * 25,
    );
    paint.shader = RadialGradient(
      colors: [
        AppColors.primaryLight.withOpacity(0.30),
        AppColors.primaryLight.withOpacity(0.10),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: orb4Center, radius: 180));
    canvas.drawCircle(orb4Center, 180, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbsPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ParticlesPainter extends CustomPainter {
  final double progress;
  final math.Random random = math.Random(42);

  _ParticlesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Floating turquoise particles
    for (int i = 0; i < 25; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final speed = 0.3 + random.nextDouble() * 0.4;
      final phase = random.nextDouble() * math.pi * 2;
      
      final x = baseX + math.sin(progress * math.pi * 2 * speed + phase) * 15;
      final y = (baseY - progress * size.height * speed * 0.5) % size.height;
      
      final opacity = 0.15 + random.nextDouble() * 0.25;
      final radius = 2 + random.nextDouble() * 3;
      
      // Mix of turquoise and cyan particles
      final color = i % 3 == 0 ? AppColors.primary : AppColors.accent;
      paint.color = color.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _NoisePainter extends CustomPainter {
  final math.Random random = math.Random(123);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Draw subtle texture dots for light theme
    for (int i = 0; i < 400; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = random.nextDouble() * 0.3;
      
      // Use darker dots for light background
      paint.color = AppColors.primary.withOpacity(opacity * 0.5);
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter oldDelegate) {
    return false; // Static noise, no need to repaint
  }
}

