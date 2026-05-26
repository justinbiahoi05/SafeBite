import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:injectable/injectable.dart';

@lazySingleton
class ScanHistoryService {
  final CollectionReference _scans = FirebaseFirestore.instance.collection(
    'scans',
  );
  User? get _user => FirebaseAuth.instance.currentUser;

  Future<DocumentReference> addScan({
    required String result,
    required double confidence,
    List<String>? ingredients,
    Map<String, String>? ingredientPredictions,
    String? imageUrl,
    String? productName,
  }) async {
    final user = _user;
    if (user == null) throw Exception('User not logged in');

    return await _scans.add({
      'userId': user.uid,
      'result': result,
      'confidence': confidence,
      'ingredients': ingredients ?? [],
      'ingredientPredictions': ingredientPredictions ?? {},
      'imageUrl': imageUrl,
      'productName': productName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getScans() {
    final user = _user;
    if (user == null) {
      return const Stream.empty();
    }
    return _scans
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<DocumentSnapshot?> getScan(String id) async {
    return await _scans.doc(id).get();
  }

  Future<void> deleteScan(String id) async {
    await _scans.doc(id).delete();
  }

  Future<int> getScanCount() async {
    final user = _user;
    if (user == null) return 0;
    final snapshot = await _scans
        .where('userId', isEqualTo: user.uid)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<int> getSafeCount() async {
    final user = _user;
    if (user == null) return 0;
    final snapshot = await _scans
        .where('userId', isEqualTo: user.uid)
        .where('result', isEqualTo: 'safe')
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<List<QueryDocumentSnapshot>> getRecentScans(int days) async {
    final user = _user;
    if (user == null) return [];

    final cutoff = DateTime.now().subtract(Duration(days: days));
    final snapshot = await _scans
        .where('userId', isEqualTo: user.uid)
        .where('createdAt', isGreaterThan: cutoff)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs;
  }

  Future<List<Map<String, dynamic>>> getWeeklyTrend() async {
    final user = _user;
    if (user == null) return [];

    final now = DateTime.now();
    final List<Map<String, dynamic>> trend = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final totalSnapshot = await _scans
          .where('userId', isEqualTo: user.uid)
          .where('createdAt', isGreaterThan: startOfDay)
          .where('createdAt', isLessThan: endOfDay)
          .count()
          .get();

      final safeSnapshot = await _scans
          .where('userId', isEqualTo: user.uid)
          .where('result', isEqualTo: 'safe')
          .where('createdAt', isGreaterThan: startOfDay)
          .where('createdAt', isLessThan: endOfDay)
          .count()
          .get();

      trend.add({
        'date': startOfDay,
        'total': totalSnapshot.count ?? 0,
        'safe': safeSnapshot.count ?? 0,
      });
    }

    return trend;
  }

  Future<List<Map<String, dynamic>>> getMonthlyTrend() async {
    final user = _user;
    if (user == null) return [];

    final now = DateTime.now();
    final List<Map<String, dynamic>> trend = [];

    for (int i = 3; i >= 0; i--) {
      final weekEnd = now.subtract(Duration(days: i * 7));
      final weekStart = weekEnd.subtract(const Duration(days: 7));

      final totalSnapshot = await _scans
          .where('userId', isEqualTo: user.uid)
          .where('createdAt', isGreaterThan: weekStart)
          .where('createdAt', isLessThan: weekEnd)
          .count()
          .get();

      final safeSnapshot = await _scans
          .where('userId', isEqualTo: user.uid)
          .where('result', isEqualTo: 'safe')
          .where('createdAt', isGreaterThan: weekStart)
          .where('createdAt', isLessThan: weekEnd)
          .count()
          .get();

      trend.add({
        'date': weekStart,
        'total': totalSnapshot.count ?? 0,
        'safe': safeSnapshot.count ?? 0,
      });
    }

    return trend;
  }
}
