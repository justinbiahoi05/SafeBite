import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../../services/scan_history_service.dart';
import 'archive_page.dart'; // THÊM IMPORT NÀY

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const Center(child: CircularProgressIndicator());

    return Container(
      decoration: const BoxDecoration(color: AppColors.scaffoldBackgroundLight),
      child: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: ScanHistoryService().getScans(),
          builder: (context, snapshot) {
            final scans = snapshot.data?.docs ?? [];
            final total = scans.length;
            final safeScans = scans.where((d) => d['result'] == 'safe').length;
            final cautionScans = total - safeScans;
            final score = total > 0 ? ((safeScans / total) * 100).round() : 100;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 12),
                  _buildVitalityText(score),
                  const SizedBox(height: 24),
                  
                  _SafetyScoreCard(score: score, totalScans: total, safeScans: safeScans),
                  const SizedBox(height: 24),

                  _IngredientsAnalyzedCard(totalScans: total),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: '$safeScans',
                          label: 'SAFE SCANS',
                          icon: Icons.eco_rounded,
                          color: Colors.white,
                          textColor: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          value: '$cautionScans',
                          label: 'CAUTION',
                          icon: Icons.warning_amber_rounded,
                          color: Colors.white,
                          textColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Recent Scans moved to Insights Page
                  const SizedBox(height: 100), 
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(100)),
      child: const Text('DAILY REPORT', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.0)),
    );
  }

  Widget _buildVitalityText(int score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 34, height: 1.1, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            children: [TextSpan(text: 'Nourishing\n'), TextSpan(text: 'your vitality.', style: TextStyle(color: AppColors.primaryGreen))],
          ),
        ),
        const SizedBox(height: 12),
        Text('Safety score: $score%. Your health journey is on track!', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    DateTime date = (timestamp as Timestamp).toDate();
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}

class _SafetyScoreCard extends StatelessWidget {
  final int score;
  final int totalScans;
  final int safeScans;
  const _SafetyScoreCard({required this.score, required this.totalScans, required this.safeScans});

  @override
  Widget build(BuildContext context) {
    final status = score >= 80 ? 'Excellent' : score >= 50 ? 'Good' : 'Needs Work';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Row(
        children: [
          CircleAvatar(radius: 25, backgroundColor: AppColors.primaryGreen, child: Text('$score', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18))),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('SAFETY SCORE', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w900)),
            Text(status, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900)),
          ]),
          const Spacer(),
          Text('$safeScans/$totalScans', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _IngredientsAnalyzedCard extends StatelessWidget {
  final int totalScans;
  const _IngredientsAnalyzedCard({required this.totalScans});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.eco_rounded, color: AppColors.primaryGreen),
          const SizedBox(height: 16),
          const Text('Ingredients Analyzed', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(totalScans > 0 ? "You've scanned $totalScans items this week." : 'Start scanning to track your food safety.', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
  const _StatCard({required this.value, required this.label, required this.icon, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(height: 20),
          Text(value, style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w900)),
          Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _RecentScanItem extends StatelessWidget {
  final String name;
  final String time;
  final String tag;
  final bool isSafe;
  const _RecentScanItem({required this.name, required this.time, required this.tag, required this.isSafe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Row(
        children: [
          Icon(isSafe ? Icons.check_circle : Icons.warning, color: isSafe ? AppColors.primaryGreen : Colors.redAccent),
          const SizedBox(width: 16),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Text('$time • $tag', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}