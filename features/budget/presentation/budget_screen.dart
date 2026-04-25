import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/presentation/components/glass_container.dart';
import '../../../core/presentation/components/bounce_button.dart';
import '../../../core/presentation/components/animated_counter.dart';
import '../../../core/presentation/components/shimmer_widget.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/database/database_service.dart';
import '../../transactions/domain/category_model.dart';
import '../application/budget_provider.dart';
import '../domain/budget_model.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  // BAGIAN 4b: Fungsi Simpan Budget Nyata
  void _saveBudget(String categoryId, double limit) async {
    final profileId = HiveService.activeProfileId;
    if (profileId == null) return;

    final now = DateTime.now();
    final budget = BudgetModel(
      id: const Uuid().v4(),
      profileId: profileId,
      categoryId: categoryId,
      amountLimit: limit,
      month: now.month,
      year: now.year,
    );

    // Menyimpan ke database lokal (SQLite)
    final db = await DatabaseService().database;
    await db.insert('budgets', budget.toMap());

    // Sinkronisasi ke Firestore (Jika FirebaseSyncService sudah ada)
    // await FirestoreSyncService.syncBudget(budget.toMap());

    // Refresh UI
    ref.invalidate(budgetsWithSpendingProvider);
  }

  void _showAddBudgetDialog() async {
    // 1. Ambil daftar kategori dari database untuk Dropdown
    final db = await DatabaseService().database;
    final profileId = HiveService.activeProfileId;
    final catRes = await db.query(
      'categories',
      where: 'profileId = ? OR profileId IS NULL',
      whereArgs: [profileId],
    );
    final categories = catRes.map((e) => CategoryModel.fromMap(e)).toList();

    if (!mounted) return;

    CategoryModel? selectedCategory;
    final limitController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Tambah Budget',
                    style: AppTextStyles.heading,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Dropdown Kategori
                  DropdownButtonFormField<CategoryModel>(
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(color: AppColors.textMain),
                    decoration: InputDecoration(
                      hintText: 'Pilih Kategori',
                      prefixIcon: const Icon(
                        Icons.category,
                        color: AppColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.inputBorder,
                        ),
                      ),
                    ),
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text('${cat.icon} ${cat.name}'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedCategory = val),
                  ),
                  const SizedBox(height: 16),

                  // Input Limit
                  TextField(
                    controller: limitController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textMain),
                    decoration: InputDecoration(
                      hintText: 'Limit per Bulan (Rp)',
                      prefixIcon: const Icon(
                        Icons.monetization_on_outlined,
                        color: AppColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.inputBorder,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Simpan
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedCategory != null &&
                            limitController.text.isNotEmpty) {
                          final limit =
                              double.tryParse(limitController.text) ?? 0;
                          _saveBudget(selectedCategory!.id, limit);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(
                        'Simpan',
                        style: AppTextStyles.buttonLabel.copyWith(
                          color: AppColors.background,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final budgetsAsync = ref.watch(budgetsWithSpendingProvider);

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
                        Text(
                          'Budget Bulanan',
                          style: AppTextStyles.heading.copyWith(fontSize: 24),
                        ),
                        BounceButton(
                          onTap: _showAddBudgetDialog,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Overview Card Dynamic
                    budgetsAsync.when(
                      data: (budgets) {
                        double totalLimit = 0;
                        double totalSpent = 0;
                        for (var b in budgets) {
                          totalLimit += b.budget.amountLimit;
                          totalSpent += b.spent;
                        }
                        return _buildOverviewCard(
                          totalLimit,
                          totalSpent,
                          formatter,
                        );
                      },
                      loading: () => const ShimmerWidget(
                        width: double.infinity,
                        height: 180,
                        borderRadius: 16,
                      ),
                      error: (_, _) => const SizedBox(),
                    ),
                    const SizedBox(height: 24),

                    // Section Title
                    Text('Detail per Kategori', style: AppTextStyles.heading),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Budget Cards Dynamic
            budgetsAsync.when(
              data: (budgets) {
                if (budgets.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'Belum ada budget untuk bulan ini.',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = budgets[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12,
                        left: 24,
                        right: 24,
                      ),
                      child: _BudgetCard(item: item, formatter: formatter),
                    );
                  }, childCount: budgets.length),
                );
              },
              loading: () => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: List.generate(
                      3,
                      (index) => const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: ShimmerWidget(
                          width: double.infinity,
                          height: 90,
                          borderRadius: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              error: (_, _) => SliverToBoxAdapter(
                child: Center(
                  child: Text(
                    'Gagal memuat budget',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ), // navbar spacing
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(
    double totalLimit,
    double totalSpent,
    NumberFormat formatter,
  ) {
    final percentage = totalLimit > 0 ? (totalSpent / totalLimit) : 0.0;

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Budget Terpakai',
            style: AppTextStyles.caption.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedCounter(
                value: totalSpent.toDouble(),
                style: AppTextStyles.display.copyWith(fontSize: 28),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '/ ${formatter.format(totalLimit)}',
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

  static Color _getProgressColor(double percentage) {
    if (percentage >= 0.9) return AppColors.danger;
    if (percentage >= 0.7) return const Color(0xFFFF9800); // orange
    return AppColors.primary; // gold
  }
}

// ─── Individual Budget Card ──────────────────────────────
class _BudgetCard extends StatelessWidget {
  final BudgetWithSpending item;
  final NumberFormat formatter;

  const _BudgetCard({required this.item, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final percentage = item.percentage.clamp(0.0, 1.0);
    final isOverBudget = item.isOverBudget;
    final progressColor = _BudgetScreenState._getProgressColor(percentage);
    final categoryColor = Color(item.category.colorValue);

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: categoryColor.withValues(alpha: 0.15),
                // Gunakan emoji dari database
                child: Text(
                  item.category.icon,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.category.name,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${formatter.format(item.spent)} / ${formatter.format(item.budget.amountLimit)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              // Percentage badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: progressColor.withValues(alpha: 0.4),
                  ),
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
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.danger,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Budget sudah terlampaui!',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
