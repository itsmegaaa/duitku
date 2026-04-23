import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), _checkRouting);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkRouting() {
    if (!mounted) return;

    final hasSeenOnboarding = HiveService.hasSeenOnboarding;
    final isAuthenticated = HiveService.isAuthenticated;
    final isPinActive = HiveService.isPinActive;

    if (!hasSeenOnboarding) {
      context.go('/onboarding');
    } else if (!isAuthenticated) {
      context.go('/auth/login');
    } else if (isPinActive) {
      context.go('/auth/pin-lock');
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          gradient: RadialGradient(
            colors: [Color(0xFF2A2310), AppColors.background],
            center: Alignment.center,
            radius: 0.8,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _scaleAnimation.value.clamp(0.0, 1.0),
                      child: Text(
                        '🪙 DuitKu',
                        style: AppTextStyles.display.copyWith(fontSize: 48),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Opacity(
                    opacity: _fadeAnimation.value,
                    child: Text(
                      'Kelola keuanganmu dengan cerdas',
                      style: AppTextStyles.caption.copyWith(fontSize: 16),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
