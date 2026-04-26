import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  final CollectionReference _users = FirebaseFirestore.instance.collection('users');
  final User? _user = FirebaseAuth.instance.currentUser;

  // Get user profile
  Future<DocumentSnapshot?> getProfile() async {
    if (_user == null) return null;
    return await _users.doc(_user.uid).get();
  }

  // Save or update user profile
  Future<void> saveProfile({
    List<String>? healthConditions,
    String? displayName,
    String? photoUrl,
  }) async {
    if (_user == null) throw Exception('User not logged in');

    final data = <String, dynamic>{};

    if (healthConditions != null) data['healthConditions'] = healthConditions;
    if (displayName != null) data['displayName'] = displayName;
    if (photoUrl != null) data['photoUrl'] = photoUrl;

    data['updatedAt'] = FieldValue.serverTimestamp();

    await _users.doc(_user.uid).set(data, SetOptions(merge: true));
  }

  // Get health conditions
  Future<List<String>> getHealthConditions() async {
    if (_user == null) return [];

    final doc = await _users.doc(_user.uid).get();
    if (!doc.exists) return [];

    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return [];

    final conditions = data['healthConditions'];
    if (conditions is List) {
      return List<String>.from(conditions);
    }
    return [];
  }

  // Update health conditions
  Future<void> updateHealthConditions(List<String> conditions) async {
    await saveProfile(healthConditions: conditions);
  }

  // Update display name
  Future<void> updateDisplayName(String name) async {
    // Update in Firestore
    await saveProfile(displayName: name);
    // Update in Firebase Auth
    await _user?.updateDisplayName(name);
  }

  // Update photo URL
  Future<void> updatePhotoUrl(String url) async {
    await saveProfile(photoUrl: url);
  }

  // Get display name
  Future<String?> getDisplayName() async {
    final doc = await getProfile();
    if (doc == null || !doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>?;
    return data?['displayName'] as String?;
  }

  // Get photo URL
  Future<String?> getPhotoUrl() async {
    final doc = await getProfile();
    if (doc == null || !doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>?;
    return data?['photoUrl'] as String?;
  }
}