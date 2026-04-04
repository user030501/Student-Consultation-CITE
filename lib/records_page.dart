import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class RecordsPage extends StatelessWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    // Adviser sees their own completed; Admin sees all completed
    final records = state.userRole == 'Admin'
        ? state.completedConsultations
        : state.completedConsultations
        .where((c) => c.formData.advisorName == state.displayName)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Consultation Records')),
      body: records.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.white24),
            SizedBox(height: 16),
            Text('No completed consultations yet.',
                style: TextStyle(color: Colors.white54)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: records.length,
        itemBuilder: (ctx, i) {
          final c = records[i];
          final d = c.formData.consultationDate;
          final completed = c.completedAt;
          return Card(
            child: ExpansionTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(c.formData.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  'Adviser: ${c.formData.advisorName}  •  '
                      '${d != null ? "${d.month}/${d.day}/${d.year}" : "-"}'),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      _detail('Student ID', c.formData.studentId),
                      _detail('Course', c.formData.courseProgram),
                      _detail('Year Level', c.formData.yearLevel),
                      _detail('Mode', c.formData.venue),
                      _detail('Purpose', c.formData.purposeCategories.join(', ')),
                      _detail('Concerns', c.formData.detailedConcerns),
                      _detail('Issues Discussed', c.formData.issuesDiscussed),
                      _detail('Action Taken', c.formData.actionTaken),
                      _detail('Recommendations', c.formData.recommendations),
                      if (completed != null)
                        _detail('Completed On',
                            '${completed.month}/${completed.day}/${completed.year}'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detail(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text('$label:',
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}