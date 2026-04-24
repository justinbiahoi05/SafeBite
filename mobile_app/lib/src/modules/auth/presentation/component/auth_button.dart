import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          gradient: isEnabled
              ? const LinearGradient(
                  colors: AppColors.buttonGradient,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.grey.shade400,
                    Colors.grey.shade500,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.buttonPrimary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),

        child: ElevatedButton(
          onPressed: isEnabled && !isLoading ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (icon != null) ...[
                      const SizedBox(width: 8),
                      Icon(icon, size: 20, color: Colors.white),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
