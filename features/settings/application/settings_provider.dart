import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/database_service.dart';
import '../../auth/domain/profile_model.dart';

part 'settings_provider.g.dart';

// Model pembantu untuk menggabungkan profil dan saldonya
class ProfileWithBalance {
  final ProfileModel profile;
  final double balance;

  ProfileWithBalance({required this.profile, required this.balance});
}

@riverpod
Future<List<ProfileWithBalance>> allProfiles(Ref ref) async {
  final db = await DatabaseService().database;
  final res = await db.query('profiles', orderBy: 'name ASC');
  final profiles = res.map((e) => ProfileModel.fromMap(e)).toList();

  List<ProfileWithBalance> result = [];

  for (var p in profiles) {
    // Hitung Pemasukan
    final incomeRes = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) as total FROM transactions
      WHERE profileId = ? AND (type = 'income' OR type = 'Pemasukan')
    ''',
      [p.id],
    );

    // Hitung Pengeluaran
    final expenseRes = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) as total FROM transactions
      WHERE profileId = ? AND (type = 'expense' OR type = 'Pengeluaran')
    ''',
      [p.id],
    );

    final income = (incomeRes.first['total'] as num).toDouble();
    final expense = (expenseRes.first['total'] as num).toDouble();

    result.add(ProfileWithBalance(profile: p, balance: income - expense));
  }

  return result;
}
