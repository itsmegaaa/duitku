import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PinIndicator extends StatelessWidget {
  final int length;
  final int currentIndex;
  final Color? activeColor;

  const PinIndicator({
    super.key,
    required this.length,
    required this.currentIndex,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isFilled = index < currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? color : Colors.transparent,
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          transform: Matrix4.diagonal3Values(isFilled ? 1.0 : 0.8, isFilled ? 1.0 : 0.8, 1.0),
          transformAlignment: Alignment.center,
        );
      }),
    );
  }
}

class PinNumpad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback? onBiometricPressed;
  final bool showBiometric;

  const PinNumpad({
    super.key,
    required this.onDigitPressed,
    required this.onDeletePressed,
    this.onBiometricPressed,
    this.showBiometric = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 16),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 16),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSpecialButton(
              icon: showBiometric ? Icons.fingerprint : null,
              onTap: showBiometric ? onBiometricPressed : null,
            ),
            _buildNumberButton('0'),
            _buildSpecialButton(
              icon: Icons.backspace_outlined,
              onTap: onDeletePressed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildNumberButton(d)).toList(),
    );
  }

  Widget _buildNumberButton(String digit) {
    return _PinButton(
      label: digit,
      onTap: () => onDigitPressed(digit),
    );
  }

  Widget _buildSpecialButton({IconData? icon, VoidCallback? onTap}) {
    if (icon == null) {
      return const SizedBox(width: 80, height: 80);
    }
    return _PinButton(
      icon: icon,
      onTap: onTap,
    );
  }
}

class _PinButton extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;

  const _PinButton({this.label, this.icon, this.onTap});

  @override
  State<_PinButton> createState() => _PinButtonState();
}

class _PinButtonState extends State<_PinButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.inputFill,
              border: Border.all(color: AppColors.inputBorder, width: 2),
            ),
            alignment: Alignment.center,
            child: widget.icon != null
                ? Icon(widget.icon, color: AppColors.textMain, size: 32)
                : Text(
                    widget.label!,
                    style: AppTextStyles.heading.copyWith(fontSize: 32),
                  ),
          ),
        ),
      ),
    );
  }
}
