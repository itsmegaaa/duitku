import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/presentation/components/glass_container.dart';
import '../../../core/presentation/components/particles_background.dart';
import '../application/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  
  bool _isObscured = true;
  bool _isLoading = false;
  double _strength = 0; // 0.0 to 1.0
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
  }

  void _checkPasswordStrength() {
    final pass = _passwordController.text;
    double s = 0;
    if (pass.length > 5) s += 0.3;
    if (pass.contains(RegExp(r'[A-Z]'))) s += 0.3;
    if (pass.contains(RegExp(r'[0-9]'))) s += 0.4;
    setState(() => _strength = s);
  }

  void _handleRegister() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua field harus diisi')));
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      setState(() => _errorMsg = 'Password tidak cocok');
      return;
    }
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password minimal 6 karakter')));
      return;
    }
    setState(() { _errorMsg = ''; _isLoading = true; });

    try {
      await ref.read(authProvider.notifier).registerWithEmail(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      context.go('/auth/pin-setup');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getStrengthColor() {
    if (_strength < 0.4) return AppColors.danger;
    if (_strength < 0.8) return AppColors.accent; // yellow
    return AppColors.success; // green
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Lottie.network(
                'https://lottie.host/78c73c88-e2eb-4581-bdd2-44243bfa9900/40IfP90S7A.json', 
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Positioned.fill(
            child: ParticlesBackground(child: SizedBox()),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    '🪙 DuitKu',
                    style: AppTextStyles.display.copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Daftar akun baru',
                    style: AppTextStyles.heading,
                  ),
                  const SizedBox(height: 32),
                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(color: AppColors.textMain),
                          decoration: const InputDecoration(
                            hintText: 'Nama Lengkap',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: AppColors.textMain),
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _isObscured,
                          style: const TextStyle(color: AppColors.textMain),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _isObscured = !_isObscured),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Password Strength Indicator
                        Row(
                          children: [
                            Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 4,
                                decoration: BoxDecoration(
                                  color: _passwordController.text.isNotEmpty ? _getStrengthColor() : Colors.transparent,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                alignment: Alignment.centerLeft,
                                child: LayoutBuilder(
                                  builder: (context, constraints) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: constraints.maxWidth * _strength,
                                    color: _getStrengthColor(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _confirmController,
                          obscureText: _isObscured,
                          style: const TextStyle(color: AppColors.textMain),
                          decoration: const InputDecoration(
                            hintText: 'Konfirmasi Password',
                            prefixIcon: Icon(Icons.lock_reset),
                          ),
                        ),
                        
                        // Error message animation
                        AnimatedOpacity(
                          opacity: _errorMsg.isEmpty ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(_errorMsg, style: AppTextStyles.error),
                          ),
                        ),

                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryLight],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: AppColors.background, strokeWidth: 2),
                                  )
                                : Text(
                                    'Buat Akun',
                                    style: AppTextStyles.buttonLabel.copyWith(
                                      color: AppColors.background,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Sudah punya akun? ', style: AppTextStyles.caption),
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: Text(
                                'Masuk',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
