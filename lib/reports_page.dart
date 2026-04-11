import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'app_state.dart';


class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});


  @override
  State<ReportsPage> createState() => _ReportsPageState();
}


class _ReportsPageState extends State<ReportsPage> {


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
       
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: _ReportsOverview(isMobile: isMobile),
            ),
          ),
        );
      },
    );
  }


}




class _ReportsOverview extends StatelessWidget {
  final bool isMobile;
  const _ReportsOverview({required this.isMobile});


  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final range = state.reportRange;
    final stats = state.getFilteredWeeklyStats();
    final topAdvisers = state.getTopAdvisers();
    final approvalDistribution = state.getApprovalTimeDistribution();


    final rangeLabel = '${range.start.month}/${range.start.day} - ${range.end.month}/${range.end.day}';


    return ListView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      children: [
        // Header
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupMenuButton<String>(
                  offset: const Offset(0, 40),
                  color: const Color(0xFF1A1A2E),
                  onSelected: (value) async {
                    final now = DateTime.now();
                    switch (value) {
                      case '7d':
                        state.setReportRange(DateTimeRange(
                          start: now.subtract(const Duration(days: 6)),
                          end: now,
                        ));
                      case '30d':
                        state.setReportRange(DateTimeRange(
                          start: now.subtract(const Duration(days: 29)),
                          end: now,
                        ));
                      case 'month':
                        state.setReportRange(DateTimeRange(
                          start: DateTime(now.year, now.month, 1),
                          end: now,
                        ));
                      case 'custom':
                        final newRange = await showDialog<DateTimeRange>(
                          context: context,
                          builder: (context) => Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  dialogTheme: DialogThemeData(
                                    backgroundColor: const Color(0xFF1A1A2E),
                                  ),
                                ),
                                child: DateRangePickerDialog(
                                  initialDateRange: state.reportRange,
                                  firstDate: DateTime(2025),
                                  lastDate: now,
                                ),
                              ),
                            ),
                          ),
                        );
                        if (newRange != null) {
                          state.setReportRange(newRange);
                        }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: '7d', child: Text('Last 7 Days', style: TextStyle(color: Colors.white70))),
                    const PopupMenuItem(value: '30d', child: Text('Last 30 Days', style: TextStyle(color: Colors.white70))),
                    const PopupMenuItem(value: 'month', child: Text('This Month', style: TextStyle(color: Colors.white70))),
                    const PopupMenuDivider(),
                    const PopupMenuItem(value: 'custom', child: Text('Custom Range...', style: TextStyle(color: Colors.white70))),
                  ],
                  child: AbsorbPointer(
                    child: _HeaderButton(
                      icon: Icons.calendar_today_outlined,
                      label: isMobile ? '7d' : rangeLabel,
                      onPressed: () {},
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _HeaderButton(
                  icon: Icons.download_outlined,
                  label: isMobile ? '' : 'Download',
                  onPressed: () {
                    state.exportToCSV();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reports downloaded successfully!')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),


        // Stat Cards
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            _StatTile(
              label: 'Total Consultations',
              value: '${state.allConsultations.length}',
              trend: '12.8%',
              isPositive: true,
            ),
            _StatTile(
              label: 'Pending Approval',
              value: '${state.totalPending}',
              trend: '9.2%',
              isPositive: false,
            ),
            _StatTile(
              label: 'Avg Completion',
              value: '3d',
              trend: '0.7%',
              isPositive: true,
            ),
            _StatTile(
              label: 'Outcome Rate',
              value: state.allConsultations.isEmpty ? '0%' : '${((state.totalCompleted / state.allConsultations.length) * 100).toStringAsFixed(0)}%',
              trend: '0.8%',
              isPositive: true,
            ),
            _StatTile(
              label: 'Active Advisers',
              value: '${state.adviserNames.length}',
              trend: '0.8%',
              isPositive: true,
            ),
          ],
        ),
        const SizedBox(height: 32),


        // Weekly Activity
        _DashboardSection(
          title: 'Consultations Activity',
          child: SizedBox(
            height: 300,
            child: _WeeklyBarChart(
              served: (stats['served'] as List).cast<int>(),
              missed: (stats['missed'] as List).cast<int>(),
            ),
          ),
        ),
        const SizedBox(height: 32),


        // Bottom Sections
        if (isMobile) ...[
          _DashboardSection(
            title: 'Top Performance Advisers',
            child: _AdviserPerformanceTable(advisers: topAdvisers),
          ),
          const SizedBox(height: 24),
          _DashboardSection(
            title: 'Approval Duration',
            child: _ApprovalTimeChart(distribution: approvalDistribution),
          ),
          const SizedBox(height: 24),
          _DashboardSection(
            title: 'Outcome Distribution',
            child: _OutcomeDonutChart(
              completed: state.totalCompleted,
              rejected: state.totalRejected,
            ),
          ),
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: _DashboardSection(
                  title: 'Top Performance Advisers',
                  child: _AdviserPerformanceTable(advisers: topAdvisers),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 3,
                child: _DashboardSection(
                  title: 'Approval Duration',
                  child: _ApprovalTimeChart(distribution: approvalDistribution),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 3,
                child: _DashboardSection(
                  title: 'Outcome Distribution',
                  child: _OutcomeDonutChart(
                    completed: state.totalCompleted,
                    rejected: state.totalRejected,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}


class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final bool isPositive;


  const _StatTile({
    required this.label,
    required this.value,
    required this.trend,
    required this.isPositive,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: isPositive ? Colors.greenAccent : Colors.redAccent,
                  ),
                  Text(
                    trend,
                    style: TextStyle(
                      fontSize: 12,
                      color: isPositive ? Colors.greenAccent : Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _DashboardSection extends StatelessWidget {
  final String title;
  final Widget child;


  const _DashboardSection({required this.title, required this.child});


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}


class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;


  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.white70),
            if (label.isNotEmpty) const SizedBox(width: 8),
            if (label.isNotEmpty)
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }
}


class _WeeklyBarChart extends StatelessWidget {
  final List<int> served;
  final List<int> missed;


  const _WeeklyBarChart({required this.served, required this.missed});


  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final range = state.reportRange;


    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY(),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final date = range.start.add(Duration(days: val.toInt()));
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${date.month}/${date.day}',
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (val, meta) => Text(
                '${val.toInt()}',
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(served.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: served[i].toDouble(),
                color: const Color(0xFF66BB6A),
                width: 14,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: missed[i].toDouble(),
                color: const Color(0xFFFFA726),
                width: 14,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }),
      ),
    );
  }


  double _getMaxY() {
    int max = 10;
    for (var i in served) {
      if (i > max) max = (i * 1.2).toInt();
    }
    for (var i in missed) {
      if (i > max) max = (i * 1.2).toInt();
    }
    return max.toDouble();
  }
}


class _AdviserPerformanceTable extends StatelessWidget {
  final List<Map<String, dynamic>> advisers;


  const _AdviserPerformanceTable({required this.advisers});


  @override
  Widget build(BuildContext context) {
    if (advisers.isEmpty) {
      return const Center(
        child: Text('No data yet', style: TextStyle(color: Colors.white24)),
      );
    }


    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text('Name', style: TextStyle(color: Colors.white38, fontSize: 12)),
              ),
              Expanded(
                flex: 2,
                child: Text('Total', style: TextStyle(color: Colors.white38, fontSize: 12), textAlign: TextAlign.center),
              ),
              Expanded(
                flex: 2,
                child: Text('Score', style: TextStyle(color: Colors.white38, fontSize: 12), textAlign: TextAlign.right),
              ),
            ],
          ),
        ),
        ...advisers.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                      child: Text(
                        (a['name'] as String).substring(0, 1),
                        style: const TextStyle(color: Color(0xFF7C4DFF), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        a['name'],
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${a['count']}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${(a['rating'] as double).toStringAsFixed(1)}%',
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}


class _ApprovalTimeChart extends StatelessWidget {
  final Map<String, int> distribution;


  const _ApprovalTimeChart({required this.distribution});


  @override
  Widget build(BuildContext context) {
    final keys = ['0-1h', '1-2h', '2-4h', '4-8h', '>8h'];
    final count = distribution.values.fold(0, (prev, e) => prev + e);


    return Column(
      children: keys.map((k) {
        final val = distribution[k] ?? 0;
        final ratio = count == 0 ? 0.0 : val / count;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(k, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  Text('${(ratio * 100).toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 12,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}


class _OutcomeDonutChart extends StatelessWidget {
  final int completed;
  final int rejected;


  const _OutcomeDonutChart({required this.completed, required this.rejected});


  @override
  Widget build(BuildContext context) {
    final total = completed + rejected;
    final compRatio = total == 0 ? 0.5 : completed / total;
    final rejRatio = total == 0 ? 0.5 : rejected / total;


    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 50,
              sections: [
                PieChartSectionData(
                  color: const Color(0xFF66BB6A),
                  value: compRatio,
                  title: '',
                  radius: 20,
                ),
                PieChartSectionData(
                  color: const Color(0xFFFF5252),
                  value: rejRatio,
                  title: '',
                  radius: 20,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                total == 0 ? '0%' : '${(compRatio * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Completed',
                style: TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}