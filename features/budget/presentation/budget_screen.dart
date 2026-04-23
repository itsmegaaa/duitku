import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/presentation/components/glass_container.dart';
import '../../../core/presentation/components/bounce_button.dart';
import '../../../core/presentation/components/animated_counter.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  // Dummy budget data
  static final List<Map<String, dynamic>> _budgets = [
    {'icon': Icons.fastfood, 'label': 'Makanan', 'color': const Color(0xFFFF7043), 'limit': 2000000, 'spent': 1750000},
    {'icon': Icons.directions_car, 'label': 'Transport', 'color': const Color(0xFF42A5F5), 'limit': 1000000, 'spent': 450000},
    {'icon': Icons.shopping_bag, 'label': 'Belanja', 'color': const Color(0xFFEC407A), 'limit': 1500000, 'spent': 1400000},
    {'icon': Icons.receipt_long, 'label': 'Tagihan', 'color': const Color(0xFF78909C), 'limit': 800000, 'spent': 800000},
    {'icon': Icons.sports_esports, 'label': 'Hiburan', 'color': const Color(0xFFAB47BC), 'limit': 500000, 'spent': 200000},
    {'icon': Icons.local_hospital, 'label': 'Kesehatan', 'color': const Color(0xFF26A69A), 'limit': 300000, 'spent': 50000},
  ];

  double get _totalLimit => _budgets.fold(0, (sum, b) => sum + (b['limit'] as int));
  double get _totalSpent => _budgets.fold(0, (sum, b) => sum + (b['spent'] as int));

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Budget Bulanan', style: AppTextStyles.heading.copyWith(fontSize: 24)),
                        BounceButton(
                          onTap: _showAddBudgetDialog,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: const Icon(Icons.add, color: AppColors.primary, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Overview Card
                    _buildOverviewCard(formatter),
                    const SizedBox(height: 24),

                    // Section Title
                    Text('Detail per Kategori', style: AppTextStyles.heading),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Budget Cards
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final budget = _budgets[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12, left: 24, right: 24),
                    child: _BudgetCard(
                      icon: budget['icon'] as IconData,
                      label: budget['label'] as String,
                      color: budget['color'] as Color,
                      limit: (budget['limit'] as int).toDouble(),
                      spent: (budget['spent'] as int).toDouble(),
                      formatter: formatter,
                    ),
                  );
                },
                childCount: _budgets.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)), // navbar spacing
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(NumberFormat formatter) {
    final percentage = _totalSpent / _totalLimit;
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Budget Terpakai', style: AppTextStyles.caption.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedCounter(
                value: _totalSpent,
                style: AppTextStyles.display.copyWith(fontSize: 28),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '/ ${formatter.format(_totalLimit)}',
                  style: AppTextStyles.caption.copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Overall progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percentage.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppColors.inputBorder,
                  color: _getProgressColor(value),
                  minHeight: 10,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(percentage * 100).toInt()}% terpakai bulan ini',
            style: AppTextStyles.caption.copyWith(
              color: _getProgressColor(percentage),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Tambah Budget', style: AppTextStyles.heading, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextField(
                style: const TextStyle(color: AppColors.textMain),
                decoration: const InputDecoration(
                  hintText: 'Nama Kategori',
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textMain),
                decoration: const InputDecoration(
                  hintText: 'Limit per Bulan (Rp)',
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text('Simpan', style: AppTextStyles.buttonLabel.copyWith(color: AppColors.background)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _getProgressColor(double percentage) {
    if (percentage >= 0.9) return AppColors.danger;
    if (percentage >= 0.7) return const Color(0xFFFF9800); // orange
    return AppColors.primary; // gold
  }
}

// ─── Individual Budget Card ──────────────────────────────
class _BudgetCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double limit;
  final double spent;
  final NumberFormat formatter;

  const _BudgetCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.limit,
    required this.spent,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (spent / limit).clamp(0.0, 1.0);
    final isOverBudget = spent >= limit;
    final progressColor = _BudgetScreenState._getProgressColor(percentage);

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                    Text(
                      '${formatter.format(spent)} / ${formatter.format(limit)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              // Percentage badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: progressColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${(percentage * 100).toInt()}%',
                  style: AppTextStyles.caption.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Animated Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percentage),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppColors.inputBorder,
                  color: progressColor,
                  minHeight: 8,
                );
              },
            ),
          ),

          // Warning if over budget
          if (isOverBudget) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Budget sudah terlampaui!',
                  style: AppTextStyles.caption.copyWith(color: AppColors.danger, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
