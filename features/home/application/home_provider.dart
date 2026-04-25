import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fl_chart/fl_chart.dart'; // Tambahan untuk grafik
import '../../../core/database/hive_service.dart';
import '../../../core/database/database_service.dart';
import '../../auth/domain/profile_model.dart';
import '../../transactions/domain/transaction_model.dart';

part 'home_provider.g.dart';

// --- BAGIAN 2a: Profil Aktif ---
@riverpod
Future<ProfileModel?> activeProfile(Ref ref) async {
  final profileId = HiveService.activeProfileId;
  if (profileId == null) return null;
  final db = await DatabaseService().database;
  final res = await db.query(
    'profiles',
    where: 'id = ?',
    whereArgs: [profileId],
  );
  if (res.isEmpty) return null;
  return ProfileModel.fromMap(res.first);
}

// --- BAGIAN 2b: Summary Saldo ---
@riverpod
Future<Map<String, double>> homeSummary(Ref ref) async {
  final profileId = HiveService.activeProfileId;
  if (profileId == null) {
    return {'balance': 0, 'monthIncome': 0, 'monthExpense': 0};
  }

  final db = await DatabaseService().database;
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();

  final allTx = await db.query(
    'transactions',
    where: 'profileId = ?',
    whereArgs: [profileId],
  );
  final monthTx = await db.query(
    'transactions',
    where: "profileId = ? AND date >= ?",
    whereArgs: [profileId, startOfMonth],
  );

  double totalIncome = 0, totalExpense = 0;
  for (var tx in allTx) {
    final amount = (tx['amount'] as num).toDouble();
    if (tx['type'] == 'Pemasukan' || tx['type'] == 'income') {
      totalIncome += amount;
    } else {
      totalExpense += amount;
    }
  }

  double monthIncome = 0, monthExpense = 0;
  for (var tx in monthTx) {
    final amount = (tx['amount'] as num).toDouble();
    if (tx['type'] == 'Pemasukan' || tx['type'] == 'income') {
      monthIncome += amount;
    } else {
      monthExpense += amount;
    }
  }

  return {
    'balance': totalIncome - totalExpense,
    'monthIncome': monthIncome,
    'monthExpense': monthExpense,
  };
}

// --- BAGIAN 2c: Model & Provider Transaksi Terbaru ---

class TransactionWithCategory {
  final TransactionModel transaction;
  final String categoryName;
  final String categoryIcon; // Menggunakan emoji
  final Color categoryColor;

  TransactionWithCategory({
    required this.transaction,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
  });

  factory TransactionWithCategory.fromMap(Map<String, dynamic> map) {
    return TransactionWithCategory(
      transaction: TransactionModel.fromMap(map),
      categoryName: map['categoryName'] as String? ?? 'Umum',
      categoryIcon: map['categoryIcon'] as String? ?? '📁',
      categoryColor: map['colorValue'] != null
          ? Color(map['colorValue'] as int)
          : const Color(0xFF9E9E9E),
    );
  }
}

@riverpod
Future<List<TransactionWithCategory>> recentTransactions(Ref ref) async {
  final profileId = HiveService.activeProfileId;
  if (profileId == null) return [];

  final db = await DatabaseService().database;

  final res = await db.rawQuery(
    '''
    SELECT t.*, c.name as categoryName, c.icon as categoryIcon, c.colorValue
    FROM transactions t
    LEFT JOIN categories c ON t.categoryId = c.id
    WHERE t.profileId = ?
    ORDER BY t.date DESC
    LIMIT 10
  ''',
    [profileId],
  );

  return res.map((e) => TransactionWithCategory.fromMap(e)).toList();
}

// --- BAGIAN 2d: Data Grafik Sparkline ---
@riverpod
Future<List<FlSpot>> sparklineData(Ref ref) async {
  final profileId = HiveService.activeProfileId;
  if (profileId == null) return [];

  final db = await DatabaseService().database;
  final List<FlSpot> spots = [];

  for (int i = 6; i >= 0; i--) {
    final day = DateTime.now().subtract(Duration(days: i));
    final start = DateTime(day.year, day.month, day.day).toIso8601String();
    final end = DateTime(
      day.year,
      day.month,
      day.day,
      23,
      59,
      59,
    ).toIso8601String();

    // Mengamankan query untuk membaca type 'expense' dan 'Pengeluaran'
    final res = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM transactions
      WHERE profileId = ? AND (type = 'expense' OR type = 'Pengeluaran') AND date BETWEEN ? AND ?
    ''',
      [profileId, start, end],
    );

    final total = (res.first['total'] as num?)?.toDouble() ?? 0;
    spots.add(FlSpot((6 - i).toDouble(), total / 1000)); // ribuan
  }
  return spots;
}
