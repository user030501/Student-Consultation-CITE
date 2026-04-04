import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'consultation_form_page.dart';

class StudentConsultationPage extends StatelessWidget {
  const StudentConsultationPage({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':               return Colors.orange;
      case 'Pending Dean Approval': return Colors.teal;
      case 'Approved':              return Colors.blue;
      case 'Completed':             return Colors.green;
      case 'Rejected':              return Colors.red;
      case 'Reschedule Requested':  return const Color(0xFFE040FB);
      default:                      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final consultations = state.myConsultations;

    return Scaffold(
      appBar: AppBar(title: const Text('My Consultation Requests')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
        backgroundColor: const Color(0xFFE040FB),
      ),
      body: consultations.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            const Text('No consultation requests yet.',
                style: TextStyle(fontSize: 16, color: Colors.white54)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Request Consultation'),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.only(bottom: 90, top: 8, left: 8, right: 8),
        itemCount: consultations.length,
        itemBuilder: (ctx, i) {
          final c = consultations[i];
          final d = c.formData.consultationDate;
          final t = c.formData.consultationTime;
          final isPendingDean = c.status == 'Pending Dean Approval';

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isPendingDean
                  ? BorderSide(color: Colors.teal.withOpacity(0.5), width: 1)
                  : BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isPendingDean ? Icons.hourglass_top : Icons.person,
                            color: isPendingDean ? Colors.teal : const Color(0xFF7C4DFF),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text('Adviser: ${c.formData.advisorName}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      _StatusChip(c.status, _statusColor(c.status)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (d != null)
                    Text('Date: ${d.month}/${d.day}/${d.year}  ${t?.format(context) ?? ""}',
                        style: const TextStyle(color: Colors.white70)),
                  Text('Mode: ${c.formData.venue}',
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 6),
                  if (c.formData.purposeCategories.isNotEmpty)
                    Text('Purpose: ${c.formData.purposeCategories.join(", ")}'),
                  if (c.adviserNote != null && c.adviserNote!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Adviser note: ${c.adviserNote}',
                          style: const TextStyle(fontSize: 12, color: Colors.white60)),
                    ),
                  ],
                  if (c.status == 'Rejected' && c.adviserRecommendation != null && c.adviserRecommendation!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.08),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 14),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Recommendation: ${c.adviserRecommendation}',
                              style: const TextStyle(fontSize: 12, color: Colors.amber),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Reschedule request info
                  if (c.status == 'Reschedule Requested' && c.rescheduleDate != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.edit_calendar, size: 14, color: Colors.orange),
                          const SizedBox(width: 6),
                          Text(
                            'Reschedule sent: ${c.rescheduleDate!.month}/${c.rescheduleDate!.day}/${c.rescheduleDate!.year}  ${c.rescheduleTime?.format(context) ?? ""}',
                            style: const TextStyle(fontSize: 12, color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Pending Dean Approval info note
                  if (isPendingDean) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.08),
                        border: Border.all(color: Colors.teal.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.teal, size: 14),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Waiting for Dean to sign before the meeting can proceed.',
                              style: TextStyle(fontSize: 11, color: Colors.white60),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Reschedule button — only for Approved
                  if (c.status == 'Approved') ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showRescheduleDialog(context, state, c.id),
                        icon: const Icon(Icons.edit_calendar, color: Color(0xFFE040FB)),
                        label: const Text('Request Reschedule',
                            style: TextStyle(color: Color(0xFFE040FB))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE040FB)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context, AppState state, String id) {
    DateTime? newDate;
    TimeOfDay? newTime;
    String? newVenue;
    final noteController = TextEditingController();
    final venueOptions = ['In-person', 'Online', 'Phone', 'Email'];

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
                DropdownButtonFormField<String>(
                  value: newVenue,
                  decoration: InputDecoration(
                    labelText: 'Venue/Method',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  items: venueOptions
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) => setStateDialog(() => newVenue = v),
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
                  newVenue: newVenue,
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

  void _openForm(BuildContext context) async {
    final state = context.read<AppState>();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ConsultationFormPage()),
    );
    if (result != null) {
      state.submitConsultation(result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consultation request submitted!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
  );
}