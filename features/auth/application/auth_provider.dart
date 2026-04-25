import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart'; // Tambahan untuk tipe Database
import 'package:uuid/uuid.dart'; // Tambahan untuk generate UUID kategori

import '../../../core/database/hive_service.dart';
import '../../../core/database/database_service.dart';
import '../domain/profile_model.dart';
import 'local_auth_service.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<ProfileModel?> build() {
    _loadSession();
    return const AsyncValue.loading();
  }

  Future<void> _loadSession() async {
    final profileId = HiveService.activeProfileId;
    if (profileId != null) {
      final db = await DatabaseService().database;
      final res = await db.query(
        'profiles',
        where: 'id = ?',
        whereArgs: [profileId],
      );
      if (res.isNotEmpty) {
        state = AsyncValue.data(ProfileModel.fromMap(res.first));
        return;
      }
    }
    state = const AsyncValue.data(null);
  }

  // ✅ BAGIAN 7: Fungsi Seed Default Categories
  Future<void> _seedDefaultCategories(Database db, String profileId) async {
    // Cek dulu apakah sudah ada kategori untuk profil ini
    final existing = await db.query(
      'categories',
      where: 'profileId = ?',
      whereArgs: [profileId],
    );
    if (existing.isNotEmpty) return;

    final defaults = [
      {'name': 'Makanan & Minuman', 'icon': '🍔', 'colorValue': 0xFFFF7043},
      {'name': 'Transportasi', 'icon': '🚗', 'colorValue': 0xFF42A5F5},
      {'name': 'Belanja', 'icon': '🛍️', 'colorValue': 0xFFEC407A},
      {'name': 'Tagihan', 'icon': '🧾', 'colorValue': 0xFF78909C},
      {'name': 'Hiburan', 'icon': '🎮', 'colorValue': 0xFFAB47BC},
      {'name': 'Kesehatan', 'icon': '💊', 'colorValue': 0xFF26A69A},
      {'name': 'Gaji', 'icon': '💼', 'colorValue': 0xFFC9A84C},
      {'name': 'Investasi', 'icon': '📈', 'colorValue': 0xFF66BB6A},
    ];

    for (final cat in defaults) {
      await db.insert('categories', {
        'id': const Uuid().v4(),
        'profileId': profileId,
        'name': cat['name'],
        'icon': cat['icon'],
        'colorValue': cat['colorValue'],
        'isDefault': 1,
      });
    }
  }

  Future<void> _syncProfile(User user, {String? defaultName}) async {
    final db = await DatabaseService().database;
    final id = user.uid;
    final email = user.email ?? '';
    final name = user.displayName ?? defaultName ?? 'Pengguna';

    final existing = await db.query(
      'profiles',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (existing.isEmpty) {
      final newProfile = ProfileModel(
        id: id,
        name: name,
        email: email,
        currency: 'IDR',
      );
      await db.insert('profiles', newProfile.toMap());

      // ✅ BAGIAN 7 DIPANGGIL: Membuat kategori default saat profil pertama kali dibuat
      await _seedDefaultCategories(db, id);
    } else {
      // Update existing profile with potentially new Google data
      await db.update(
        'profiles',
        {'name': name, 'email': email},
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    await HiveService.setActiveProfileId(id);
    await HiveService.setAuthenticated(true);
    _loadSession();
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await _syncProfile(credential.user!);
      }
    } catch (e) {
      throw Exception('Login gagal: $e');
    }
  }

  Future<void> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        await _syncProfile(credential.user!, defaultName: name);
      }
    } catch (e) {
      throw Exception('Daftar gagal: $e');
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      // GoogleSignIn v7.0.0+ requires initialization and uses authenticate()
      await GoogleSignIn.instance.initialize(
        serverClientId: '52333236285-r108aqm5fb9v0enhhnt98t1obet8a736.apps.googleusercontent.com',
      );
      
      final googleUser = await GoogleSignIn.instance.authenticate();
      // authenticate() throws if cancelled or failed in v7.0.0+


      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
          
      // Ensure we have an idToken
      if (googleAuth.idToken == null) {
        throw Exception('Missing idToken from Google Sign In. Ensure SHA-1 is correct in Firebase Console.');
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      if (userCredential.user != null) {
        await _syncProfile(userCredential.user!);
      }
    } catch (e) {
      throw Exception('Google Sign-In gagal: $e');
    }
  }

  Future<void> loginWithBiometrics() async {
    final localAuth = ref.read(localAuthServiceProvider);
    final success = await localAuth.authenticate(
      'Verifikasi biometrik untuk mengakses DuitKu',
    );
    if (success) {
      await HiveService.setAuthenticated(true);
      ref.invalidateSelf();
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn.instance.signOut();
    await HiveService.setAuthenticated(false);
    ref.invalidateSelf();
  }
}
