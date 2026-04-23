import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/presentation/components/particles_background.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Selamat Datang di DuitKu',
      'desc': 'Aplikasi pencatatan keuangan harian yang cerdas, aman, dan mudah digunakan',
      'lottie': 'https://lottie.host/9e4d01b1-6a0b-426b-bf78-1a4c9b3a37ba/sT49g5r4Lg.json', // Placeholder Wallet
    },
    {
      'title': 'Pantau Keuangan Real-time',
      'desc': 'Grafik interaktif, laporan bulanan, dan kategori lengkap membantu kamu memahami pola pengeluaran',
      'lottie': 'https://lottie.host/1c4d92ee-4475-4be4-a621-e0c3886bedc1/Q1tU538wJ2.json', // Placeholder Chart
    },
    {
      'title': 'Keamanan Berlapis',
      'desc': 'Data kamu dilindungi dengan PIN, sidik jari, dan enkripsi cloud. Hanya kamu yang bisa mengakses',
      'lottie': 'https://lottie.host/a98019b8-6725-4b19-b223-14902cd5605d/Xg7w8J1a0M.json', // Placeholder Secure
    },
    {
      'title': 'Siap Mulai?',
      'desc': 'Bergabung sekarang dan mulai perjalanan finansialmu bersama DuitKu',
      'lottie': 'https://lottie.host/b04ab60b-923f-4df4-a823-efd0b67812f8/pXqXzZ0K1l.json', // Placeholder Rocket
    },
  ];

  void _finishOnboarding() async {
    await HiveService.setHasSeenOnboarding(true);
    if (mounted) context.go('/auth/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParticlesBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) => setState(() => _currentIndex = index),
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    return _buildSlide(_slides[index]);
                  },
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_currentIndex != _slides.length - 1)
            TextButton(
              onPressed: _finishOnboarding,
              child: Text(
                'Lewati',
                style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.normal),
              ),
            )
          else
            const SizedBox(height: 48), // Match TextButton height
        ],
      ),
    );
  }

  Widget _buildSlide(Map<String, String> data) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Lottie.network(
              data['lottie']!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 100, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            data['title']!,
            style: AppTextStyles.heading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data['desc']!,
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final isLast = _currentIndex == _slides.length - 1;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: isLast
          ? _buildStartButton()
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index ? AppColors.primary : AppColors.inputBorder,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _finishOnboarding,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Mulai Sekarang',
          style: AppTextStyles.buttonLabel.copyWith(
              color: AppColors.background, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
