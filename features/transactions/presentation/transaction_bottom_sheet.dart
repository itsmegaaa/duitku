import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/presentation/components/glass_container.dart';
import '../../../core/presentation/components/bounce_button.dart';

class TransactionBottomSheet extends StatefulWidget {
  const TransactionBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TransactionBottomSheet(),
    );
  }

  @override
  State<TransactionBottomSheet> createState() => _TransactionBottomSheetState();
}

class _TransactionBottomSheetState extends State<TransactionBottomSheet> {
  final _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isIncome = false;
  int _selectedCategoryIndex = 0;
  DateTime _selectedDate = DateTime.now();

  static const List<Map<String, dynamic>> _categories = [
    {'icon': Icons.fastfood, 'label': 'Makanan', 'color': Color(0xFFFF7043)},
    {'icon': Icons.directions_car, 'label': 'Transport', 'color': Color(0xFF42A5F5)},
    {'icon': Icons.shopping_bag, 'label': 'Belanja', 'color': Color(0xFFEC407A)},
    {'icon': Icons.receipt_long, 'label': 'Tagihan', 'color': Color(0xFF78909C)},
    {'icon': Icons.sports_esports, 'label': 'Hiburan', 'color': Color(0xFFAB47BC)},
    {'icon': Icons.local_hospital, 'label': 'Kesehatan', 'color': Color(0xFF26A69A)},
    {'icon': Icons.work, 'label': 'Gaji', 'color': AppColors.primary},
    {'icon': Icons.trending_up, 'label': 'Investasi', 'color': Color(0xFF66BB6A)},
  ];

  @override
  void dispose() {
    _confettiController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal terlebih dahulu')),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    _confettiController.play();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          content: GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                const SizedBox(width: 12),
                Text(
                  '✅ Transaksi berhasil disimpan!',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatAmount(String raw) {
    if (raw.isEmpty) return '';
    final number = int.tryParse(raw.replaceAll('.', ''));
    if (number == null) return raw;
    return NumberFormat.decimalPattern('id_ID').format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                  left: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                  right: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.inputBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Title
                  Text(
                    'Tambah Transaksi',
                    style: AppTextStyles.heading,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Income/Expense Toggle
                  _buildTypeToggle(),
                  const SizedBox(height: 24),

                  // Amount Input
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nominal', style: AppTextStyles.caption),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: AppTextStyles.display.copyWith(fontSize: 32),
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: AppTextStyles.display.copyWith(
                              fontSize: 32,
                              color: AppColors.textSecondary.withValues(alpha: 0.3),
                            ),
                            prefixText: 'Rp ',
                            prefixStyle: AppTextStyles.heading.copyWith(color: AppColors.primary),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          onChanged: (value) {
                            final raw = value.replaceAll('.', '');
                            final formatted = _formatAmount(raw);
                            if (formatted != value) {
                              _amountController.value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(offset: formatted.length),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category Selector
                  Text('Kategori', style: AppTextStyles.caption),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _categories.length,
                      separatorBuilder: (context, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategoryIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategoryIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 72,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (cat['color'] as Color).withValues(alpha: 0.2)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? cat['color'] as Color
                                    : AppColors.inputBorder,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 28),
                                const SizedBox(height: 4),
                                Text(
                                  cat['label'] as String,
                                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Date Picker
                  GestureDetector(
                    onTap: _pickDate,
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate),
                            style: AppTextStyles.body,
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Note Input
                  TextField(
                    controller: _noteController,
                    maxLines: 2,
                    style: const TextStyle(color: AppColors.textMain),
                    decoration: const InputDecoration(
                      hintText: 'Catatan (opsional)',
                      prefixIcon: Icon(Icons.note_alt_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Attachment (Foto Struk)
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur foto struk akan segera hadir')),
                      );
                    },
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Text('Lampirkan foto struk', style: AppTextStyles.body),
                          const Spacer(),
                          const Icon(Icons.add_a_photo, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: BounceButton(
                      onTap: _handleSave,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        child: Text(
                          'Simpan Transaksi',
                          style: AppTextStyles.buttonLabel.copyWith(
                            color: AppColors.background,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),

        // Confetti at top center
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 30,
            gravity: 0.1,
            emissionFrequency: 0.05,
            colors: const [AppColors.primary, AppColors.accent, Colors.white, Color(0xFF0A0A0A)],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeToggle() {
    return Row(
      children: [
        Expanded(
          child: BounceButton(
            onTap: () => setState(() => _isIncome = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: !_isIncome ? const Color(0xFFB71C1C).withValues(alpha: 0.15) : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: !_isIncome ? const Color(0xFFB71C1C) : AppColors.inputBorder,
                  width: !_isIncome ? 2 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_circle, color: !_isIncome ? const Color(0xFFB71C1C) : AppColors.textSecondary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Pengeluaran',
                    style: AppTextStyles.body.copyWith(
                      color: !_isIncome ? const Color(0xFFB71C1C) : AppColors.textSecondary,
                      fontWeight: !_isIncome ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: BounceButton(
            onTap: () => setState(() => _isIncome = true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _isIncome ? AppColors.success.withValues(alpha: 0.15) : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isIncome ? AppColors.success : AppColors.inputBorder,
                  width: _isIncome ? 2 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle, color: _isIncome ? AppColors.success : AppColors.textSecondary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Pemasukan',
                    style: AppTextStyles.body.copyWith(
                      color: _isIncome ? AppColors.success : AppColors.textSecondary,
                      fontWeight: _isIncome ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
