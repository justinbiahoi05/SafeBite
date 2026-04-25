import 'package:flutter/material.dart';
import 'package:mobile_app/src/core/theme/app_colors.dart';

import 'services/ai_service.dart';
import 'src/modules/onboarding/presentation/onboarding_screen.dart';

void main() async {
  // Đảm bảo Flutter engine đã khởi tạo
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo AI Service trước khi chạy ứng dụng
  // Model TFLite chỉ được load một lần duy nhất
  try {
    await AIService().initAI();
    print("Main: AI Service initialized successfully!");
  } catch (e) {
    print("Main: Failed to initialize AI Service - $e");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeBite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: Typography.whiteMountainView.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}
