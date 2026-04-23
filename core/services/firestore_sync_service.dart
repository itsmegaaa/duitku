import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firestore Sync Service — Cloud sync engine for DuitKu
/// Auto-syncs local data to Firestore when online.
class FirestoreSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get _userId => _auth.currentUser?.uid;

  // ─── Sync Transactions ──────────────────────────────────
  static Future<void> syncTransaction(Map<String, dynamic> transaction) async {
    if (_userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .doc(transaction['id'] as String?)
          .set(transaction, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Sync error: $e');
    }
  }

  static Future<void> deleteTransaction(String id) async {
    if (_userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .doc(id)
          .delete();
    } catch (e) {
      debugPrint('Delete sync error: $e');
    }
  }

  // ─── Sync Budgets ──────────────────────────────────────
  static Future<void> syncBudget(Map<String, dynamic> budget) async {
    if (_userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('budgets')
          .doc(budget['id'] as String?)
          .set(budget, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Budget sync error: $e');
    }
  }

  // ─── Sync Profile ──────────────────────────────────────
  static Future<void> syncProfile(Map<String, dynamic> profile) async {
    if (_userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('profiles')
          .doc(profile['id'] as String?)
          .set(profile, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Profile sync error: $e');
    }
  }

  // ─── Fetch All Remote Data ─────────────────────────────
  static Future<List<Map<String, dynamic>>> fetchTransactions() async {
    if (_userId == null) return [];
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      debugPrint('Fetch error: $e');
      return [];
    }
  }

  // ─── Full Sync (Pull + Push) ───────────────────────────
  static Future<void> fullSync() async {
    if (_userId == null) return;
    // Placeholder: In a real implementation, this would diff local Hive data
    // against Firestore and merge changes in both directions.
    debugPrint('Full sync triggered for user: $_userId');
  }
}
