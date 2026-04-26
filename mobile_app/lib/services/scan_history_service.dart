import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScanHistoryService {
  final CollectionReference _scans = FirebaseFirestore.instance.collection('scans');
  final User? _user = FirebaseAuth.instance.currentUser;

  // Add a new scan result
  Future<DocumentReference> addScan({
    required String result,
    required double confidence,
    List<String>? ingredients,
    String? imageUrl,
    String? productName,
  }) async {
    if (_user == null) throw Exception('User not logged in');

    return await _scans.add({
      'userId': _user!.uid,
      'result': result,
      'confidence': confidence,
      'ingredients': ingredients ?? [],
      'imageUrl': imageUrl,
      'productName': productName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get all scans for current user
  Stream<QuerySnapshot> getScans() {
    if (_user == null) {
      return const Stream.empty();
    }
    return _scans
        .where('userId', isEqualTo: _user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get single scan by ID
  Future<DocumentSnapshot?> getScan(String id) async {
    return await _scans.doc(id).get();
  }

  // Delete a scan
  Future<void> deleteScan(String id) async {
    await _scans.doc(id).delete();
  }

  // Get scan count
  Future<int> getScanCount() async {
    if (_user == null) return 0;
    final snapshot = await _scans
        .where('userId', isEqualTo: _user.uid)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  // Get safe scans count (result = safe)
  Future<int> getSafeCount() async {
    if (_user == null) return 0;
    final snapshot = await _scans
        .where('userId', isEqualTo: _user.uid)
        .where('result', isEqualTo: 'safe')
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  // Get recent scans (last 7 days)
  Future<List<QueryDocumentSnapshot>> getRecentScans(int days) async {
    if (_user == null) return [];

    final cutoff = DateTime.now().subtract(Duration(days: days));
    final snapshot = await _scans
        .where('userId', isEqualTo: _user.uid)
        .where('createdAt', isGreaterThan: cutoff)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs;
  }

  Future<List<Map<String, dynamic>>> getWeeklyTrend() async {
    if (_user == null) return [];

    final now = DateTime.now();
    final List<Map<String, dynamic>> trend = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final totalSnapshot = await _scans
          .where('userId', isEqualTo: _user.uid)
          .where('createdAt', isGreaterThan: startOfDay)
          .where('createdAt', isLessThan: endOfDay)
          .count()
          .get();

      final safeSnapshot = await _scans
          .where('userId', isEqualTo: _user.uid)
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

  // Get monthly trend data (last 30 days, grouped by week)
  Future<List<Map<String, dynamic>>> getMonthlyTrend() async {
    if (_user == null) return [];

    final now = DateTime.now();
    final List<Map<String, dynamic>> trend = [];

    for (int i = 3; i >= 0; i--) {
      final weekEnd = now.subtract(Duration(days: i * 7));
      final weekStart = weekEnd.subtract(const Duration(days: 7));

      final totalSnapshot = await _scans
          .where('userId', isEqualTo: _user.uid)
          .where('createdAt', isGreaterThan: weekStart)
          .where('createdAt', isLessThan: weekEnd)
          .count()
          .get();

      final safeSnapshot = await _scans
          .where('userId', isEqualTo: _user.uid)
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