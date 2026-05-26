import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'package:injectable/injectable.dart';

@lazySingleton
class OCRService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> recognizeTextFromImage(File imageFile) async {
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

  void dispose() {
    _textRecognizer.close();
  }
}
