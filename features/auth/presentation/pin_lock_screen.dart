import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/presentation/components/glass_container.dart';
import 'components/pin_numpad.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  bool _isError = false;
  int _wrongAttempts = 0;
  bool _isLockedOut = false;
  int _countdown = 30;
  Timer? _timer;
  
  late AnimationController _shakeController;
  late Animation<Offset> _shakeAnimation;

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Simple shake tween
    _shakeAnimation = TweenSequence<Offset>([
      TweenSequenceItem(tween: Tween(begin: Offset.zero, end: const Offset(0.1, 0)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: const Offset(0.1, 0), end: const Offset(-0.1, 0)), weight: 2),
      TweenSequenceItem(tween: Tween(begin: const Offset(-0.1, 0), end: const Offset(0.1, 0)), weight: 2),
      TweenSequenceItem(tween: Tween(begin: const Offset(0.1, 0), end: const Offset(-0.1, 0)), weight: 2),
      TweenSequenceItem(tween: Tween(begin: const Offset(-0.1, 0), end: Offset.zero), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      if (canCheck && isSupported && mounted) {
        setState(() => _canCheckBiometrics = true);
        _promptBiometrics();
      }
    } catch (e) {
      debugPrint('Biometrics error: $e');
    }
  }

  Future<void> _promptBiometrics() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Gunakan biometrik untuk membuka DuitKu',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      if (authenticated && mounted) {
        context.go('/');
      }
    } catch (e) {
      debugPrint('Auth err: $e');
    }
  }

  void _onDigitPressed(String digit) async {
    if (_isLockedOut || _pin.length >= 6) return;
    
    setState(() {
      _isError = false;
      _pin += digit;
    });

    if (_pin.length == 6) {
      await Future.delayed(const Duration(milliseconds: 200));
      _verifyPin();
    }
  }

  void _verifyPin() {
    final savedPin = HiveService.pinCode;
    
    // Fallback if somehow pinCode is null (should not be possible by router)
    if (_pin == savedPin || savedPin == null) {
      setState(() => _wrongAttempts = 0);
      context.go('/');
    } else {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0.0);
      setState(() {
        _isError = true;
        _pin = '';
        _wrongAttempts++;
      });

      if (_wrongAttempts >= 10) {
        _lockOut();
      }
    }
  }

  void _onDeletePressed() {
    if (_isLockedOut) return;
    setState(() {
      _isError = false;
      if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  void _lockOut() {
    setState(() {
      _isLockedOut = true;
      _countdown = 30;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        setState(() {
          _isLockedOut = false;
          _wrongAttempts = 0;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF8B6914), AppColors.background],
                center: Alignment.center,
                radius: 1.2,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.surface,
                  child: Icon(Icons.person, size: 40, color: AppColors.primary), // Placeholder Avatar
                ),
                const SizedBox(height: 16),
                Text(
                  'Selamat datang kembali!',
                  style: AppTextStyles.heading,
                ),
                const SizedBox(height: 32),
                
                // Shake indicator
                SlideTransition(
                  position: _shakeAnimation,
                  child: PinIndicator(
                    length: 6,
                    currentIndex: _pin.length,
                    activeColor: _isError || _isLockedOut ? AppColors.danger : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 64),
                
                // Numpad
                PinNumpad(
                  onDigitPressed: _onDigitPressed,
                  onDeletePressed: _onDeletePressed,
                  showBiometric: _canCheckBiometrics,
                  onBiometricPressed: _promptBiometrics,
                ),
                const Spacer(),
                
                GestureDetector(
                  onTap: () {
                    if (!_isLockedOut) {
                      context.push('/auth/forgot-pin');
                    }
                  },
                  child: Text(
                    'Lupa PIN?',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          if (_isLockedOut)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(color: Colors.black.withValues(alpha: 0.4)),
              ),
            ),
            
          if (_isLockedOut)
            Center(
              child: GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_clock, size: 48, color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Terlalu banyak percobaan.',
                      style: AppTextStyles.heading,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Coba lagi dalam $_countdown detik',
                      style: AppTextStyles.display.copyWith(fontSize: 24),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
