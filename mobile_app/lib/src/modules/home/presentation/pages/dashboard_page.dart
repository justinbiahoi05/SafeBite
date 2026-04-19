import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF9FBF9), // Match background in screenshot
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: const NetworkImage('https://i.pravatar.cc/150?u=safebite'), // Placeholder
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'SafeBite',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.history_rounded, color: Colors.black54),
                ],
              ),
              const SizedBox(height: 32),

              // Daily Report Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'DAILY REPORT',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 34,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A),
                    fontFamily: 'Outfit',
                  ),
                  children: [
                    const TextSpan(text: 'Nourishing\n'),
                    TextSpan(
                      text: 'your vitality.',
                      style: TextStyle(color: AppColors.primaryGreen),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Today's intake shows 92% purity. Your gut health is thriving in the optimal greenhouse zone.",
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Safety Score Card
              _SafetyScoreCard(),
              const SizedBox(height: 24),

              // Ingredients Analyzed Card
              _IngredientsAnalyzedCard(),
              const SizedBox(height: 24),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      value: '84%',
                      label: 'SUGAR-FREE STREAK',
                      icon: Icons.show_chart_rounded,
                      color: const Color(0xFF04542C),
                      textColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      value: '12',
                      label: 'SMART TIPS',
                      icon: Icons.wb_incandescent_outlined,
                      color: const Color(0xFFEFEFEF),
                      textColor: const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Recent Scans Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Scans',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View Archive',
                      style: TextStyle(
                        color: Color(0xFF04542C),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              // Recent Scans List
              _RecentScanItem(
                name: 'Hass Avocado',
                time: '2 hours ago',
                tag: 'Organic',
                icon: Icons.eco_rounded,
                isSafe: true,
              ),
              _RecentScanItem(
                name: 'Dark Cacao 85%',
                time: '3 hours ago',
                tag: 'Clean Label',
                icon: Icons.check_circle_rounded,
                isSafe: true,
              ),
              _RecentScanItem(
                name: 'Wheat Pretzels',
                time: 'Yesterday',
                tag: 'Gluten Alert',
                icon: Icons.warning_amber_rounded,
                isSafe: false,
              ),

              const SizedBox(height: 120), // Padding for Bottom Navigation Bar
            ],
          ),
        ),
      ),
    );
  }
}

class _SafetyScoreCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFF04542C),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              '92',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SAFETY SCORE',
                style: TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
              Text(
                'Excellent',
                style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IngredientsAnalyzedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.eco_rounded, color: Color(0xFF04542C), size: 28),
          const SizedBox(height: 16),
          const Text(
            'Ingredients Analyzed',
            style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            "You've scanned 14 items today. All were free from your flagged allergens.",
            style: TextStyle(color: Color(0xFF666666), fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          _MiniTag(label: 'Organic Kale', status: 'Safe'),
          const SizedBox(height: 8),
          _MiniTag(label: 'Almond Milk', status: 'Safe'),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final String status;

  const _MiniTag({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBF9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF101010))),
          Text(status, style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryGreen, fontSize: 12)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor.withValues(alpha: 0.6), size: 20),
          const SizedBox(height: 20),
          Text(
            value,
            style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

class _RecentScanItem extends StatelessWidget {
  final String name;
  final String time;
  final String tag;
  final IconData icon;
  final bool isSafe;

  const _RecentScanItem({
    required this.name,
    required this.time,
    required this.tag,
    required this.icon,
    required this.isSafe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.blueGrey, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 4),
                Text(
                  '$time • $tag',
                  style: const TextStyle(color: Colors.black26, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Icon(
            isSafe ? Icons.check_circle_rounded : Icons.warning_rounded,
            color: isSafe ? AppColors.primaryGreen : Colors.redAccent,
            size: 20,
          ),
        ],
      ),
    );
  }
}
