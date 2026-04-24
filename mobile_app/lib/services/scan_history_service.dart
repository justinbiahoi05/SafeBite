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
  }) async {
    if (_user == null) throw Exception('User not logged in');

    return await _scans.add({
      'userId': _user!.uid,
      'result': result,
      'confidence': confidence,
      'ingredients': ingredients ?? [],
      'imageUrl': imageUrl,
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
}