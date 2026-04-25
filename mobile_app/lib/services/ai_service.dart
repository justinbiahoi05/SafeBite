import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class AIService {
  // Singleton pattern
  static final AIService _instance = AIService._internal();

  Interpreter? _interpreter;
  Map<String, dynamic>? _vocab;
  List<String>? _labels;
  final int _maxLength = 8; // Phải khớp với max_length lúc train
  bool _isInitialized = false;

  // Private constructor
  AIService._internal();

  // Factory constructor - trả về instance duy nhất
  factory AIService() {
    return _instance;
  }

  // Getter để kiểm tra trạng thái khởi tạo
  bool get isInitialized => _isInitialized;

  /// Khởi tạo AI (Gọi hàm này ở main.dart khi mở App)
  /// Model AI chỉ được load một lần duy nhất trong suốt vòng đời ứng dụng
  Future<void> initAI() async {
    if (_isInitialized) {
      print("AI Service: Already initialized!");
      return;
    }

    try {
      // Load Model
      _interpreter = await Interpreter.fromAsset('assets/ai/safebite_model.tflite');

      // Load Vocab
      String vocabJson = await rootBundle.loadString('assets/ai/vocab.json');
      _vocab = json.decode(vocabJson);

      // Load Labels
      String labelsJson = await rootBundle.loadString('assets/ai/labels.json');
      _labels = List<String>.from(json.decode(labelsJson));

      _isInitialized = true;
      print("AI Service: Successfully initialized!");
    } catch (e) {
      _isInitialized = false;
      print("AI Service Error: $e");
      rethrow;
    }
  }

  /// Hàm dự đoán - trả về nhãn từ labels.json dựa trên xác suất cao nhất
  /// Nếu xác suất < 0.4, trả về 'Unknown'
  String predict(String text) {
    if (!_isInitialized || _interpreter == null || _vocab == null || _labels == null) {
      return "Unknown";
    }

    // Tiền xử lý: Chuyển text thành mảng số (Tokenization)
    List<double> input = _tokenize(text);

    // Chuẩn bị đầu ra (Mảng chứa số lượng nhãn xác suất)
    var output =
        List<double>.filled(_labels!.length, 0).reshape([1, _labels!.length]);

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
    if (maxScore < 0.4) {
      return "Unknown";
    }

    return _labels![maxIdx];
  }

  /// Hàm biến chữ thành số (Tokenization)
  /// - Loại bỏ các ký tự đặc biệt (dấu phẩy, chấm, ngoặc) trước khi split
  /// - Đảm bảo kết quả khớp chính xác với vocab.json
  List<double> _tokenize(String text) {
    // Chuyển về chữ thường
    String cleanText = text.toLowerCase();

    // Loại bỏ các ký tự đặc biệt (dấu phẩy, chấm, ngoặc, v.v)
    // Giữ lại khoảng trắng và các ký tự chữ cái, số
    cleanText = cleanText.replaceAll(RegExp(r'[^\w\s]'), ' ');

    // Split thành từng từ
    List<String> words = cleanText.split(RegExp(r'\s+'));

    // Loại bỏ các từ rỗng
    words = words.where((word) => word.isNotEmpty).toList();

    List<double> sequence = [];

    for (var word in words) {
      // Nếu có trong từ điển thì lấy ID, không thì lấy ID của <OOV> (thường là 1)
      sequence.add((_vocab![word] ?? 1).toDouble());
    }

    // Padding cho đủ _maxLength phần tử với giá trị 0
    while (sequence.length < _maxLength) {
      sequence.add(0.0);
    }

    // Cắt bỏ các phần tử vượt quá _maxLength
    return sequence.sublist(0, _maxLength);
  }
}