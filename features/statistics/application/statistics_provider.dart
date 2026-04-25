import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart'; // Tambahan untuk format bulan
import '../../../core/database/hive_service.dart';
import '../../../core/database/database_service.dart';

part 'statistics_provider.g.dart';

// --- Models ---
class StatisticsSummary {
  final double income;
  final double expense;

  StatisticsSummary({required this.income, required this.expense});

  factory StatisticsSummary.empty() =>
      StatisticsSummary(income: 0.0, expense: 0.0);
}

class CategoryStat {
  final String name;
  final String icon;
  final Color color;
  final double amount;
  final double percentage;

  CategoryStat({
    required this.name,
    required this.icon,
    required this.color,
    required this.amount,
    required this.percentage,
  });
}

// ✅ BAGIAN 3b: Model untuk Bar Chart
class MonthlyBar {
  final String month;
  final double income;
  final double expense;

  MonthlyBar({
    required this.month,
    required this.income,
    required this.expense,
  });
}

// --- Helper Date Range ---
(String, String) _getDateRange(String period) {
  final now = DateTime.now();
  switch (period.toLowerCase()) {
    case 'weekly':
    case 'mingguan':
      final start = now.subtract(const Duration(days: 7));
      return (start.toIso8601String(), now.toIso8601String());
    case 'yearly':
    case 'tahunan':
      return (
        DateTime(now.year, 1, 1).toIso8601String(),
        now.toIso8601String(),
      );
    case 'monthly':
    case 'bulanan':
    default:
      return (
        DateTime(now.year, now.month, 1).toIso8601String(),
        now.toIso8601String(),
      );
  }
}

// --- Providers ---

@riverpod
Future<StatisticsSummary> statisticsSummary(
  Ref ref,
  String period,
) async {
  final profileId = HiveService.activeProfileId;
  if (profileId == null) return StatisticsSummary.empty();

  final db = await DatabaseService().database;
  final (startDate, endDate) = _getDateRange(period);

  final incomeRes = await db.rawQuery(
    '''
    SELECT COALESCE(SUM(amount), 0) as total FROM transactions
    WHERE profileId = ? AND (type = 'income' OR type = 'Pemasukan') AND date BETWEEN ? AND ?
  ''',
    [profileId, startDate, endDate],
  );

  final expenseRes = await db.rawQuery(
    '''
    SELECT COALESCE(SUM(amount), 0) as total FROM transactions
    WHERE profileId = ? AND (type = 'expense' OR type = 'Pengeluaran') AND date BETWEEN ? AND ?
  ''',
    [profileId, startDate, endDate],
  );

  return StatisticsSummary(
    income: (incomeRes.first['total'] as num).toDouble(),
    expense: (expenseRes.first['total'] as num).toDouble(),
  );
}

@riverpod
Future<List<CategoryStat>> categoryStats(
  Ref ref,
  String period,
) async {
  final profileId = HiveService.activeProfileId;
  if (profileId == null) return [];

  final db = await DatabaseService().database;
  final (startDate, endDate) = _getDateRange(period);

  final res = await db.rawQuery(
    '''
    SELECT c.name, c.icon, c.colorValue,
           SUM(t.amount) as total
    FROM transactions t
    JOIN categories c ON t.categoryId = c.id
    WHERE t.profileId = ? AND (t.type = 'expense' OR t.type = 'Pengeluaran') AND t.date BETWEEN ? AND ?
    GROUP BY t.categoryId
    ORDER BY total DESC
  ''',
    [profileId, startDate, endDate],
  );

  final totalExpense = res.fold(
    0.0,
    (sum, r) => sum + (r['total'] as num).toDouble(),
  );

  return res
      .map(
        (r) => CategoryStat(
          name: r['name'] as String,
          icon: r['icon'] as String,
          color: Color(r['colorValue'] as int),
          amount: (r['total'] as num).toDouble(),
          percentage: totalExpense > 0
              ? ((r['total'] as num).toDouble() / totalExpense * 100)
              : 0,
        ),
      )
      .toList();
}

// ✅ BAGIAN 3b: Provider untuk Bar Chart (6 Bulan Terakhir)
@riverpod
Future<List<MonthlyBar>> monthlyBars(Ref ref) async {
  final profileId = HiveService.activeProfileId;
  if (profileId == null) return [];

  final db = await DatabaseService().database;
  final List<MonthlyBar> bars = [];
  final now = DateTime.now();

  // Looping 6 bulan terakhir (dari 5 bulan lalu sampai bulan ini)
  for (int i = 5; i >= 0; i--) {
    // Mendapatkan tanggal awal bulan target
    final targetMonth = DateTime(now.year, now.month - i, 1);
    // Mendapatkan tanggal awal bulan depannya sebagai batas akhir
    final nextMonth = DateTime(now.year, now.month - i + 1, 1);

    final startDate = targetMonth.toIso8601String();
    final endDate = nextMonth.toIso8601String();

    // Format nama bulan, misal: Jan, Feb (Otomatis id_ID jika app diset ke locale Indonesia)
    final monthLabel = DateFormat('MMM', 'id_ID').format(targetMonth);

    final incomeRes = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) as total FROM transactions
      WHERE profileId = ? AND (type = 'income' OR type = 'Pemasukan') AND date >= ? AND date < ?
    ''',
      [profileId, startDate, endDate],
    );

    final expenseRes = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) as total FROM transactions
      WHERE profileId = ? AND (type = 'expense' OR type = 'Pengeluaran') AND date >= ? AND date < ?
    ''',
      [profileId, startDate, endDate],
    );

    bars.add(
      MonthlyBar(
        month: monthLabel,
        income: (incomeRes.first['total'] as num).toDouble(),
        expense: (expenseRes.first['total'] as num).toDouble(),
      ),
    );
  }

  return bars;
}
