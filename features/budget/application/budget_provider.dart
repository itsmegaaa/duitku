import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/database/database_service.dart';
import '../../transactions/domain/category_model.dart';
import '../domain/budget_model.dart';

part 'budget_provider.g.dart';

// --- Model Pembantu ---
class BudgetWithSpending {
  final BudgetModel budget;
  final CategoryModel category;
  final double spent;

  BudgetWithSpending({
    required this.budget,
    required this.category,
    required this.spent,
  });

  // Mencegah error pembagian dengan nol jika limit budget 0
  double get percentage =>
      budget.amountLimit > 0 ? (spent / budget.amountLimit) : 0.0;
  bool get isOverBudget => spent >= budget.amountLimit;
}

// --- Provider ---
@riverpod
Future<List<BudgetWithSpending>> budgetsWithSpending(Ref ref) async {
  final profileId = HiveService.activeProfileId;
  if (profileId == null) return [];

  final db = await DatabaseService().database;
  final now = DateTime.now();

  final budgetsRaw = await db.rawQuery('''
    SELECT 
      b.*,
      c.id as c_id, c.name as c_name, c.icon as c_icon, c.colorValue as c_color, c.profileId as c_profileId,
      COALESCE((
        SELECT SUM(amount) 
        FROM transactions t 
        WHERE t.profileId = ? AND t.categoryId = b.categoryId 
          AND (t.type = 'expense' OR t.type = 'Pengeluaran')
          AND t.date >= ? AND t.date <= ?
      ), 0) as total_spent
    FROM budgets b
    JOIN categories c ON b.categoryId = c.id
    WHERE b.profileId = ? AND b.month = ? AND b.year = ?
  ''', [
    profileId,
    DateTime(now.year, now.month, 1).toIso8601String(),
    now.toIso8601String(),
    profileId,
    now.month,
    now.year,
  ]);

  final List<BudgetWithSpending> result = [];

  for (final row in budgetsRaw) {
    final budgetData = {
      'id': row['id'],
      'profileId': row['profileId'],
      'categoryId': row['categoryId'],
      'amountLimit': row['amountLimit'],
      'month': row['month'],
      'year': row['year'],
    };
    
    final categoryData = {
      'id': row['c_id'],
      'profileId': row['c_profileId'],
      'name': row['c_name'],
      'icon': row['c_icon'],
      'colorValue': row['c_color'],
    };

    result.add(
      BudgetWithSpending(
        budget: BudgetModel.fromMap(budgetData),
        category: CategoryModel.fromMap(categoryData),
        spent: (row['total_spent'] as num).toDouble(),
      ),
    );
  }

  return result;
}
