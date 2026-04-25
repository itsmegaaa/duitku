import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_service.dart';
import '../domain/category_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryRepository {
  final DatabaseService _dbService;
  
  CategoryRepository(this._dbService);
  
  Future<List<CategoryModel>> getCategories(String profileId) async {
    try {
      final db = await _dbService.database;
      final res = await db.query('categories', where: 'profileId = ?', whereArgs: [profileId]);
      return res.map((e) => CategoryModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Gagal memuat kategori: $e');
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      final db = await _dbService.database;
      await db.insert('categories', category.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw Exception('Gagal menambahkan kategori: $e');
    }
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(DatabaseService());
});
