import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class AIService {
  // Singleton pattern: Đảm bảo chỉ có một thực thể duy nhất trong suốt app
  static final AIService _instance = AIService._internal();

  Interpreter? _interpreter;
  Map<String, dynamic>? _vocab;
  List<String>? _labels;
  final int _maxLength = 8; // Phải khớp với tham số lúc train model
  bool _isInitialized = false;

  // Private constructor
  AIService._internal();

  // Factory constructor
  factory AIService() {
    return _instance;
  }

  // Kiểm tra xem AI đã sẵn sàng chưa
  bool get isInitialized => _isInitialized;

  /// Khởi tạo AI: Load model, vocab và labels từ assets
  /// Cần gọi 'await AIService().initAI()' trong main.dart
  Future<void> initAI() async {
    if (_isInitialized) {
      print("AI Service: Đã khởi tạo trước đó.");
      return;
    }

    try {
      // 1. Load Model TFLite
      _interpreter = await Interpreter.fromAsset('assets/ai/safebite_model_v3.tflite');

      // 2. Load Từ điển (Vocab) để chuyển chữ thành số
      String vocabJson = await rootBundle.loadString('assets/ai/vocab.json');
      _vocab = json.decode(vocabJson);

      // 3. Load Danh sách nhãn (Labels) - ví dụ: ['safe', 'caution', 'danger']
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

  /// Hàm dự đoán chính: Trả về Map chứa kết quả và độ tự tin
  /// Để tránh lỗi 'type Map can't be assigned to String', 
  /// nơi gọi hàm này cần dùng: AIService().predict(text)['label']
  Map<String, dynamic> predict(String text) {
    // Kiểm tra an toàn trước khi chạy
    if (!_isInitialized || _interpreter == null || _vocab == null || _labels == null) {
      return {
        "label": "Unknown", 
        "confidence": 0.0
      };
    }

    // Bước 1: Tiền xử lý văn bản (Tokenization)
    List<double> input = _tokenize(text);

    // Bước 2: Chuẩn bị mảng đầu ra (Output tensor)
    // Tạo mảng 2 chiều [1, số_lượng_nhãn] chứa toàn số 0
    var output = List<double>.filled(_labels!.length, 0).reshape([1, _labels!.length]);

    // Bước 3: Chạy Inference (Suy luận)
    try {
      _interpreter!.run([input], output);
    } catch (e) {
      print("AI Service Inference Error: $e");
      return {"label": "Error", "confidence": 0.0};
    }

    // Bước 4: Xử lý kết quả đầu ra
    List<double> results = output[0];
    int maxIdx = 0;
    double maxScore = 0;

    // Tìm nhãn có xác suất (score) cao nhất
    for (int i = 0; i < results.length; i++) {
      if (results[i] > maxScore) {
        maxScore = results[i];
        maxIdx = i;
      }
    }

    // Bước 5: Ngưỡng an toàn (Threshold)
    // Nếu AI đoán với xác suất < 40%, coi như không biết để đảm bảo an toàn cho người dùng
    if (maxScore < 0.4) {
      return {
        "label": "Unknown", 
        "confidence": maxScore
      };
    }

    return {
      "label": _labels![maxIdx], // Trả về nhãn (ví dụ: 'safe')
      "confidence": maxScore      // Trả về độ tin cậy (ví dụ: 0.98)
    };
  }

  /// Hàm biến đổi văn bản thành dãy số (Vectorization)
  List<double> _tokenize(String text) {
    // Chuẩn hóa: viết thường và xóa ký tự lạ
    String cleanText = text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ' ');

    // Cắt chuỗi thành danh sách từ
    List<String> words = cleanText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    List<double> sequence = [];

    for (var word in words) {
      // Lấy ID từ vocab, nếu không có thì dùng ID 1 (thường là mã của <OOV> - Out Of Vocabulary)
      sequence.add((_vocab![word] ?? 1).toDouble());
    }

    // Padding & Truncating: Đảm bảo độ dài luôn bằng _maxLength (8)
    if (sequence.length < _maxLength) {
      // Thiếu thì bù số 0 vào cuối
      while (sequence.length < _maxLength) {
        sequence.add(0.0);
      }
    } else {
      // Thừa thì cắt bớt
      sequence = sequence.sublist(0, _maxLength);
    }

    return sequence;
  }
}