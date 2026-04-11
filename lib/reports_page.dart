import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final total = state.allConsultations.length;
    final purposeBreakdown = state.purposeBreakdown;

    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Analytics')),
      body: total == 0
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.white24),
            SizedBox(height: 16),
            Text('No data yet. Submit some consultations first.',
                style: TextStyle(color: Colors.white54)),
          ],
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overview cards
          const Text('Overview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              _StatCard('Total', '$total', Colors.purple),
              _StatCard('Pending', '${state.totalPending}', Colors.orange),
              _StatCard('Approved', '${state.totalApproved}', Colors.blue),
              _StatCard('Completed', '${state.totalCompleted}', Colors.green),
              _StatCard('Rejected', '${state.totalRejected}', Colors.red),
              _StatCard(
                'Completion Rate',
                total > 0 ? '${((state.totalCompleted / total) * 100).toStringAsFixed(0)}%' : '0%',
                Colors.teal,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Status bar chart
          const Text('Status Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _Bar('Pending',  state.totalPending,  total, Colors.orange),
                  _Bar('Approved', state.totalApproved, total, Colors.blue),
                  _Bar('Completed',state.totalCompleted,total, Colors.green),
                  _Bar('Rejected', state.totalRejected, total, Colors.red),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Purpose breakdown
          if (purposeBreakdown.isNotEmpty) ...[
            const Text('Purpose Breakdown',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: purposeBreakdown.entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(e.key,
                                style: const TextStyle(fontSize: 12, color: Colors.white70)),
                          ),
                          Expanded(
                            flex: 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: e.value / total,
                                minHeight: 12,
                                backgroundColor: Colors.white12,
                                color: const Color(0xFF7C4DFF),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${e.value}',
                              style: const TextStyle(fontSize: 12, color: Colors.white54)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
      ],
    ),
  );
}

class _Bar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  const _Bar(this.label, this.count, this.total, this.color);

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13)),
              Text('$count', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: Colors.white12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}