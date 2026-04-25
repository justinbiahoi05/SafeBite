part of '../onboarding_screen.dart';

class OnboardingBrandMark extends StatelessWidget {
  const OnboardingBrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.28)),
          ),
          child: const Icon(
            Icons.eco_rounded,
            color: AppColors.accent,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'SafeBite',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
