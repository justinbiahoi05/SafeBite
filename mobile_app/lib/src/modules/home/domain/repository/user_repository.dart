import 'package:cloud_firestore/cloud_firestore.dart';

abstract class UserRepository {
  Future<DocumentSnapshot?> getProfile();
  Future<void> saveProfile({
    List<String>? healthConditions,
    String? displayName,
    String? photoUrl,
  });
  Future<List<String>> getHealthConditions();
  Future<void> updateHealthConditions(List<String> conditions);
  Future<void> updateDisplayName(String name);
  Future<void> updatePhotoUrl(String url);
  Future<String?> getDisplayName();
  Future<String?> getPhotoUrl();
  String? getGeminiApiKey();
  void setGeminiApiKey(String key);
}
