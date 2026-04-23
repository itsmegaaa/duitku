import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/presentation/components/glass_container.dart';
import '../../../core/presentation/components/animated_counter.dart';
import '../../../core/presentation/components/bounce_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  void _showProfileModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 40, backgroundColor: AppColors.primary, child: Icon(Icons.person, size: 40, color: AppColors.background)),
            const SizedBox(height: 16),
            Text('Budi Santoso', style: AppTextStyles.heading),
            Text('budi@example.com', style: AppTextStyles.caption),
            const SizedBox(height: 24),
            BounceButton(
              onTap: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil diklik (Dummy)')));
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text('Edit Profil', style: AppTextStyles.buttonLabel.copyWith(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 16),
            BounceButton(
              onTap: () {
                context.pop();
                context.go('/auth/login');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text('Keluar', style: AppTextStyles.buttonLabel.copyWith(color: AppColors.danger)),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 32),
                    _buildHeroCard(),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 32),
                    _buildSparklineChart(),
                    const SizedBox(height: 32),
                    _buildTransactionsHeader(),
                  ],
                ),
              ),
            ),
            _buildTransactionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getGreeting()}, Budi! ☀️',
              style: AppTextStyles.heading.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              'Yuk, catat keuanganmu hari ini',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showProfileModal(context),
          child: const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.surface,
            child: Icon(Icons.person, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.primary.withValues(alpha: 0.3), Colors.transparent],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Saldo', style: AppTextStyles.caption.copyWith(fontSize: 14)),
              const SizedBox(height: 8),
              AnimatedCounter(
                value: 12500000,
                style: AppTextStyles.display,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildChip(Icons.arrow_downward, 'Pemasukan', '+Rp 4.2M', AppColors.success),
                  const SizedBox(width: 16),
                  _buildChip(Icons.arrow_upward, 'Pengeluaran', '-Rp 1.1M', AppColors.danger),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, String amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(label, style: AppTextStyles.caption.copyWith(color: color)),
              ],
            ),
            const SizedBox(height: 4),
            Text(amount, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BounceButton(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Pemasukan belum aktif'))),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Pemasukan', style: AppTextStyles.buttonLabel.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: BounceButton(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Pengeluaran belum aktif'))),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.remove_circle, color: Color(0xFFB71C1C)),
                  const SizedBox(width: 8),
                  Text('Pengeluaran', style: AppTextStyles.buttonLabel.copyWith(color: const Color(0xFFB71C1C))),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSparklineChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Statistik 7 Hari', style: AppTextStyles.heading),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          height: 120,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 3),
                    FlSpot(1, 1),
                    FlSpot(2, 4),
                    FlSpot(3, 2),
                    FlSpot(4, 5),
                    FlSpot(5, 3),
                    FlSpot(6, 6),
                  ],
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Transaksi Terbaru', style: AppTextStyles.heading),
        Text('Lihat Semua', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
      ],
    );
  }

  Widget _buildTransactionsList() {
    final Map<String, dynamic> dummyData = {
      'icon': Icons.fastfood,
      'title': 'Makan Siang',
      'date': 'Hari ini, 12:30',
      'amount': '-Rp 45.000',
      'isIncome': false,
    };
    
    final dummyTransactions = List.generate(10, (index) => dummyData);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final tx = dummyTransactions[index];
          return Dismissible(
            key: ValueKey('tx_$index'),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              HapticFeedback.mediumImpact();
            },
            background: Container(
              margin: const EdgeInsets.only(bottom: 12, left: 24, right: 24),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Container(
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
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: Icon(tx['icon'], color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tx['title'], style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                        Text(tx['date'], style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  Text(
                    tx['amount'],
                    style: AppTextStyles.body.copyWith(
                      color: tx['isIncome'] ? AppColors.success : AppColors.danger,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: dummyTransactions.length,
      ),
    );
  }
}
