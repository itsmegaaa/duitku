import 'package:cloud_firestore/cloud_firestore.dart';
import '../../transactions/domain/transaction_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseSyncService() {
    // Enable offline persistence
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  Future<void> syncTransaction(TransactionModel transaction) async {
    await _firestore
        .collection('profiles')
        .doc(transaction.profileId)
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toMap());
  }

  // Backup all offline-added transactions
  Future<void> syncOfflineBatch(List<TransactionModel> unsyncedTransactions) async {
    final batch = _firestore.batch();
    for (var trx in unsyncedTransactions) {
      final docRef = _firestore
          .collection('profiles')
          .doc(trx.profileId)
          .collection('transactions')
          .doc(trx.id);
      batch.set(docRef, trx.toMap());
    }
    await batch.commit();
  }
}

final firebaseSyncServiceProvider = Provider<FirebaseSyncService>((ref) {
  return FirebaseSyncService();
});
