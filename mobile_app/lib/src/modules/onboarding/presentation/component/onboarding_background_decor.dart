part of '../onboarding_screen.dart';

class OnboardingBackgroundDecor extends StatelessWidget {
  const OnboardingBackgroundDecor({
    super.key,
    required this.accent,
    required this.softAccent,
  });

  final Color accent;
  final Color softAccent;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -60,
            child: _GlowOrb(
              color: Colors.white.withValues(alpha: 0.04),
              size: 180,
            ),
          ),
          Positioned(
            top: 120,
            right: -40,
            child: _GlowOrb(color: accent.withValues(alpha: 0.08), size: 140),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: _GlowOrb(
              color: softAccent.withValues(alpha: 0.05),
              size: 180,
            ),
          ),
          Positioned(
            bottom: -70,
            right: -60,
            child: _GlowOrb(
              color: Colors.white.withValues(alpha: 0.03),
              size: 200,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
