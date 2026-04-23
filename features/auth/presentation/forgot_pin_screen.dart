import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/presentation/components/glass_container.dart';
import 'components/pin_numpad.dart';

class ForgotPinScreen extends StatefulWidget {
  const ForgotPinScreen({super.key});

  @override
  State<ForgotPinScreen> createState() => _ForgotPinScreenState();
}

class _ForgotPinScreenState extends State<ForgotPinScreen> {
  final PageController _pageController = PageController();
  
  // Step 1
  final _emailController = TextEditingController();
  
  // Step 2
  final _otpController = TextEditingController();
  int _countdown = 59;
  Timer? _timer;
  
  // Step 3
  String _newPin1 = '';
  String _newPin2 = '';
  int _pinPhase = 0; // 0 = create, 1 = confirm, 2 = success

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _startOtpTimer() {
    setState(() => _countdown = 59);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  void _handleSendCode() {
    if (_emailController.text.isNotEmpty) {
      _nextPage(); // Go to OTP
      _startOtpTimer();
    }
  }

  void _handlePinDigit(String digit) async {
    if (_pinPhase == 2) return;

    setState(() {
      if (_pinPhase == 0) {
        if (_newPin1.length < 6) _newPin1 += digit;
      } else if (_pinPhase == 1) {
        if (_newPin2.length < 6) _newPin2 += digit;
      }
    });

    if (_pinPhase == 0 && _newPin1.length == 6) {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() => _pinPhase = 1);
    } else if (_pinPhase == 1 && _newPin2.length == 6) {
      if (_newPin1 == _newPin2) {
        setState(() => _pinPhase = 2);
        await HiveService.setPinCode(_newPin1);
        _nextPage(); // Go to success
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) context.go('/auth/pin-lock');
      } else {
        setState(() => _newPin2 = ''); // reset and error
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN tidak cocok, coba lagi')));
      }
    }
  }

  void _handlePinDelete() {
    setState(() {
      if (_pinPhase == 0 && _newPin1.isNotEmpty) {
        _newPin1 = _newPin1.substring(0, _newPin1.length - 1);
      } else if (_pinPhase == 1 && _newPin2.isNotEmpty) {
        _newPin2 = _newPin2.substring(0, _newPin2.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset PIN', style: AppTextStyles.heading),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildStep1Email(),
          _buildStep2OTP(),
          _buildStep3NewPin(),
          _buildStep4Success(),
        ],
      ),
    );
  }

  Widget _buildStep1Email() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Masukkan email akunmu, kami akan kirim kode verifikasi OTP.',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: AppColors.textMain),
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _handleSendCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    'Kirim Kode',
                    style: AppTextStyles.buttonLabel.copyWith(
                      color: AppColors.background,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep2OTP() {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: AppTextStyles.heading.copyWith(fontSize: 24, color: AppColors.primary),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
        child: Column(
          children: [
            const Spacer(),
            Text('Kode OTP telah dikirim', style: AppTextStyles.heading),
            const SizedBox(height: 8),
            Text(
              'Masukkan 6 digit kode OTP dari email kamu.',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Pinput(
              length: 6,
              controller: _otpController,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyDecorationWith(
                border: Border.all(color: AppColors.primary),
              ),
              onCompleted: (pin) {
                // Mock verify
                if (pin.length == 6) _nextPage();
              },
            ),
            const SizedBox(height: 32),
            if (_countdown > 0)
              Text('Kirim ulang dalam $_countdown detik', style: AppTextStyles.caption)
            else
              GestureDetector(
                onTap: _startOtpTimer,
                child: Text(
                  'Kirim Ulang Kode Berhasil',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primary, decoration: TextDecoration.underline),
                ),
              ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3NewPin() {
    final currentLength = _pinPhase == 0 ? _newPin1.length : _newPin2.length;
    final titleLabel = _pinPhase == 0 ? 'Buat PIN Baru' : 'Konfirmasi PIN';

    return SafeArea(
      child: Column(
        children: [
          const Spacer(),
          Text(titleLabel, style: AppTextStyles.heading),
          const SizedBox(height: 8),
          Text(
            'Gunakan PIN ini untuk membuka aplikasi',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PinIndicator(length: 6, currentIndex: currentLength),
          const Spacer(),
          PinNumpad(
            onDigitPressed: _handlePinDigit,
            onDeletePressed: _handlePinDelete,
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildStep4Success() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(
            'https://lottie.host/80bb6e2a-0a73-45ab-a70e-f00885e3f426/M1G8hD9XUv.json', // Placeholder checkmark unlocked
            width: 200,
            height: 200,
            repeat: false,
          ),
          const SizedBox(height: 16),
          Text('PIN berhasil direset!', style: AppTextStyles.heading),
        ],
      ),
    );
  }
}
