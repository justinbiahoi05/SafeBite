import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'component/auth_text_field.dart';
import 'component/auth_button.dart';
import 'component/auth_header.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.authGradient,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                const AuthHeader(
                  title: 'SafeBite',
                  subtitle: 'Start your healthy journey today.',
                ),
                const SizedBox(height: 30),

                // Register Card
                Container(
                  padding: const EdgeInsets.all(28.0),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Join SafeBite',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Create an account to eat with confidence.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Name Field
                      AuthTextField(
                        controller: _nameController,
                        label: 'FULL NAME',
                        hint: 'John Doe',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      AuthTextField(
                        controller: _emailController,
                        label: 'EMAIL ADDRESS',
                        hint: 'name@example.com',
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      AuthTextField(
                        controller: _passwordController,
                        label: 'PASSWORD',
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                      ),
                      const SizedBox(height: 20),

                      // Confirm Password Field
                      AuthTextField(
                        controller: _confirmPasswordController,
                        label: 'CONFIRM PASSWORD',
                        hint: '••••••••',
                        icon: Icons.lock_reset_rounded,
                        isPassword: true,
                      ),
                      const SizedBox(height: 32),

                      // Sign Up Button
                      AuthButton(
                        text: 'Sign Up',
                        onPressed: () {},
                        icon: Icons.arrow_forward_rounded,
                      ),

                      const SizedBox(height: 32),

                      // Login Link
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            children: [
                              const TextSpan(text: 'Already have an account? '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: const Text(
                                    'Log In',
                                    style: TextStyle(
                                      color: AppColors.primaryGreen,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Security Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_rounded,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '100% ORGANIC SECURITY',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
