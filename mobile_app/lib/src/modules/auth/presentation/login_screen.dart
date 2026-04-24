import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/src/core/theme/app_colors.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'component/auth_text_field.dart';
import 'component/auth_button.dart';
import 'component/auth_header.dart';
import 'register_screen.dart';
import 'package:mobile_app/src/modules/home/presentation/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await AuthService().signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
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
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      default:
        return 'Login failed. Please check your credentials.';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                  subtitle: 'Eat with confidence. Live with vitality.',
                ),
                const SizedBox(height: 30),

                // Login Card
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
                        'Welcome Back',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sign in to your healthy journey',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 32),
                      AuthTextField(
                        controller: _emailController,
                        label: 'EMAIL ADDRESS',
                        hint: 'name@example.com',
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 24),
                      AuthTextField(
                        controller: _passwordController,
                        label: 'PASSWORD',
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      AuthButton(
                        text: 'Log In',
                        isLoading: _isLoading,
                        onPressed: _login,
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

                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.black.withValues(alpha: 0.1),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR CONTINUE WITH',
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.4),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.black.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color: Colors.black.withValues(alpha: 0.08),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'G',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Google',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            children: [
                              const TextSpan(text: 'New to SafeBite? '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Create an account',
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
