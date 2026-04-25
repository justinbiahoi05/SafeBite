import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.scaffoldBackgroundLight),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'PERSONAL ANALYTICS',
                style: TextStyle(
                  color: AppColors.primaryGreen.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 34,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                  children: [
                    const TextSpan(text: 'Your journey to\n'),
                    TextSpan(
                      text: 'cleaner living.',
                      style: TextStyle(color: AppColors.primaryGreen),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Tracking the invisible. We've analyzed your consumption patterns over the last 30 days to help you minimize processed additives and maximize vitality.",
                style: TextStyle(
                  color: AppColors.textSecondary,

                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Text(
                      '84',
                      style: TextStyle(
                        color: AppColors.textPrimary,

                        fontWeight: FontWeight.w900,
                        fontSize: 50,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          'VITALITY SCORE',
                          style: TextStyle(
                            color: AppColors.forestGreen,

                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 4),
                        Text(
                          '+12% this month',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primaryGreen,
                      size: 25,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Additive Intake Trend',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Daily chemical exposure levels',
                              style: TextStyle(
                                color: AppColors.mutedText.withValues(
                                  alpha: 0.6,
                                ),

                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Text(
                            'Monthly',
                            style: TextStyle(
                              color: AppColors.forestGreen,

                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const _SimpleBarChart(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'OCT 01',
                          style: TextStyle(
                            color: AppColors.mutedText.withValues(alpha: 0.5),

                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'OCT 15',
                          style: TextStyle(
                            color: AppColors.mutedText.withValues(alpha: 0.5),

                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'OCT 30',
                          style: TextStyle(
                            color: AppColors.mutedText.withValues(alpha: 0.5),

                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen,

                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.verified_rounded, color: Colors.white, size: 32),
                    const SizedBox(height: 40),
                    const Text(
                      '214',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'SAFE PRODUCTS FOUND',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Scans',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View full archive →',
                      style: TextStyle(
                        color: AppColors.textSecondary,

                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _InsightItem(
                name: 'Greek Yogurt, Plain',
                brand: 'PurelyOrganic Farms',
                time: '2h ago',
                status: 'SAFE',
                isWarning: false,
              ),
              _InsightItem(
                name: 'Citrus Sparkle Soda',
                brand: 'Health Beverages',
                time: 'Yesterday',
                status: 'HIGH ADDITIVE',
                isWarning: true,
              ),
              _InsightItem(
                name: '85% Dark Cacao Bar',
                brand: 'Velvet Batch',
                time: 'Oct 24',
                status: 'SAFE',
                isWarning: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleBarChart extends StatelessWidget {
  const _SimpleBarChart();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _Bar(height: 60, color: Colors.grey.shade100),
          _Bar(height: 80, color: Colors.grey.shade100),
          _Bar(height: 40, color: AppColors.accent.withValues(alpha: 0.3)),
          _Bar(height: 110, color: AppColors.forestGreen, hasIndicator: true),

          _Bar(height: 70, color: Colors.grey.shade100),
          _Bar(height: 90, color: AppColors.accent.withValues(alpha: 0.3)),
          _Bar(height: 120, color: AppColors.forestGreen),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final Color color;
  final bool hasIndicator;

  const _Bar({
    required this.height,
    required this.color,
    this.hasIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (hasIndicator)
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
        Container(
          width: 20,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ],
    );
  }
}

class _InsightItem extends StatelessWidget {
  final String name;
  final String brand;
  final String time;
  final String status;
  final bool isWarning;

  const _InsightItem({
    required this.name,
    required this.brand,
    required this.time,
    required this.status,
    required this.isWarning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
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
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.blueGrey,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$brand • $time',
                  style: const TextStyle(
                    color: AppColors.textSecondary,

                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textPrimary,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isWarning
                      ? Colors.red.withValues(alpha: 0.1)
                      : AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isWarning ? Colors.red : AppColors.primaryGreen,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
