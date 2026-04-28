import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../services/scan_history_service.dart';
import '../../../../core/theme/app_colors.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundLight, // Đồng bộ màu nền Dashboard
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("HEALTH INSIGHTS", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 16)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ScanHistoryService().getWeeklyTrend(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }
          final data = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Weekly Trend", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 24),

                // KHUNG BIỂU ĐỒ (Màu trắng giống Card Dashboard)
                Container(
                  height: 250,
                  padding: const EdgeInsets.fromLTRB(10, 25, 20, 10),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(24), 
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                  ),
                  child: BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: _buildTitles(),
                      borderData: FlBorderData(show: false),
                      barGroups: data.asMap().entries.map((e) {
                        return BarChartGroupData(x: e.key, barRods: [
                          BarChartRodData(toY: e.value['total'].toDouble(), color: Colors.grey.shade300, width: 14, borderRadius: BorderRadius.circular(4)),
                          BarChartRodData(toY: e.value['safe'].toDouble(), color: AppColors.primaryGreen, width: 14, borderRadius: BorderRadius.circular(4)),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                const Text("Smart Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                
                // Đã đổi logic thành đếm sản phẩm có hại (Caution) thay vì đếm tổng
                _buildSummaryTile("Caution Items Detected", "${_calculateCaution(data)} items", Icons.warning_amber_rounded, Colors.orange),
                _buildSummaryTile("Diet Consistency", "Good", Icons.auto_graph_rounded, AppColors.primaryGreen),
                
                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
    );
  }

  // Tính số sản phẩm độc hại (Tổng - An toàn)
  int _calculateCaution(List<Map<String, dynamic>> data) {
    int total = data.fold(0, (sum, item) => sum + (item['total'] as int));
    int safe = data.fold(0, (sum, item) => sum + (item['safe'] as int));
    return total - safe;
  }

  FlTitlesData _buildTitles() {
    return FlTitlesData(
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(days[value.toInt() % 7], style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryTile(String label, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w700))),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
    );
  }
}