import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class AdviserAppointmentPage extends StatelessWidget {
  const AdviserAppointmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pending = state.pendingForAdviser;
    final reschedules = state.rescheduleRequestsForAdviser;
    final pendingDean = state.allConsultations
        .where((c) =>
    c.formData.advisorName == state.displayName &&
        c.status == 'Pending Dean Approval')
        .toList();

    final isEmpty = pending.isEmpty && reschedules.isEmpty && pendingDean.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Student Requests')),
      body: isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in, size: 64, color: Colors.white24),
            SizedBox(height: 16),
            Text('No pending requests.', style: TextStyle(color: Colors.white54)),
          ],
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Reschedule requests section
          if (reschedules.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Reschedule Requests',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
            ),
            ...reschedules.map((c) => _rescheduleCard(context, state, c)),
            const SizedBox(height: 8),
          ],
          // Pending consultation requests
          if (pending.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('New Consultation Requests',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
            ),
            ...pending.map((c) => _pendingCard(context, state, c)),
          ],
          // Waiting for Dean signature
          if (pendingDean.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Awaiting Dean Signature',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
            ),
            ...pendingDean.map((c) => _pendingDeanCard(context, c)),
          ],
        ],
      ),
    );
  }

  Widget _rescheduleCard(BuildContext context, AppState state, ConsultationEntry c) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.orange, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_calendar, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(c.formData.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Reschedule', style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Requested new schedule:',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            if (c.rescheduleDate != null)
              _infoRow(Icons.calendar_today,
                  '${c.rescheduleDate!.month}/${c.rescheduleDate!.day}/${c.rescheduleDate!.year}'),
            if (c.rescheduleTime != null)
              _infoRow(Icons.access_time, c.rescheduleTime!.format(context)),
            if (c.rescheduleVenue != null && c.rescheduleVenue!.isNotEmpty)
              _infoRow(Icons.location_on, c.rescheduleVenue!),
            if (c.rescheduleNote != null && c.rescheduleNote!.isNotEmpty)
              _infoRow(Icons.note, c.rescheduleNote!),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showActionDialog(context, state, c.id, approve: false),
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text('Reject', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await state.approveReschedule(c.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reschedule approved!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pendingCard(BuildContext context, AppState state, ConsultationEntry c) {
    final d = c.formData.consultationDate;
    final t = c.formData.consultationTime;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Color(0xFF7C4DFF)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(c.formData.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Pending',
                      style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _infoRow(Icons.calendar_today,
                d != null ? '${d.month}/${d.day}/${d.year}' : 'Date not set'),
            _infoRow(Icons.access_time,
                t != null ? t.format(context) : 'Time not set'),
            _infoRow(Icons.location_on, c.formData.venue),
            _infoRow(Icons.school, '${c.formData.courseProgram} — ${c.formData.yearLevel}'),
            if (c.formData.purposeCategories.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: c.formData.purposeCategories
                    .map((p) => Chip(
                  label: Text(p, style: const TextStyle(fontSize: 11)),
                  backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 6),
            if (c.formData.detailedConcerns.isNotEmpty)
              Text('Concern: ${c.formData.detailedConcerns}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showActionDialog(context, state, c.id, approve: false),
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text('Reject', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showActionDialog(context, state, c.id, approve: true),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pendingDeanCard(BuildContext context, ConsultationEntry c) {
    final d = c.formData.consultationDate;
    final t = c.formData.consultationTime;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.teal.withValues(alpha: 0.5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.hourglass_top, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(c.formData.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Pending Dean Approval',
                      style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _infoRow(Icons.calendar_today,
                d != null ? '${d.month}/${d.day}/${d.year}' : 'Date not set'),
            _infoRow(Icons.access_time,
                t != null ? t.format(context) : 'Time not set'),
            _infoRow(Icons.location_on, c.formData.venue),
            _infoRow(Icons.school, '${c.formData.courseProgram} — ${c.formData.yearLevel}'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.08),
                border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
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
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Icon(icon, size: 14, color: Colors.white38),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    ),
  );

  void _showActionDialog(BuildContext context, AppState state, String id, {required bool approve}) {
    final noteController = TextEditingController();
    final signatureController = TextEditingController();
    final recommendationController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(approve ? 'Approve Request' : 'Reject Request'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (approve) ...[
                const Text('Adviser Signature *',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: signatureController,
                  decoration: InputDecoration(
                    hintText: 'Type your full name as signature',
                    prefixIcon: const Icon(Icons.create),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Note for student (optional):',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'e.g. See you on the scheduled date',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ] else ...[
                const Text('Reason for rejection:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'e.g. Please reschedule',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Recommendation:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: recommendationController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'e.g. Please visit the guidance office first',
                    prefixIcon: const Icon(Icons.lightbulb_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: approve ? Colors.green : Colors.red),
            onPressed: () {
              if (approve && signatureController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your signature to approve.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              if (approve) {
                state.approveConsultation(id,
                    note: noteController.text.trim(),
                    adviserSignature: signatureController.text.trim());
              } else {
                state.rejectConsultation(id,
                    note: noteController.text.trim(),
                    recommendation: recommendationController.text.trim());
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(approve ? 'Request approved!' : 'Request rejected.'),
                  backgroundColor: approve ? Colors.green : Colors.red,
                ),
              );
            },
            child: Text(approve ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }
}