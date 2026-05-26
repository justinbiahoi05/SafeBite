import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/src/core/data/remote/services/gemini_service.dart';
import 'firebase_options.dart';

import 'package:mobile_app/src/core/theme/app_colors.dart';
import 'package:mobile_app/src/core/data/remote/services/onboarding_service.dart';

import 'package:mobile_app/src/core/data/remote/services/ai_service.dart';
import 'package:mobile_app/src/core/data/remote/services/health_logic.dart';
import 'package:mobile_app/src/common/utils/getit_utils.dart';
import 'src/modules/onboarding/presentation/onboarding_screen.dart';
import 'src/modules/getstart/presentation/get_started_screen.dart';
import 'src/modules/auth/presentation/login_screen.dart';
import 'src/modules/home/presentation/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  configureDependencies();

  try {
    await getIt<AIService>().initAI();

    await HealthLogic.loadRawDb();
  } catch (e) {
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
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const AuthWrapper());
      },
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
    final complete = await getIt<OnboardingService>().isOnboardingComplete();
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
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
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

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        if (!_isOnboardingComplete) {
          return OnboardingScreen(
            onComplete: () async {
              await getIt<OnboardingService>().setOnboardingComplete();
              if (mounted) {
                setState(() => _isOnboardingComplete = true);
              }
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
