import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'package:mobile_app/src/core/theme/app_colors.dart';
import 'package:mobile_app/services/onboarding_service.dart';

import 'services/ai_service.dart';
import 'src/modules/onboarding/presentation/onboarding_screen.dart';
import 'src/modules/getstart/presentation/get_started_screen.dart';
import 'src/modules/auth/presentation/login_screen.dart';
import 'src/modules/home/presentation/home_screen.dart';

void main() async {
  // Đảm bảo Flutter engine đã khởi tạo trước khi gọi các plugin Native (Firebase, AI)
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 2. Khởi tạo AI Service (Model TFLite)
  // Bọc trong try-catch để tránh crash app nếu model không load được
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
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isOnboardingComplete = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final complete = await OnboardingService.isOnboardingComplete();
    if (mounted) {
      setState(() {
        _isOnboardingComplete = complete;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }

        // Nếu đã đăng nhập (Firebase có data) -> Vào Home
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Nếu chưa đăng nhập:
        // 1. Kiểm tra Onboarding (cho người dùng mới)
        if (!_isOnboardingComplete) {
          return OnboardingScreen(
            onComplete: () async {
              await OnboardingService.setOnboardingComplete();
              if (mounted) {
                setState(() => _isOnboardingComplete = true);
              }
            },
          );
        }

        // 2. Nếu đã xem Onboarding rồi thì hiện màn Login
        return const LoginScreen();
      },
    );
  }
}