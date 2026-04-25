import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/login_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.7,
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/app_image/getstart.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surface,
                    child: const Icon(
                      Icons.image,
                      color: Colors.white24,
                      size: 64,
                    ),
                  );
                },
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.flash_on_rounded,
                          size: 14,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'AI-POWERED SAFETY',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SafeBite',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        'Healthier Choices',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Empower your health with instant food label analysis and personalized nutrition tracking.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(flex: 2),

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accent, Color(0xFF16A34A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get Started',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 12),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
