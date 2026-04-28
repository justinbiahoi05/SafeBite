import 'package:flutter/services.dart';

class HapticService {
  static Future<void> alertDanger() async {
    // Rung mạnh 3 lần liên tiếp để cảnh báo
    for (int i = 0; i < 3; i++) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  static Future<void> alertSuccess() async {
    await HapticFeedback.lightImpact();
  }
}