import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:injectable/injectable.dart';

@lazySingleton
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;


  Future<String?> uploadScanImage(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final String fileName = 'scans/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final UploadTask task = _storage.ref().child(fileName).putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await task;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }
}
