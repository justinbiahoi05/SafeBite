import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class OCRService {
  static final _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  static Future<String> recognizeTextInFrame(
    File imageFile,
    Rect scanWindow,
    Size screenSize,
  ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return "Không thể đọc định dạng ảnh";

      // Fix orientation
      image = img.bakeOrientation(image);

      final imgW = image.width.toDouble();
      final imgH = image.height.toDouble();
      final scrW = screenSize.width;
      final scrH = screenSize.height;

      // BoxFit.cover scale
      final scale = math.max(scrW / imgW, scrH / imgH);
      final displayedImgW = imgW * scale;
      final displayedImgH = imgH * scale;

      // Phần ảnh bị cắt khi cover
      final leftOffset = (displayedImgW - scrW) / 2;
      final topOffset = (displayedImgH - scrH) / 2;

      const paddingSide = 10.0;

      int cropX =
          ((scanWindow.left + leftOffset - paddingSide) / scale).round();
      int cropY =
          ((scanWindow.top + topOffset) / scale).round();
      int cropW =
          ((scanWindow.width - paddingSide * 2) / scale).round();
      int cropH =
          ((scanWindow.height) / scale).round();

      // 🔥 Kéo lên thêm 30% chiều cao khung
      cropY = (cropY - (cropH * 0.3)).round();

      // Clamp tránh vượt biên
      cropX = cropX.clamp(0, image.width - 1);
      cropY = cropY.clamp(0, image.height - 1);
      cropW = cropW.clamp(1, image.width - cropX);
      cropH = cropH.clamp(1, image.height - cropY);

      // Crop ảnh
      final cropped = img.copyCrop(
        image,
        x: cropX,
        y: cropY,
        width: cropW,
        height: cropH,
      );

      // Lưu tạm để ML Kit đọc
      final tempFile = File(
        '${Directory.systemTemp.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(img.encodeJpg(cropped));

      final inputImage = InputImage.fromFilePath(tempFile.path);
      final result = await _textRecognizer.processImage(inputImage);

      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      // ✅ Lấy text theo từng dòng ML Kit
      return _extractLines(result);
    } catch (e) {
      return "Lỗi hệ thống: $e";
    }
  }

  // ✅ Lấy từng dòng text chuẩn từ ML Kit
  static String _extractLines(RecognizedText result) {
    final List<String> lines = [];

    for (final block in result.blocks) {
      for (final line in block.lines) {
        String text = line.text.trim();

        // Làm sạch rác đầu/cuối
        text = text.replaceAll(
          RegExp(r'^[^a-zA-Z0-9]+|[^a-zA-Z0-9%)]+$'),
          '',
        );

        if (text.length > 2) {
          lines.add(text);
        }
      }
    }

    return lines.join('\n');
  }
}