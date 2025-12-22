import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_theme.dart';

class SwipeActionButtons extends StatelessWidget {
  final VoidCallback onPass;
  final VoidCallback onLike;
  final VoidCallback onSuperLike;
  final VoidCallback? onUndo;
  final VoidCallback? onInfo;
  final AnimationController pulseController;

  const SwipeActionButtons({
    super.key,
    required this.onPass,
    required this.onLike,
    required this.onSuperLike,
    this.onUndo,
    this.onInfo,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Undo button
          _ActionButton(
            icon: Iconsax.refresh_left_square,
            color: AppColors.warning,
            size: 48,
            onTap: onUndo,
            tooltip: 'Undo',
          ),
          
          // Pass button
          _ActionButton(
            icon: Iconsax.close_circle,
            color: AppColors.error,
            size: 60,
            onTap: onPass,
            tooltip: 'Skip',
          ),
          
          // Super Like button
          AnimatedBuilder(
            animation: pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + (pulseController.value * 0.05),
                child: child,
              );
            },
            child: _ActionButton(
              icon: Iconsax.star5,
              color: AppColors.primary,
              size: 52,
              onTap: onSuperLike,
              isGradient: true,
              tooltip: 'Super Like',
            ),
          ),
          
          // Like button
          _ActionButton(
            icon: Iconsax.heart5,
            color: AppColors.success,
            size: 60,
            onTap: onLike,
            tooltip: 'Interested',
          ),
          
          // Info button
          _ActionButton(
            icon: Iconsax.info_circle,
            color: AppColors.accent,
            size: 48,
            onTap: onInfo,
            tooltip: 'Details',
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onTap;
  final bool isGradient;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
    this.isGradient = false,
    required this.tooltip,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null;
    
    return Tooltip(
      message: widget.tooltip,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEnabled
                ? widget.isGradient 
                  ? null 
                  : widget.color.withOpacity(_isPressed ? 0.3 : 0.15)
                : AppColors.surfaceLight,
              gradient: widget.isGradient && isEnabled
                ? LinearGradient(
                    colors: [
                      widget.color.withOpacity(_isPressed ? 0.8 : 1.0),
                      widget.color.withOpacity(_isPressed ? 0.6 : 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
              border: Border.all(
                color: isEnabled 
                  ? widget.color.withOpacity(_isPressed ? 0.8 : 0.4)
                  : AppColors.surfaceBright,
                width: 2,
              ),
              boxShadow: isEnabled && _isPressed
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
            ),
            child: Center(
              child: Icon(
                widget.icon,
                color: isEnabled
                  ? widget.isGradient 
                    ? Colors.white 
                    : widget.color
                  : AppColors.textTertiary,
                size: widget.size * 0.45,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

