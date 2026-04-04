import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class StudentAppointmentPage extends StatelessWidget {
  const StudentAppointmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final appointments = state.myApprovedAppointments;

    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: appointments.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.white24),
            SizedBox(height: 16),
            Text('No approved appointments yet.',
                style: TextStyle(color: Colors.white54)),
            SizedBox(height: 8),
            Text('Submit a consultation request first.',
                style: TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: appointments.length,
        itemBuilder: (ctx, i) {
          final c = appointments[i];
          final d = c.formData.consultationDate;
          final t = c.formData.consultationTime;
          final isRescheduleRequested = c.status == 'Reschedule Requested';
          final isPending = c.status == 'Pending';
          final isRejected = c.status == 'Rejected';
          final isCompleted = c.status == 'Completed';

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Appointment',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      _statusChip(c.status),
                    ],
                  ),
                  const Divider(height: 16),
                  _row(Icons.person, 'Adviser: ${c.formData.advisorName}'),
                  _row(Icons.calendar_today,
                      d != null ? '${d.month}/${d.day}/${d.year}' : 'Date not set'),
                  _row(Icons.access_time,
                      t != null ? t.format(ctx) : 'Time not set'),
                  _row(Icons.location_on, c.formData.venue),
                  if (c.formData.purposeCategories.isNotEmpty)
                    _row(Icons.assignment,
                        c.formData.purposeCategories.join(', ')),
                  if (c.adviserNote != null && c.adviserNote!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.message, size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Note: ${c.adviserNote}',
                                style: const TextStyle(fontSize: 12, color: Colors.white70)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Show reschedule request info if pending
                  if (isRescheduleRequested && c.rescheduleDate != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Reschedule Request Sent:',
                              style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
                          Text(
                            'New date: ${c.rescheduleDate!.month}/${c.rescheduleDate!.day}/${c.rescheduleDate!.year}  ${c.rescheduleTime?.format(ctx) ?? ""}',
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                          if (c.rescheduleNote != null && c.rescheduleNote!.isNotEmpty)
                            Text('Note: ${c.rescheduleNote}',
                                style: const TextStyle(fontSize: 12, color: Colors.white54)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Reschedule button — only show if Approved
                  if (c.status == 'Approved')
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showRescheduleDialog(ctx, state, c.id),
                        icon: const Icon(Icons.edit_calendar, color: Color(0xFFE040FB)),
                        label: const Text('Request Reschedule',
                            style: TextStyle(color: Color(0xFFE040FB))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE040FB)),
                        ),
                      ),
                    ),
                  if (isRescheduleRequested)
                    const Center(
                      child: Text('Waiting for adviser approval...',
                          style: TextStyle(color: Colors.orange, fontSize: 12)),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case 'Approved': color = Colors.blue; break;
      case 'Reschedule Requested': color = Colors.orange; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }

  void _showRescheduleDialog(BuildContext context, AppState state, String id) {
    DateTime? newDate;
    TimeOfDay? newTime;
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Request Reschedule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pick your preferred new schedule:',
                    style: TextStyle(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 12),
                // Date picker
                GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) setStateDialog(() => newDate = d);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.white54),
                        const SizedBox(width: 8),
                        Text(
                          newDate != null
                              ? '${newDate!.month}/${newDate!.day}/${newDate!.year}'
                              : 'Select new date',
                          style: TextStyle(
                              color: newDate != null ? Colors.white : Colors.white38),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Time picker
                GestureDetector(
                  onTap: () async {
                    final t = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay.now(),
                    );
                    if (t != null) setStateDialog(() => newTime = t);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.white54),
                        const SizedBox(width: 8),
                        Text(
                          newTime != null ? newTime!.format(ctx) : 'Select new time',
                          style: TextStyle(
                              color: newTime != null ? Colors.white : Colors.white38),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    hintText: 'Reason for rescheduling (optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (newDate == null || newTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select date and time.')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                await state.requestReschedule(
                  id,
                  newDate: newDate!,
                  newTime: newTime!,
                  note: noteController.text.trim(),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reschedule request sent to adviser!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('Send Request'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF7C4DFF)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    ),
  );
}