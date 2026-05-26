import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:injectable/injectable.dart';

@lazySingleton
class UserProfileService {
  final CollectionReference _users = FirebaseFirestore.instance.collection('users');
  User? get _user => FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot?> getProfile() async {
    final user = _user;
    if (user == null) return null;
    return await _users.doc(user.uid).get();
  }

  Future<void> saveProfile({
    List<String>? healthConditions,
    String? displayName,
    String? photoUrl,
  }) async {
    final user = _user;
    if (user == null) throw Exception('User not logged in');

    final data = <String, dynamic>{};

    if (healthConditions != null) data['healthConditions'] = healthConditions;
    if (displayName != null) data['displayName'] = displayName;
    if (photoUrl != null) data['photoUrl'] = photoUrl;

    data['updatedAt'] = FieldValue.serverTimestamp();

    await _users.doc(user.uid).set(data, SetOptions(merge: true));
  }

  Future<List<String>> getHealthConditions() async {
    final user = _user;
    if (user == null) return [];

    final doc = await _users.doc(user.uid).get();
    if (!doc.exists) return [];

    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return [];

    final conditions = data['healthConditions'];
    if (conditions is List) {
      return List<String>.from(conditions);
    }
    return [];
  }

  Future<void> updateHealthConditions(List<String> conditions) async {
    await saveProfile(healthConditions: conditions);
  }

  Future<void> updateDisplayName(String name) async {
    await saveProfile(displayName: name);
    await _user?.updateDisplayName(name);
  }

  Future<void> updatePhotoUrl(String url) async {
    await saveProfile(photoUrl: url);
  }

  Future<String?> getDisplayName() async {
    final doc = await getProfile();
    if (doc == null || !doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>?;
    return data?['displayName'] as String?;
  }

  Future<String?> getPhotoUrl() async {
    final doc = await getProfile();
    if (doc == null || !doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>?;
    return data?['photoUrl'] as String?;
  }
}
