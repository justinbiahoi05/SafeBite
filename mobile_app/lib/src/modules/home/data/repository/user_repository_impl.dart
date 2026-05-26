import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/data/remote/services/user_profile_service.dart';
import '../../../../core/data/remote/services/gemini_service.dart';
import '../../domain/repository/user_repository.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final UserProfileService _userProfileService;
  final GeminiService _geminiService;

  UserRepositoryImpl(this._userProfileService, this._geminiService);

  @override
  Future<DocumentSnapshot?> getProfile() {
    return _userProfileService.getProfile();
  }

  @override
  Future<void> saveProfile({
    List<String>? healthConditions,
    String? displayName,
    String? photoUrl,
  }) {
    return _userProfileService.saveProfile(
      healthConditions: healthConditions,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  @override
  Future<List<String>> getHealthConditions() {
    return _userProfileService.getHealthConditions();
  }

  @override
  Future<void> updateHealthConditions(List<String> conditions) {
    return _userProfileService.updateHealthConditions(conditions);
  }

  @override
  Future<void> updateDisplayName(String name) {
    return _userProfileService.updateDisplayName(name);
  }

  @override
  Future<void> updatePhotoUrl(String url) {
    return _userProfileService.updatePhotoUrl(url);
  }

  @override
  Future<String?> getDisplayName() {
    return _userProfileService.getDisplayName();
  }

  @override
  Future<String?> getPhotoUrl() {
    return _userProfileService.getPhotoUrl();
  }

  @override
  String? getGeminiApiKey() {
    return _geminiService.apiKey;
  }

  @override
  void setGeminiApiKey(String key) {
    _geminiService.setApiKey(key);
  }
}
