import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ScanRepository {
  Future<Map<String, dynamic>?> extractIngredients(XFile photo);
  Future<Map<String, String>?> analyzeIngredients({
    required List<String> ingredients,
    required List<String> healthConditions,
  });
  Future<String?> getHealthAdvice({
    required Map<String, dynamic> ingredientsData,
    required List<String> healthConditions,
  });
  Future<String?> uploadScanImage(File imageFile);
  Future<DocumentReference> addScan({
    required String result,
    required double confidence,
    List<String>? ingredients,
    Map<String, String>? ingredientPredictions,
    String? imageUrl,
    String? productName,
  });
  Stream<QuerySnapshot> getScans();
  Future<void> deleteScan(String id);
  Future<int> getScanCount();
  Future<int> getSafeCount();
  Future<List<QueryDocumentSnapshot>> getRecentScans(int days);
  Future<List<Map<String, dynamic>>> getMonthlyTrend();
  Map<String, dynamic> predictLocal(String text);
  Future<bool> hasInternet();
  Future<String?> chatWithAI(List<Map<String, String>> messages);
}
