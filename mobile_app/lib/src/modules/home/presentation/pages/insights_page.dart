import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../services/scan_history_service.dart';
import '../../../../core/theme/app_colors.dart';
import 'scan_detail_page.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  // Filter state
  String _filterMode = 'today';
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  List<QueryDocumentSnapshot> _allScans = [];
  List<QueryDocumentSnapshot> _filteredScans = [];
  bool _isLoading = true;

  // Cache weekly data to prevent chart rebuilds
  List<Map<String, dynamic>>? _weeklyDataCache;

  final List<_QuickFilter> _quickFilters = [
    _QuickFilter(id: 'today', label: 'Today', icon: Icons.today),
    _QuickFilter(id: '7days', label: '7 Days', icon: Icons.date_range),
    _QuickFilter(id: '30days', label: '30 Days', icon: Icons.calendar_month),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load weekly trend once
    _weeklyDataCache = await ScanHistoryService().getWeeklyTrend();

    // Listen to scans stream
    ScanHistoryService().getScans().listen((snapshot) {
      if (mounted) {
        setState(() {
          _allScans = snapshot.docs;
          _filteredScans = _filterScans(_allScans);
          _isLoading = false;
        });
      }
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _filterMode = filter;
      if (filter != 'custom') {
        _customStartDate = null;
        _customEndDate = null;
      }
      // Only filter the list - chart stays the same
      _filteredScans = _filterScans(_allScans);
    });
  }

  void _onCustomRangeSelected(DateTimeRange range) {
    setState(() {
      _customStartDate = range.start;
      _customEndDate = range.end;
      _filterMode = 'custom';
      _filteredScans = _filterScans(_allScans);
    });
  }

  void _clearCustomRange() {
    setState(() {
      _customStartDate = null;
      _customEndDate = null;
      _filterMode = 'today';
      _filteredScans = _filterScans(_allScans);
    });
  }

  List<QueryDocumentSnapshot> _filterScans(List<QueryDocumentSnapshot> scans) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return scans.where((scan) {
      final scanDate = (scan['createdAt'] as Timestamp?)?.toDate();
      if (scanDate == null) return false;

      switch (_filterMode) {
        case 'today':
          return scanDate.year == today.year &&
            scanDate.month == today.month &&
            scanDate.day == today.day;
        case '7days':
          final weekAgo = today.subtract(const Duration(days: 7));
          return scanDate.isAfter(weekAgo);
        case '30days':
          final monthAgo = today.subtract(const Duration(days: 30));
          return scanDate.isAfter(monthAgo);
        case 'custom':
          if (_customStartDate == null) return true;
          final start = DateTime(_customStartDate!.year, _customStartDate!.month, _customStartDate!.day);
          final end = _customEndDate != null
            ? DateTime(_customEndDate!.year, _customEndDate!.month, _customEndDate!.day)
            : start;
          return !scanDate.isBefore(start) && !scanDate.isAfter(end.add(const Duration(days: 1)));
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundLight,
      body: SafeArea(
        child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  expandedHeight: 60,
                  title: const Text(
                    "HEALTH INSIGHTS",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                  centerTitle: true,
                ),

                // Weekly Chart (static - doesn't rebuild on filter change)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          "Weekly Trend",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _WeeklyChart(cachedData: _weeklyDataCache),
                      ],
                    ),
                  ),
                ),

                // Date Filter Section (only this section triggers filter update)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Recent Scans",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${_filteredScans.length} items',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Filter Bar
                        _DateFilterBar(
                          quickFilters: _quickFilters,
                          selectedFilter: _filterMode,
                          onFilterChanged: _onFilterChanged,
                          onCalendarTap: () => _showStyledDateRangePicker(context),
                        ),

                        // Custom Range Display
                        if (_filterMode == 'custom' && _customStartDate != null) ...[
                          const SizedBox(height: 12),
                          _CustomRangeChip(
                            startDate: _customStartDate!,
                            endDate: _customEndDate ?? _customStartDate!,
                            onClear: _clearCustomRange,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Scan List (rebuilds only when filter changes)
                _buildScanList(),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
      ),
    );
  }

  Widget _buildScanList() {
    if (_filteredScans.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              children: [
                Icon(Icons.inbox_rounded, size: 48, color: AppColors.textSecondary),
                SizedBox(height: 16),
                Text(
                  "No scans found",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Start scanning products to see them here",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final scan = _filteredScans[index];
            final isSafe = scan['result'] == 'safe';
            DateTime date = (scan['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ScanListItem(
                scan: scan,
                isSafe: isSafe,
                date: date,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ScanDetailPage(scan: scan)),
                  );
                },
              ),
            );
          },
          childCount: _filteredScans.length,
        ),
      ),
    );
  }

  Future<void> _showStyledDateRangePicker(BuildContext context) async {
  final DateTimeRange? picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
    initialDateRange: _customStartDate != null
      ? DateTimeRange(
          start: _customStartDate!,
          end: _customEndDate ?? _customStartDate!,
        )
      : null,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          brightness: Brightness.light, // 🔥 ép sáng hoàn toàn

          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryGreen,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.textPrimary,
          ),

          dialogBackgroundColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          canvasColor: Colors.white, // 🔥 fix nền bị ám

          textTheme: Theme.of(context).textTheme.copyWith(
            headlineMedium: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            bodyLarge: const TextStyle(
              color: AppColors.textPrimary,
            ),
            bodyMedium: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),

          // 🔥 thêm cái này để UI “clear” hơn
          datePickerTheme: DatePickerThemeData(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent, // bỏ lớp phủ xám
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    _onCustomRangeSelected(picked);
  }
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
              child: Text(
                days[value.toInt() % 7],
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Separate widget for chart - uses cached data, doesn't rebuild on filter change
class _WeeklyChart extends StatelessWidget {
  final List<Map<String, dynamic>>? cachedData;

  const _WeeklyChart({super.key, this.cachedData});

  @override
  Widget build(BuildContext context) {
    final weeklyData = cachedData ?? [];

    if (weeklyData.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'No weekly data',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(10, 25, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
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
                    child: Text(
                      days[value.toInt() % 7],
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: weeklyData.asMap().entries.map((e) {
            return BarChartGroupData(x: e.key, barRods: [
              BarChartRodData(
                toY: e.value['total'].toDouble(),
                color: Colors.grey.shade300,
                width: 14,
                borderRadius: BorderRadius.circular(4),
              ),
              BarChartRodData(
                toY: e.value['safe'].toDouble(),
                color: AppColors.primaryGreen,
                width: 14,
                borderRadius: BorderRadius.circular(4),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

// Scan List Item - extracted for efficient rebuild
class _ScanListItem extends StatelessWidget {
  final QueryDocumentSnapshot scan;
  final bool isSafe;
  final DateTime date;
  final VoidCallback onTap;

  const _ScanListItem({
    required this.scan,
    required this.isSafe,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSafe
                  ? AppColors.primaryGreen.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSafe ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                color: isSafe ? AppColors.primaryGreen : Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan['productName'] ?? 'Unknown',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.hour}:${date.minute.toString().padLeft(2, '0')} • ${isSafe ? "Safe" : "Caution"}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackgroundLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickFilter {
  final String id;
  final String label;
  final IconData icon;

  const _QuickFilter({required this.id, required this.label, required this.icon});
}

class _DateFilterBar extends StatelessWidget {
  final List<_QuickFilter> quickFilters;
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final VoidCallback onCalendarTap;

  const _DateFilterBar({
    required this.quickFilters,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onCalendarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: quickFilters.map((filter) {
                final isSelected = selectedFilter == filter.id;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onFilterChanged(filter.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isSelected
                          ? const LinearGradient(
                              colors: [AppColors.primaryGreen, Color(0xFF22C55E)],
                            )
                          : null,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryGreen.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            filter.icon,
                            size: 16,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            filter.label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onCalendarTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selectedFilter == 'custom'
                  ? AppColors.primaryGreen
                  : AppColors.scaffoldBackgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_month,
                size: 20,
                color: selectedFilter == 'custom'
                  ? Colors.white
                  : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomRangeChip extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onClear;

  const _CustomRangeChip({
    required this.startDate,
    required this.endDate,
    required this.onClear,
  });

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final isSingleDay = startDate.year == endDate.year &&
      startDate.month == endDate.month &&
      startDate.day == endDate.day;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen.withOpacity(0.1),
            AppColors.primaryGreen.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.date_range, size: 16, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Text(
            isSingleDay
              ? _formatDate(startDate)
              : '${_formatDate(startDate)} – ${_formatDate(endDate)}',
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}