import 'package:flutter/services.dart';

import 'package:injectable/injectable.dart';

@lazySingleton
class HapticService {
  Future<void> alertDanger() async {

    for (int i = 0; i < 3; i++) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  Future<void> alertSuccess() async {
    await HapticFeedback.lightImpact();
  }
}
