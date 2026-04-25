import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  // Khởi tạo bộ nhận diện văn bản
  static final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  static Future<String> recognizeTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      return recognizedText.text.trim().isEmpty 
          ? "Không tìm thấy văn bản nào trên bao bì." 
          : recognizedText.text;
    } catch (e) {
      return "Lỗi khi quét OCR: $e";
    }
  }

  static void dispose() {
    _textRecognizer.close();
  }
}