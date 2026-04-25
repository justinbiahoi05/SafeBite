import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile_app/services/scan_history_service.dart';
import '../../../../core/theme/app_colors.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  final _scanService = ScanHistoryService();
  final _user = FirebaseAuth.instance.currentUser;

  int _totalScans = 0;
  int _safeScans = 0;
  int _dangerScans = 0;
  bool _isLoading = true;
  List<dynamic> _recentScans = [];
  bool _isWeekly = true;
  List<Map<String, dynamic>> _trendData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final total = await _scanService.getScanCount();
      final safe = await _scanService.getSafeCount();
      final recent = await _scanService.getRecentScans(30);
      final trend = _isWeekly
          ? await _scanService.getWeeklyTrend()
          : await _scanService.getMonthlyTrend();

      setState(() {
        _totalScans = total;
        _safeScans = safe;
        _dangerScans = total - safe;
        _recentScans = recent;
        _trendData = trend;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _togglePeriod(bool weekly) {
    if (_isWeekly == weekly) return;
    setState(() {
      _isWeekly = weekly;
      _isLoading = true;
    });
    _loadData();
  }

  int get _vitalityScore {
    if (_totalScans == 0) return 0;
    return ((_safeScans / _totalScans) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(color: AppColors.scaffoldBackgroundLight),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  "Tracking the invisible. We've analyzed your consumption patterns over the last 30 days to help you minimize processed additives and maximize vitality.",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),

                // Vitality Score Card
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
                      Text(
                        '$_vitalityScore',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 50,
                        ),
                      ),
                      Column(
                        children: [
                          const Text(
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
                            '$_totalScans scans',
                            style: const TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primaryGreen,
                        size: 25,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'SAFE',
                        value: '$_safeScans',
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        label: 'CAUTION',
                        value: '$_dangerScans',
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Period Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PeriodButton(
                      label: 'Weekly',
                      isSelected: _isWeekly,
                      onTap: () => _togglePeriod(true),
                    ),
                    const SizedBox(width: 12),
                    _PeriodButton(
                      label: 'Monthly',
                      isSelected: !_isWeekly,
                      onTap: () => _togglePeriod(false),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Trend Chart
                if (_trendData.isNotEmpty)
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          // Safe line (green)
                          LineChartBarData(
                            spots: _trendData.asMap().entries.map((e) {
                              return FlSpot(
                                e.key.toDouble(),
                                (e.value['safe'] as int).toDouble(),
                              );
                            }).toList(),
                            isCurved: true,
                            color: AppColors.primaryGreen,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primaryGreen.withValues(alpha: 0.1),
                            ),
                          ),
                          // Total line (gray)
                          LineChartBarData(
                            spots: _trendData.asMap().entries.map((e) {
                              return FlSpot(
                                e.key.toDouble(),
                                (e.value['total'] as int).toDouble(),
                              );
                            }).toList(),
                            isCurved: true,
                            color: Colors.grey,
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'No trend data yet',
                        style: TextStyle(color: AppColors.mutedText),
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

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
                      onPressed: _loadData,
                      child: const Text(
                        'Refresh →',
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

                if (_recentScans.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Text(
                        'No scans yet. Start scanning!',
                        style: TextStyle(color: AppColors.mutedText),
                      ),
                    ),
                  )
                else
                  ..._recentScans.take(5).map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final result = data['result'] as String? ?? 'Unknown';
                    final isSafe = result == 'safe';
                    return _InsightItem(
                      name: (data['ingredients'] as List?)?.join(', ') ?? 'N/A',
                      brand: data['createdAt']?.toString().split(' ')[0] ?? 'Recently',
                      time: _formatTime(data['createdAt']),
                      status: result.toUpperCase(),
                      isWarning: !isSafe,
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'Recently';
    try {
      final dt = (timestamp as Timestamp).toDate();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${diff.inDays ~/ 7}w ago';
    } catch (e) {
      return 'Recently';
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
            child: Icon(
              isWarning ? Icons.warning_amber : Icons.eco,
              color: isWarning ? Colors.orange : Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isWarning
                  ? Colors.red.withValues(alpha: 0.1)
                  : AppColors.primaryGreen.withValues(alpha: 0.1),
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
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}