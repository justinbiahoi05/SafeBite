import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.buttonGradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.buttonPrimary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          child: Row(
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
