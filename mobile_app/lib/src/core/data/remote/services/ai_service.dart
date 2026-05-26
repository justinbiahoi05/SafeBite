import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'package:injectable/injectable.dart';

@lazySingleton
class AIService {
  static final AIService _instance = AIService._internal();

  Interpreter? _interpreter;
  Map<String, dynamic>? _vocab;
  List<String>? _labels;
  final int _maxLength = 8;
  bool _isInitialized = false;

  AIService._internal();

  factory AIService() {
    return _instance;
  }

  bool get isInitialized => _isInitialized;

  Future<void> initAI() async {
    if (_isInitialized) {
      print("AI Service: Đã khởi tạo trước đó.");
      return;
    }

    try {
      _interpreter = await Interpreter.fromAsset('assets/ai/safebite_model_v3.tflite');

      String vocabJson = await rootBundle.loadString('assets/ai/vocab.json');
      _vocab = json.decode(vocabJson);

      String labelsJson = await rootBundle.loadString('assets/ai/labels.json');
      _labels = List<String>.from(json.decode(labelsJson));

      _isInitialized = true;
      print("AI Service: Khởi tạo thành công!");
    } catch (e) {
      _isInitialized = false;
      print("AI Service Error: Không thể khởi tạo AI - $e");
      rethrow;
    }
  }

  Map<String, dynamic> predict(String text) {
    if (!_isInitialized || _interpreter == null || _vocab == null || _labels == null) {
      return {
        "label": "Unknown",
        "confidence": 0.0
      };
    }

    List<double> input = _tokenize(text);

    var output = List<double>.filled(_labels!.length, 0).reshape([1, _labels!.length]);

    try {
      _interpreter!.run([input], output);
    } catch (e) {
      print("AI Service Inference Error: $e");
      return {"label": "Error", "confidence": 0.0};
    }

    List<double> results = output[0];
    int maxIdx = 0;
    double maxScore = 0;

    for (int i = 0; i < results.length; i++) {
      if (results[i] > maxScore) {
        maxScore = results[i];
        maxIdx = i;
      }
    }

    if (maxScore < 0.4) {
      return {
        "label": "Unknown",
        "confidence": maxScore
      };
    }

    return {
      "label": _labels![maxIdx],
      "confidence": maxScore
    };
  }

  List<double> _tokenize(String text) {
    String cleanText = text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ' ');

    List<String> words = cleanText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    List<double> sequence = [];

    for (var word in words) {
      sequence.add((_vocab![word] ?? 1).toDouble());
    }

    if (sequence.length < _maxLength) {
      while (sequence.length < _maxLength) {
        sequence.add(0.0);
      }
    } else {
      sequence = sequence.sublist(0, _maxLength);
    }

    return sequence;
  }
}
