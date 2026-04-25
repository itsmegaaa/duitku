import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/presentation/components/glass_container.dart';
import '../../../core/presentation/components/animated_counter.dart';
import '../../../core/presentation/components/bounce_button.dart';
import '../../../core/presentation/components/shimmer_widget.dart';
import '../application/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  void _showProfileModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final profileAsync = ref.watch(activeProfileProvider);
          final profile = profileAsync.value;

          return GlassContainer(
            padding: const EdgeInsets.all(24),
            borderRadius: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.background,
                  ),
                ),
                const SizedBox(height: 16),
                Text(profile?.name ?? 'Pengguna', style: AppTextStyles.heading),
                Text(profile?.email ?? '-', style: AppTextStyles.caption),
                const SizedBox(height: 24),
                BounceButton(
                  onTap: () {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur Edit Profil belum tersedia'),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Edit Profil',
                      style: AppTextStyles.buttonLabel.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                BounceButton(
                  onTap: () async {
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
                    child: Text(
                      'Keluar',
                      style: AppTextStyles.buttonLabel.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    _buildHeader(context, ref),
                    const SizedBox(height: 32),
                    _buildHeroCard(ref),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 32),
                    _buildSparklineChart(ref),
                    const SizedBox(height: 32),
                    _buildTransactionsHeader(),
                  ],
                ),
              ),
            ),
            _buildTransactionsList(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(activeProfileProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profileAsync.when(
              data: (profile) {
                final firstName = profile?.name.split(' ').first ?? 'Pengguna';
                return Text(
                  '${_getGreeting()}, $firstName! ☀️',
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.primary,
                  ),
                );
              },
              loading: () => const ShimmerWidget(width: 150, height: 24),
              error: (_, _) => Text(
                'Selamat datang! ☀️',
                style: AppTextStyles.heading.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Yuk, catat keuanganmu hari ini',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showProfileModal(context, ref),
          child: const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.surface,
            child: Icon(Icons.person, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(WidgetRef ref) {
    final summaryAsync = ref.watch(homeSummaryProvider);
    final formatter = NumberFormat.compactCurrency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 1,
    );

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
                  colors: [
                    AppColors.primary.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Saldo',
                style: AppTextStyles.caption.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),
              summaryAsync.when(
                data: (summary) => AnimatedCounter(
                  value: (summary['balance'] as num?)?.toDouble() ?? 0.0,
                  style: AppTextStyles.display,
                ),
                loading: () => const ShimmerWidget(width: 200, height: 40),
                error: (_, _) => Text('Rp 0', style: AppTextStyles.display),
              ),
              const SizedBox(height: 24),
              summaryAsync.when(
                data: (summary) {
                  final income = summary['monthIncome'] ?? 0;
                  final expense = summary['monthExpense'] ?? 0;
                  return Row(
                    children: [
                      _buildChip(
                        Icons.arrow_downward,
                        'Pemasukan',
                        '+${formatter.format(income)}',
                        AppColors.success,
                      ),
                      const SizedBox(width: 16),
                      _buildChip(
                        Icons.arrow_upward,
                        'Pengeluaran',
                        '-${formatter.format(expense)}',
                        AppColors.danger,
                      ),
                    ],
                  );
                },
                loading: () => const Row(
                  children: [
                    Expanded(
                      child: ShimmerWidget(
                        width: double.infinity,
                        height: 60,
                        borderRadius: 12,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ShimmerWidget(
                        width: double.infinity,
                        height: 60,
                        borderRadius: 12,
                      ),
                    ),
                  ],
                ),
                error: (_, _) => const SizedBox(),
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
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
            ),
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
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur Pemasukan belum aktif')),
            ),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Pemasukan',
                    style: AppTextStyles.buttonLabel.copyWith(
                      color: AppColors.primary,
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
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur Pengeluaran belum aktif')),
            ),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.remove_circle, color: Color(0xFFB71C1C)),
                  const SizedBox(width: 8),
                  Text(
                    'Pengeluaran',
                    style: AppTextStyles.buttonLabel.copyWith(
                      color: const Color(0xFFB71C1C),
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

  Widget _buildSparklineChart(WidgetRef ref) {
    final spotsAsync = ref.watch(sparklineDataProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pengeluaran 7 Hari', style: AppTextStyles.heading),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          height: 120,
          child: spotsAsync.when(
            data: (spots) {
              if (spots.isEmpty || spots.every((s) => s.y == 0)) {
                return Center(
                  child: Text(
                    'Belum ada data pengeluaran',
                    style: AppTextStyles.caption,
                  ),
                );
              }
              return LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
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
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (_, _) => Center(
              child: Text(
                'Gagal memuat grafik',
                style: AppTextStyles.caption.copyWith(color: AppColors.danger),
              ),
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
        Text(
          'Lihat Semua',
          style: AppTextStyles.caption.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildTransactionsList(WidgetRef ref) {
    final transactionsAsync = ref.watch(recentTransactionsProvider);
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'Belum ada transaksi.',
                  style: AppTextStyles.caption,
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final txData = transactions[index];
            final tx = txData.transaction;
            final isIncome = tx.type == 'Pemasukan' || tx.type == 'income';

            return Dismissible(
              key: ValueKey('tx_${tx.id}'),
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
                      backgroundColor: txData.categoryColor.withValues(
                        alpha: 0.2,
                      ),
                      child: Text(
                        txData.categoryIcon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            txData.categoryName,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            tx.note ??
                                DateFormat('dd MMM, HH:mm').format(tx.date),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${isIncome ? '+' : '-'}${formatter.format(tx.amount)}',
                      style: AppTextStyles.body.copyWith(
                        color: isIncome ? AppColors.success : AppColors.danger,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }, childCount: transactions.length),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ),
      error: (err, stack) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'Gagal memuat transaksi.',
              style: AppTextStyles.caption.copyWith(color: AppColors.danger),
            ),
          ),
        ),
      ),
    );
  }
}
