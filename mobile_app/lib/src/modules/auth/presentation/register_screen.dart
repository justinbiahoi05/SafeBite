import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/src/core/theme/app_colors.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'component/auth_text_field.dart';
import 'component/auth_button.dart';
import 'component/auth_header.dart';
import 'package:mobile_app/src/modules/home/presentation/home_screen.dart';

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
  bool _isLoading = false;
  String? _error;

  Future<void> _register() async {
    // Validation
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await AuthService().signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        displayName: _nameController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _getErrorMessage(e.code));
    } catch (e) {
      setState(() => _error = 'An error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      default:
        return 'Registration failed. Please try again.';
    }
  }

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
                        isLoading: _isLoading,
                        onPressed: _register,
                        icon: Icons.arrow_forward_rounded,
                      ),

                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

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
