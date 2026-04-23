import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'bounce_button.dart';

class PulseFAB extends StatefulWidget {
  final VoidCallback onTap;

  const PulseFAB({super.key, required this.onTap});

  @override
  State<PulseFAB> createState() => _PulseFABState();
}

class _PulseFABState extends State<PulseFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
      
    _glowAnimation = Tween<double>(begin: 4.0, end: 15.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 56,
          height: 56,
          margin: const EdgeInsets.only(bottom: 24), // Menonjol 10px ke atas dari navbar 64px
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.6),
                blurRadius: _glowAnimation.value,
                spreadRadius: _glowAnimation.value / 4,
              ),
            ],
          ),
          child: BounceButton(
            onTap: widget.onTap,
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        );
      },
    );
  }
}
