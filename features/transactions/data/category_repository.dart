import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_service.dart';
import '../domain/category_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryRepository {
  final DatabaseService _dbService;
  
  CategoryRepository(this._dbService);
  
  Future<List<CategoryModel>> getCategories(String profileId) async {
    final db = await _dbService.database;
    final res = await db.query('categories', where: 'profileId = ?', whereArgs: [profileId]);
    return res.map((e) => CategoryModel.fromMap(e)).toList();
  }

  Future<void> addCategory(CategoryModel category) async {
    final db = await _dbService.database;
    await db.insert('categories', category.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(DatabaseService());
});
