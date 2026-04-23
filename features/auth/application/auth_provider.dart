import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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
      final res = await db.query('profiles', where: 'id = ?', whereArgs: [profileId]);
      if (res.isNotEmpty) {
        state = AsyncValue.data(ProfileModel.fromMap(res.first));
        return;
      }
    }
    state = const AsyncValue.data(null);
  }

  Future<void> _syncProfile(User user, {String? defaultName}) async {
    final db = await DatabaseService().database;
    final id = user.uid;
    final email = user.email ?? '';
    final name = user.displayName ?? defaultName ?? 'Pengguna';
    
    final existing = await db.query('profiles', where: 'id = ?', whereArgs: [id]);
    if (existing.isEmpty) {
      final newProfile = ProfileModel(id: id, name: name, email: email, currency: 'IDR');
      await db.insert('profiles', newProfile.toMap());
    } else {
      // Update existing profile with potentially new Google data
      await db.update('profiles', {'name': name, 'email': email}, where: 'id = ?', whereArgs: [id]);
    }
    
    await HiveService.setActiveProfileId(id);
    await HiveService.setAuthenticated(true);
    _loadSession();
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        await _syncProfile(credential.user!);
      }
    } catch (e) {
      throw Exception('Login gagal: $e');
    }
  }

  Future<void> registerWithEmail(String name, String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
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
      final googleUser = await GoogleSignIn.instance.authenticate();

      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _syncProfile(userCredential.user!);
      }
    } catch (e) {
      throw Exception('Google Sign-In gagal: $e');
    }
  }

  Future<void> loginWithBiometrics() async {
    final localAuth = ref.read(localAuthServiceProvider);
    final success = await localAuth.authenticate('Verifikasi biometrik untuk mengakses DuitKu');
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
