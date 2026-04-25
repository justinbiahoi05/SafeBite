part of '../onboarding_screen.dart';

class OnboardingSectionLabel extends StatelessWidget {
  const OnboardingSectionLabel({
    super.key,
    required this.text,
    required this.accent,
  });

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: accent.withValues(alpha: 0.88),
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }
}

class OnboardingFeatureChip extends StatelessWidget {
  const OnboardingFeatureChip({
    super.key,
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPageIndicators extends StatelessWidget {
  const OnboardingPageIndicators({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.activeColor,
  });

  final int currentPage;
  final int totalPages;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? activeColor
                : Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
