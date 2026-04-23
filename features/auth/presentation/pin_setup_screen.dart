import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/database/hive_service.dart';
import 'components/pin_numpad.dart';

enum PinSetupPhase { create, confirm, success }

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _pin1 = '';
  String _pin2 = '';
  PinSetupPhase _phase = PinSetupPhase.create;
  bool _isError = false;

  void _onDigitPressed(String digit) async {
    if (_phase == PinSetupPhase.success) return;

    setState(() {
      _isError = false;
      if (_phase == PinSetupPhase.create) {
        if (_pin1.length < 6) _pin1 += digit;
      } else if (_phase == PinSetupPhase.confirm) {
        if (_pin2.length < 6) _pin2 += digit;
      }
    });

    if (_phase == PinSetupPhase.create && _pin1.length == 6) {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _phase = PinSetupPhase.confirm;
      });
    } else if (_phase == PinSetupPhase.confirm && _pin2.length == 6) {
      if (_pin1 == _pin2) {
        setState(() => _phase = PinSetupPhase.success);
        await HiveService.setPinCode(_pin1);
        await HiveService.setIsPinActive(true);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) context.go('/');
      } else {
        setState(() {
          _isError = true;
          _pin2 = '';
        });
      }
    }
  }

  void _onDeletePressed() {
    if (_phase == PinSetupPhase.success) return;
    setState(() {
      _isError = false;
      if (_phase == PinSetupPhase.create && _pin1.isNotEmpty) {
        _pin1 = _pin1.substring(0, _pin1.length - 1);
      } else if (_phase == PinSetupPhase.confirm && _pin2.isNotEmpty) {
        _pin2 = _pin2.substring(0, _pin2.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == PinSetupPhase.success) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.network(
                'https://lottie.host/80bb6e2a-0a73-45ab-a70e-f00885e3f426/M1G8hD9XUv.json', // Placeholder checkmark
                width: 200,
                height: 200,
                repeat: false,
              ),
              const SizedBox(height: 16),
              Text('PIN Berhasil Dibuat!', style: AppTextStyles.heading),
            ],
          ),
        ),
      );
    }

    final currentPinLength = _phase == PinSetupPhase.create ? _pin1.length : _pin2.length;
    final title = _phase == PinSetupPhase.create ? 'Buat PIN 6 Angka' : 'Konfirmasi PIN';

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: AppTextStyles.heading),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _phase == PinSetupPhase.confirm
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _phase = PinSetupPhase.create;
                  _pin2 = '';
                  _isError = false;
                }),
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.go('/auth/login'),
              ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Text(
              'Gunakan PIN ini untuk membuka aplikasi',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PinIndicator(
              length: 6,
              currentIndex: currentPinLength,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 24,
              child: AnimatedOpacity(
                opacity: _isError ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Text('PIN tidak cocok, coba lagi', style: AppTextStyles.error),
              ),
            ),
            const Spacer(),
            PinNumpad(
              onDigitPressed: _onDigitPressed,
              onDeletePressed: _onDeletePressed,
              showBiometric: false, // Setup screen does not show biometric
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
