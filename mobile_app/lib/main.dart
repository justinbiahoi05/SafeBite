import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'package:mobile_app/src/core/theme/app_colors.dart';
import 'package:mobile_app/services/onboarding_service.dart';

import 'services/ai_service.dart';
import 'services/health_logic.dart'; // THÊM IMPORT NÀY
import 'src/modules/onboarding/presentation/onboarding_screen.dart';
import 'src/modules/getstart/presentation/get_started_screen.dart';
import 'src/modules/auth/presentation/login_screen.dart';
import 'src/modules/home/presentation/home_screen.dart';

void main() async {
  // Đảm bảo Flutter engine đã khởi tạo trước khi gọi các plugin Native
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 2. Khởi tạo các dịch vụ AI và Dữ liệu y khoa
  try {
    // Khởi tạo bộ não AI (Model TFLite)
    await AIService().initAI();
    
    // Khởi tạo Ma trận logic 16 bệnh lý (File JSON của Hoàng)
    await HealthLogic.loadRawDb(); 
    
    print("Main: All Services initialized successfully!");
  } catch (e) {
    print("Main: Failed to initialize services - $e");
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
      // Use onGenerateRoute for proper route handling
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const AuthWrapper(),
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.background,
        // Cấu hình Font chữ mặc định cho toàn App
        textTheme: Typography.whiteMountainView.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
          fontFamily: 'Inter', 
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
    // Màn hình chờ khi đang kiểm tra dữ liệu
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
        // Đang kết nối với Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }

        // LUỒNG ĐIỀU HƯỚNG THÔNG MINH:
        
        // 1. Nếu đã đăng nhập (Firebase có User) -> Vào thẳng màn hình chính
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // 2. Nếu chưa đăng nhập và là người dùng mới -> Xem giới thiệu (Onboarding)
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

        // 3. Nếu đã xem giới thiệu nhưng chưa đăng nhập -> Vào màn Login
        return const LoginScreen();
      },
    );
  }
}