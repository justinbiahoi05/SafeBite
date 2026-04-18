import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class AIService {
  Interpreter? _interpreter;
  Map<String, dynamic>? _vocab;
  List<String>? _labels;
  final int _maxLength = 8; // Phải khớp với max_length lúc train

  // 1. Khởi tạo AI (Gọi hàm này khi mở App)
  Future<void> initAI() async {
    try {
      // Load Model
      _interpreter = await Interpreter.fromAsset('assets/ai/safebite_model.tflite');
      
      // Load Vocab
      String vocabJson = await rootBundle.loadString('assets/ai/vocab.json');
      _vocab = json.decode(vocabJson);
      
      // Load Labels
      String labelsJson = await rootBundle.loadString('assets/ai/labels.json');
      _labels = List<String>.from(json.decode(labelsJson));
      
      print("AI Service: Ready!");
    } catch (e) {
      print("AI Service Error: $e");
    }
  }

  // 2. Hàm dự đoán (Hàm Duy sẽ gọi)
  String predict(String text) {
    if (_interpreter == null || _vocab == null || _labels == null) return "Unknown";

    // Tiền xử lý: Chuyển text thành mảng số (Tokenization)
    List<double> input = _tokenize(text);
    
    // Chuẩn bị đầu ra (Mảng chứa 9 xác suất)
    var output = List<double>.filled(_labels!.length, 0).reshape([1, _labels!.length]);

    // Chạy AI
    _interpreter!.run([input], output);

    // Lấy nhãn có xác suất cao nhất
    List<double> results = output[0];
    int maxIdx = 0;
    double maxScore = 0;
    
    for (int i = 0; i < results.length; i++) {
      if (results[i] > maxScore) {
        maxScore = results[i];
        maxIdx = i;
      }
    }

    // Nếu AI quá phân vân (dưới 40%), báo unknown cho an toàn
    if (maxScore < 0.4) return "Unknown";

    return _labels![maxIdx];
  }

  // Hàm biến chữ thành số (Phải giống hệt lúc train bằng Python)
  List<double> _tokenize(String text) {
    List<String> words = text.toLowerCase().split(' ');
    List<double> sequence = [];

    for (var word in words) {
      // Nếu có trong từ điển thì lấy ID, không thì lấy ID của <OOV> (thường là 1)
      sequence.add((_vocab![word] ?? 1).toDouble());
    }

    // Padding cho đủ 8 phần tử
    while (sequence.length < _maxLength) {
      sequence.add(0.0);
    }
    
    return sequence.sublist(0, _maxLength);
  }
}