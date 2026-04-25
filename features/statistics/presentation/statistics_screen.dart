import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../application/statistics_provider.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  String _selectedPeriod = 'Bulanan';
  final List<String> _periods = ['Mingguan', 'Bulanan', 'Tahunan'];

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(statisticsSummaryProvider(_selectedPeriod));
    final categoriesAsync = ref.watch(categoryStatsProvider(_selectedPeriod));
    final barsAsync = ref.watch(monthlyBarsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPeriod,
                dropdownColor: AppColors.surface,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                style: AppTextStyles.body.copyWith(color: AppColors.primary),
                items: _periods.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedPeriod = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SUMMARY CARDS ---
            summaryAsync.when(
              data: (summary) => Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Pemasukan',
                      summary.income,
                      AppColors.success,
                      Icons.arrow_downward,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      'Pengeluaran',
                      summary.expense,
                      AppColors.danger,
                      Icons.arrow_upward,
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err', style: AppTextStyles.error)),
            ),

            const SizedBox(height: 32),

            // --- CATEGORY STATS ---
            Text('Pengeluaran per Kategori', style: AppTextStyles.heading),
            const SizedBox(height: 16),
            categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text('Belum ada data pengeluaran', style: AppTextStyles.caption),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return _buildCategoryItem(cat);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err', style: AppTextStyles.error)),
            ),

            const SizedBox(height: 32),

            // --- MONTHLY BARS ---
            Text('Tren 6 Bulan Terakhir', style: AppTextStyles.heading),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: barsAsync.when(
                data: (bars) {
                  if (bars.isEmpty) {
                     return Center(child: Text('Belum ada data tren', style: AppTextStyles.caption));
                  }
                  
                  // Simple bar chart layout using Row and Containers
                  double maxVal = 0;
                  for (var b in bars) {
                    if (b.income > maxVal) maxVal = b.income;
                    if (b.expense > maxVal) maxVal = b.expense;
                  }
                  if (maxVal == 0) maxVal = 1;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: bars.map((b) {
                      final incHeight = (b.income / maxVal) * 100;
                      final expHeight = (b.expense / maxVal) * 100;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: 8,
                                height: incHeight > 0 ? incHeight : 2,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 8,
                                height: expHeight > 0 ? expHeight : 2,
                                decoration: BoxDecoration(
                                  color: AppColors.danger,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(b.month, style: AppTextStyles.caption.copyWith(fontSize: 10)),
                        ],
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err', style: AppTextStyles.error)),
              ),
            ),
            const SizedBox(height: 80), // Padding for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currencyFormat.format(amount),
            style: AppTextStyles.heading.copyWith(
              color: color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(CategoryStat cat) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cat.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(cat.icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cat.name, style: AppTextStyles.body),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: cat.percentage / 100,
                  backgroundColor: AppColors.inputFill,
                  valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(cat.amount),
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${cat.percentage.toStringAsFixed(1)}%',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
