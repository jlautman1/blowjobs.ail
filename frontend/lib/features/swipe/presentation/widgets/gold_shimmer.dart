import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class GoldShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const GoldShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<GoldShimmer> createState() => _GoldShimmerState();
}

class _GoldShimmerState extends State<GoldShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
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
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryLight,
                Colors.white.withOpacity(0.9),
                AppColors.primaryLight,
                AppColors.primary,
              ],
              stops: [
                0.0,
                _controller.value - 0.2,
                _controller.value,
                _controller.value + 0.2,
                1.0,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: widget.child,
        );
      },
    );
  }
}

