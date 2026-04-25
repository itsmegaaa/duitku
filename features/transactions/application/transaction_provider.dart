import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/hive_service.dart';
import '../data/category_repository.dart';
import '../domain/category_model.dart';

part 'transaction_provider.g.dart';

// ✅ BAGIAN 6a: Provider untuk membaca kategori dari SQLite
@riverpod
Future<List<CategoryModel>> profileCategories(Ref ref) async {
  final profileId = HiveService.activeProfileId;
  if (profileId == null) return [];

  final repo = ref.read(categoryRepositoryProvider);
  return repo.getCategories(profileId);
}
