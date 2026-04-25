import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/services/firestore_sync_service.dart';
import '../../../core/presentation/components/bounce_button.dart';

import '../domain/transaction_model.dart';
import '../data/transaction_repository.dart';
import '../application/transaction_provider.dart';

// Providers to invalidate
import '../../home/application/home_provider.dart';
import '../../statistics/application/statistics_provider.dart';
import '../../budget/application/budget_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  String _amount = "0";
  bool _isIncome = false;
  String? _selectedCategoryId;
  final TextEditingController _noteController = TextEditingController();
  final DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onNumpadPressed(String value) {
    setState(() {
      if (value == '.') {
        if (!_amount.contains('.')) {
          _amount += '.';
        }
        return;
      }
      
      if (_amount == "0") {
        _amount = value;
      } else {
        _amount += value;
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      if (_amount.length > 1) {
        _amount = _amount.substring(0, _amount.length - 1);
      } else {
        _amount = "0";
      }
    });
  }

  Future<void> _handleSave() async {
    final amount = double.tryParse(_amount);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal tidak valid')),
      );
      return;
    }

    final profileId = HiveService.activeProfileId;
    if (profileId == null) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    final transaction = TransactionModel(
      id: const Uuid().v4(),
      profileId: profileId,
      categoryId: _selectedCategoryId!,
      amount: amount,
      type: _isIncome ? 'Pemasukan' : 'Pengeluaran',
      date: _selectedDate,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      isRecurring: false,
      createdAt: DateTime.now(),
      syncStatus: 0,
    );

    // Save locally
    final repo = ref.read(transactionRepositoryProvider);
    await repo.addTransaction(transaction);

    // Sync to Firestore
    FirestoreSyncService.syncTransaction(transaction.toMap()).ignore();

    // Invalidate providers
    ref.invalidate(recentTransactionsProvider);
    ref.invalidate(homeSummaryProvider);
    ref.invalidate(sparklineDataProvider);
    ref.invalidate(statisticsSummaryProvider);
    ref.invalidate(categoryStatsProvider);
    ref.invalidate(monthlyBarsProvider);
    ref.invalidate(budgetsWithSpendingProvider);

    HapticFeedback.mediumImpact();
    
    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Transaksi berhasil disimpan!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(profileCategoriesProvider);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Display Amount Area
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Pengeluaran'), icon: Icon(Icons.remove_circle_outline)),
                    ButtonSegment(value: true, label: Text('Pemasukan'), icon: Icon(Icons.add_circle_outline)),
                  ],
                  selected: {_isIncome},
                  onSelectionChanged: (val) => setState(() => _isIncome = val.first),
                ),
                const SizedBox(height: 32),
                Text(
                  'Rp ${NumberFormat('#,###', 'id_ID').format(double.tryParse(_amount) ?? 0)}',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _isIncome ? AppColors.success : AppColors.danger,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Form Area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Category Selection
                categoriesAsync.when(
                  data: (categories) {
                    if (_selectedCategoryId == null && categories.isNotEmpty) {
                      Future.microtask(() => setState(() => _selectedCategoryId = categories.first.id));
                    }
                    return SizedBox(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final isSelected = _selectedCategoryId == cat.id;
                          return ChoiceChip(
                            label: Text('${cat.icon} ${cat.name}'),
                            selected: isSelected,
                            onSelected: (val) => setState(() => _selectedCategoryId = cat.id),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => const Text('Gagal memuat kategori'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: 'Catatan (opsional)',
                    prefixIcon: const Icon(Icons.notes),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),
          
          // Numpad Area
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNumpadRow(['1', '2', '3']),
                _buildNumpadRow(['4', '5', '6']),
                _buildNumpadRow(['7', '8', '9']),
                _buildNumpadRow(['.', '0', 'DEL']),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: BounceButton(
                    onTap: _handleSave,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Simpan Transaksi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNumpadRow(List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) {
          return Expanded(
            child: item == 'DEL'
                ? IconButton(
                    onPressed: _onDeletePressed,
                    icon: const Icon(Icons.backspace_outlined, size: 26),
                  )
                : TextButton(
                    onPressed: () => _onNumpadPressed(item),
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                  ),
          );
        }).toList(),
      ),
    );
  }
}

