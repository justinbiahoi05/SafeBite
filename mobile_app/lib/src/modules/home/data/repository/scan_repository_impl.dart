import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/data/remote/services/groq_service.dart';
import '../../../../core/data/remote/services/storage_service.dart';
import '../../../../core/data/remote/services/scan_history_service.dart';
import '../../../../core/data/remote/services/ai_service.dart';
import '../../../../core/data/remote/services/network_service.dart';
import '../../domain/repository/scan_repository.dart';

@LazySingleton(as: ScanRepository)
class ScanRepositoryImpl implements ScanRepository {
  final GroqService _groqService;
  final StorageService _storageService;
  final ScanHistoryService _scanHistoryService;
  final AIService _aiService;
  final NetworkService _networkService;

  ScanRepositoryImpl(
    this._groqService,
    this._storageService,
    this._scanHistoryService,
    this._aiService,
    this._networkService,
  );

  @override
  Future<Map<String, dynamic>?> extractIngredients(XFile photo) {
    return _groqService.extractIngredients(photo);
  }

  @override
  Future<Map<String, String>?> analyzeIngredients({
    required List<String> ingredients,
    required List<String> healthConditions,
  }) {
    return _groqService.analyzeIngredients(
      ingredients: ingredients,
      healthConditions: healthConditions,
    );
  }

  @override
  Future<String?> getHealthAdvice({
    required Map<String, dynamic> ingredientsData,
    required List<String> healthConditions,
  }) {
    return _groqService.getHealthAdvice(
      ingredientsData: ingredientsData,
      healthConditions: healthConditions,
    );
  }

  @override
  Future<String?> uploadScanImage(File imageFile) {
    return _storageService.uploadScanImage(imageFile);
  }

  @override
  Future<DocumentReference> addScan({
    required String result,
    required double confidence,
    List<String>? ingredients,
    Map<String, String>? ingredientPredictions,
    String? imageUrl,
    String? productName,
  }) {
    return _scanHistoryService.addScan(
      result: result,
      confidence: confidence,
      ingredients: ingredients,
      ingredientPredictions: ingredientPredictions,
      imageUrl: imageUrl,
      productName: productName,
    );
  }

  @override
  Stream<QuerySnapshot> getScans() {
    return _scanHistoryService.getScans();
  }

  @override
  Future<void> deleteScan(String id) {
    return _scanHistoryService.deleteScan(id);
  }

  @override
  Future<int> getScanCount() {
    return _scanHistoryService.getScanCount();
  }

  @override
  Future<int> getSafeCount() {
    return _scanHistoryService.getSafeCount();
  }

  @override
  Future<List<QueryDocumentSnapshot>> getRecentScans(int days) {
    return _scanHistoryService.getRecentScans(days);
  }

  @override
  Future<List<Map<String, dynamic>>> getMonthlyTrend() {
    return _scanHistoryService.getMonthlyTrend();
  }

  @override
  Map<String, dynamic> predictLocal(String text) {
    return _aiService.predict(text);
  }

  @override
  Future<bool> hasInternet() {
    return _networkService.hasInternet();
  }

  @override
  Future<String?> chatWithAI(List<Map<String, String>> messages) {
    return _groqService.chat(messages);
  }
}
