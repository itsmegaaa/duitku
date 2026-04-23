import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_service.dart';
import '../domain/budget_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetRepository {
  final DatabaseService _dbService;
  
  BudgetRepository(this._dbService);
  
  Future<List<BudgetModel>> getBudgets(String profileId, int month, int year) async {
    final db = await _dbService.database;
    final res = await db.query(
      'budgets', 
      where: 'profileId = ? AND month = ? AND year = ?', 
      whereArgs: [profileId, month, year],
    );
    return res.map((e) => BudgetModel.fromMap(e)).toList();
  }

  Future<void> saveBudget(BudgetModel budget) async {
    final db = await _dbService.database;
    await db.insert('budgets', budget.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(DatabaseService());
});
