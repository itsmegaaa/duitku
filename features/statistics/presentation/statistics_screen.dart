import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/presentation/components/glass_container.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _periodIndex = 1; // 0=Mingguan, 1=Bulanan, 2=Tahunan
  int _chartIndex = 0;  // 0=Pie, 1=Bar, 2=Line

  final List<String> _periods = ['Mingguan', 'Bulanan', 'Tahunan'];
  final List<String> _chartLabels = ['Kategori', 'Perbandingan', 'Tren'];

  // Dummy category data matching the transaction sheet colors
  static const List<Map<String, dynamic>> _categories = [
    {'label': 'Makanan', 'color': Color(0xFFFF7043), 'value': 35.0, 'amount': 1750000},
    {'label': 'Transport', 'color': Color(0xFF42A5F5), 'value': 20.0, 'amount': 1000000},
    {'label': 'Belanja', 'color': Color(0xFFEC407A), 'value': 18.0, 'amount': 900000},
    {'label': 'Tagihan', 'color': Color(0xFF78909C), 'value': 12.0, 'amount': 600000},
    {'label': 'Hiburan', 'color': Color(0xFFAB47BC), 'value': 10.0, 'amount': 500000},
    {'label': 'Kesehatan', 'color': Color(0xFF26A69A), 'value': 5.0, 'amount': 250000},
  ];

  @override
  Widget build(BuildContext context) {
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
                    Text('Statistik', style: AppTextStyles.heading.copyWith(fontSize: 24)),
                    const SizedBox(height: 24),

                    // Period Switcher (pill style)
                    _buildPeriodSwitcher(),
                    const SizedBox(height: 24),

                    // Summary Cards Row
                    _buildSummaryRow(),
                    const SizedBox(height: 24),

                    // Chart Type Switcher
                    _buildChartTypeSwitcher(),
                    const SizedBox(height: 16),

                    // Chart Area
                    _buildChartCard(),
                    const SizedBox(height: 24),

                    // Category Breakdown
                    Text('Pengeluaran per Kategori', style: AppTextStyles.heading),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Category List
            _buildCategoryList(),
            const SliverToBoxAdapter(child: SizedBox(height: 100)), // navbar spacing
          ],
        ),
      ),
    );
  }

  // ─── Period Switcher ───────────────────────────────────
  Widget _buildPeriodSwitcher() {
    return GlassContainer(
      padding: const EdgeInsets.all(4),
      borderRadius: 16,
      child: Row(
        children: List.generate(_periods.length, (index) {
          final isActive = _periodIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _periodIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  _periods[index],
                  style: AppTextStyles.body.copyWith(
                    color: isActive ? AppColors.background : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Summary Cards ─────────────────────────────────────
  Widget _buildSummaryRow() {
    return Row(
      children: [
        _buildSummaryCard('Pemasukan', 4200000, AppColors.success),
        const SizedBox(width: 12),
        _buildSummaryCard('Pengeluaran', 3100000, AppColors.danger),
        const SizedBox(width: 12),
        _buildSummaryCard('Saldo', 1100000, AppColors.primary),
      ],
    );
  }

  Widget _buildSummaryCard(String label, double amount, Color color) {
    final formatter = NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 1);
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11)),
            const SizedBox(height: 8),
            Text(
              formatter.format(amount),
              style: AppTextStyles.body.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Chart Type Switcher ───────────────────────────────
  Widget _buildChartTypeSwitcher() {
    return Row(
      children: List.generate(_chartLabels.length, (index) {
        final isActive = _chartIndex == index;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _chartIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.inputBorder,
                ),
              ),
              child: Text(
                _chartLabels[index],
                style: AppTextStyles.caption.copyWith(
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ─── Chart Card ────────────────────────────────────────
  Widget _buildChartCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      height: 260,
      child: _buildCurrentChart(),
    );
  }

  Widget _buildCurrentChart() {
    switch (_chartIndex) {
      case 0:
        return _buildPieChart();
      case 1:
        return _buildBarChart();
      case 2:
        return _buildLineChart();
      default:
        return const SizedBox();
    }
  }

  // ─── Pie Chart ─────────────────────────────────────────
  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 45,
        sections: _categories.map((cat) {
          return PieChartSectionData(
            color: cat['color'] as Color,
            value: cat['value'] as double,
            title: '${(cat['value'] as double).toInt()}%',
            radius: 55,
            titleStyle: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Bar Chart ─────────────────────────────────────────
  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'];
                if (value.toInt() >= labels.length) return const SizedBox();
                return SideTitleWidget(
                  meta: meta,
                  child: Text(labels[value.toInt()], style: AppTextStyles.caption.copyWith(fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(6, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: [8, 12, 10, 14, 9, 16][index].toDouble(),
                color: AppColors.primary,
                width: 12,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
              BarChartRodData(
                toY: [6, 8, 7, 10, 5, 12][index].toDouble(),
                color: const Color(0xFFB71C1C),
                width: 12,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ─── Line Chart ────────────────────────────────────────
  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3), FlSpot(1, 1.5), FlSpot(2, 4), FlSpot(3, 2.5),
              FlSpot(4, 5), FlSpot(5, 3.5), FlSpot(6, 6),
            ],
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: AppColors.primaryLight,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.25),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Category Breakdown List ───────────────────────────
  Widget _buildCategoryList() {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final cat = _categories[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12, left: 24, right: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: (cat['color'] as Color).withValues(alpha: 0.2),
                  child: Icon(Icons.circle, color: cat['color'] as Color, size: 16),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cat['label'] as String, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      // Mini progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (cat['value'] as double) / 100,
                          backgroundColor: AppColors.inputBorder,
                          color: cat['color'] as Color,
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatter.format(cat['amount']),
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text('${(cat['value'] as double).toInt()}%', style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          );
        },
        childCount: _categories.length,
      ),
    );
  }
}
