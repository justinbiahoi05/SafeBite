import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Map<String, bool> _healthConditions = {
    'Diabetes': false,
    'Kidney Disease': false,
    'Pregnancy': false,
    'Peanut Allergy': false,
    'Hypertension': false,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF9FDFB), Colors.white],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PERSONALIZATION',
                style: TextStyle(
                  color: AppColors.primaryGreen.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 42,
                    height: 1.1,
                    fontFamily:
                        'Outfit', // Assuming Outfit from theme, fallback to system
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A),
                  ),
                  children: [
                    const TextSpan(text: 'Your Health,\n'),
                    TextSpan(
                      text: 'Our Priority.',
                      style: TextStyle(color: AppColors.primaryGreen),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select your medical profile so we can filter ingredients that matter most to your vitality.',
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),

              // Health Options List
              _HealthOptionCard(
                title: 'Diabetes',
                subtitle: 'Monitors sugar and carb levels',
                icon: Icons.opacity_rounded,
                value: _healthConditions['Diabetes']!,
                onChanged: (val) =>
                    setState(() => _healthConditions['Diabetes'] = val),
              ),
              _HealthOptionCard(
                title: 'Kidney Disease',
                subtitle: 'Tracks sodium and potassium intake',
                icon: Icons.spa_rounded,
                value: _healthConditions['Kidney Disease']!,
                onChanged: (val) =>
                    setState(() => _healthConditions['Kidney Disease'] = val),
              ),
              _HealthOptionCard(
                title: 'Pregnancy',
                subtitle: 'Alerts for raw and unpasteurized items',
                icon: Icons.pregnant_woman_rounded,
                value: _healthConditions['Pregnancy']!,
                onChanged: (val) =>
                    setState(() => _healthConditions['Pregnancy'] = val),
              ),
              _HealthOptionCard(
                title: 'Peanut Allergy',
                subtitle: 'Strict warnings for nut derivatives',
                icon: Icons.emergency_rounded,
                value: _healthConditions['Peanut Allergy']!,
                onChanged: (val) =>
                    setState(() => _healthConditions['Peanut Allergy'] = val),
              ),
              _HealthOptionCard(
                title: 'Hypertension',
                subtitle: 'Monitors sodium and heart-health indicators',
                icon: Icons.favorite_rounded,
                value: _healthConditions['Hypertension']!,
                onChanged: (val) =>
                    setState(() => _healthConditions['Hypertension'] = val),
              ),

              const SizedBox(height: 40),

              // Save Button
              Container(
                width: double.infinity,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.buttonGradient,
                  ),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Save logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Text(
                    'Save Profile & Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'You can update these preferences anytime in settings.',
                  style: TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 120), // Extra space for bottom nav bar
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _HealthOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F7F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryGreen,
            activeTrackColor: AppColors.primaryGreen.withValues(alpha: 0.2),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFEEEEEE),
          ),
        ],
      ),
    );
  }
}
