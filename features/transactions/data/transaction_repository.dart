import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_service.dart';
import '../domain/transaction_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionRepository {
  final DatabaseService _dbService;
  
  TransactionRepository(this._dbService);
  
  Future<List<TransactionModel>> getTransactions(String profileId) async {
    try {
      final db = await _dbService.database;
      final res = await db.query(
        'transactions', 
        where: 'profileId = ?', 
        whereArgs: [profileId],
        orderBy: 'date DESC'
      );
      return res.map((e) => TransactionModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Gagal memuat transaksi: $e');
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final db = await _dbService.database;
      await db.insert('transactions', transaction.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw Exception('Gagal menambahkan transaksi: $e');
    }
  }

  Future<void> deleteTransaction(String id, String profileId) async {
    try {
      final db = await _dbService.database;
      await db.delete('transactions', where: 'id = ? AND profileId = ?', whereArgs: [id, profileId]);
    } catch (e) {
      throw Exception('Gagal menghapus transaksi: $e');
    }
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(DatabaseService());
});
