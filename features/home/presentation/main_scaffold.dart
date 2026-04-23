import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/presentation/components/glass_container.dart';
import '../../../core/presentation/components/bounce_button.dart';
import '../../../core/presentation/components/pulse_fab.dart';
import '../../transactions/presentation/transaction_bottom_sheet.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Current route to highlight active tab
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. Konten Utama
          Positioned.fill(
            child: child,
          ),

          // 2. Navigasi Bawah Mengambang
          Positioned(
            bottom: 16,
            left: 24,
            right: 24,
            child: GlassContainer(
              height: 64,
              borderRadius: 24,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavBarIcon(
                    icon: Icons.home_rounded,
                    isActive: location == '/',
                    onTap: () => context.go('/'),
                  ),
                  _NavBarIcon(
                    icon: Icons.bar_chart_rounded,
                    isActive: location == '/statistics',
                    onTap: () => context.go('/statistics'),
                  ),
                  const SizedBox(width: 56), // Ruang kosong untuk FAB
                  _NavBarIcon(
                    icon: Icons.pie_chart_rounded,
                    isActive: location == '/budget',
                    onTap: () => context.go('/budget'),
                  ),
                  _NavBarIcon(
                    icon: Icons.person_rounded,
                    isActive: location == '/settings',
                    onTap: () => context.go('/settings'),
                  ),
                ],
              ),
            ),
          ),

          // 3. Pulse FAB di tengah
          Positioned(
            bottom: 26, // Nav bottom(16) + prodrude(10)
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: PulseFAB(
                onTap: () => TransactionBottomSheet.show(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarIcon({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BounceButton(
        onTap: onTap,
        scaleFactor: 0.8,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          transform: Matrix4.diagonal3Values(isActive ? 1.1 : 1.0, isActive ? 1.1 : 1.0, 1.0),
          transformAlignment: Alignment.center,
          child: Icon(
            icon,
            size: 28,
            color: isActive ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
