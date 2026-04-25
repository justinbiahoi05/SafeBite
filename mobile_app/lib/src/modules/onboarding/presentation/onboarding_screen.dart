import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_app/src/core/theme/app_colors.dart';
import 'package:mobile_app/src/modules/getstart/presentation/get_started_screen.dart';
part 'component/onboarding_background_decor.dart';
part 'component/onboarding_brand_mark.dart';
part 'component/onboarding_hero_panel.dart';
part 'component/onboarding_meta_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  void _skip() => _openHome();

  void _next() {
    if (_currentPage < onboardingPages.length - 1) {
      _animateToPage(_currentPage + 1);
    } else {
      _openHome();
    }
  }

  void _openHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const GetStartedScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = onboardingPages[_currentPage];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              currentPage.accent.withValues(alpha: 0.18),
              AppColors.darkGreen,
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          children: [
            OnboardingBackgroundDecor(
              accent: currentPage.accent,
              softAccent: currentPage.softAccent,
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 20, 6),
                    child: Row(
                      children: [
                        const OnboardingBrandMark(),
                        const Spacer(),
                        TextButton(
                          onPressed: _skip,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.mutedText,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: onboardingPages.length,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return _OnboardingPage(page: onboardingPages[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OnboardingPageIndicators(
                          currentPage: _currentPage,
                          totalPages: onboardingPages.length,
                          activeColor: currentPage.accent,
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentPage.accent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: Tween<double>(
                                      begin: 0.98,
                                      end: 1.0,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: KeyedSubtree(
                                key: ValueKey<int>(_currentPage),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _currentPage == onboardingPages.length - 1
                                          ? 'Start'
                                          : 'Next',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.15,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.page});

  final OnboardingPageData page;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.displaySmall?.copyWith(
      fontSize: 34,
      height: 0.96,
      fontWeight: FontWeight.w900,
      letterSpacing: -1.1,
      color: Colors.white,
    );

    final bodyStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontSize: 15.5,
      height: 1.55,
      color: AppColors.mutedText,
    );

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        OnboardingSectionLabel(text: page.badge, accent: page.accent),
        const SizedBox(height: 16),
        OnboardingHeroPanel(page: page),
        const SizedBox(height: 24),
        Text(page.titlePrefix, style: titleStyle),
        Text(page.titleAccent, style: titleStyle?.copyWith(color: page.accent)),
        const SizedBox(height: 12),
        Text(page.description, style: bodyStyle),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: page.chips
              .map(
                (chip) => OnboardingFeatureChip(
                  icon: chip.icon,
                  label: chip.label,
                  accent: page.accent,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class OnboardingPageData {
  const OnboardingPageData({
    required this.badge,
    required this.titlePrefix,
    required this.titleAccent,
    required this.description,
    required this.chips,
    required this.accent,
    required this.softAccent,
    required this.heroKind,
  });

  final String badge;
  final String titlePrefix;
  final String titleAccent;
  final String description;
  final List<FeatureChipData> chips;
  final Color accent;
  final Color softAccent;
  final HeroKind heroKind;
}

class FeatureChipData {
  const FeatureChipData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

enum HeroKind { scan, analytics, guardian }

const List<OnboardingPageData> onboardingPages = [
  OnboardingPageData(
    badge: 'ONBOARDING 01',
    titlePrefix: 'Smart',
    titleAccent: 'Scanning',
    description:
        'Point your camera at any food label and SafeBite highlights additives, nutrition notes, and allergen risks in real time.',
    chips: [
      FeatureChipData(
        icon: Icons.center_focus_strong_rounded,
        label: 'Live camera scan',
      ),
      FeatureChipData(
        icon: Icons.wifi_tethering_rounded,
        label: 'Instant analysis',
      ),
      FeatureChipData(icon: Icons.no_food_rounded, label: 'Hidden additives'),
    ],
    accent: AppColors.accent,
    softAccent: AppColors.accentSoft,
    heroKind: HeroKind.scan,
  ),
  OnboardingPageData(
    badge: 'ONBOARDING 02',
    titlePrefix: 'Track Your',
    titleAccent: 'Journey',
    description:
        'See your clean streak, weekly vitality, and the meals that keep your routine on track.',
    chips: [
      FeatureChipData(icon: Icons.show_chart_rounded, label: 'Weekly trend'),
      FeatureChipData(
        icon: Icons.local_fire_department_rounded,
        label: '12 day streak',
      ),
      FeatureChipData(icon: Icons.insights_rounded, label: '+14% vitality'),
    ],
    accent: Color(0xFF48D47D),
    softAccent: Color(0xFFA7F3C1),
    heroKind: HeroKind.analytics,
  ),
  OnboardingPageData(
    badge: 'ONBOARDING 03',
    titlePrefix: 'Your Personal',
    titleAccent: 'Food Guardian',
    description:
        'Get simple warnings before you eat, so every choice feels safer and easier.',
    chips: [
      FeatureChipData(icon: Icons.verified_rounded, label: 'Safety verified'),
      FeatureChipData(
        icon: Icons.report_gmailerrorred_rounded,
        label: 'Allergen alerts',
      ),
      FeatureChipData(icon: Icons.shield_rounded, label: 'Smart protection'),
    ],
    accent: Color(0xFF22C55E),
    softAccent: Color(0xFF97F0B9),
    heroKind: HeroKind.guardian,
  ),
];
