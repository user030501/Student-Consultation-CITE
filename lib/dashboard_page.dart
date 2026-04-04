import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class DashboardPage extends StatelessWidget {
  final void Function(int)? onTabChange;
  const DashboardPage({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final role = state.userRole;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome, ${state.displayName}!',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('Role: ${state.displayRole}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            Expanded(child: _buildCards(context, state, role)),
          ],
        ),
      ),
    );
  }

  Widget _buildCards(BuildContext context, AppState state, String role) {
    if (role == 'Student') return _studentCards(context, state);
    if (role == 'Adviser') return _adviserCards(context, state);
    return _adminCards(context, state);
  }

  Widget _studentCards(BuildContext context, AppState state) {
    final myConsults = state.myConsultations;
    final pending   = myConsults.where((c) => c.status == 'Pending').length;
    final approved  = myConsults.where((c) => c.status == 'Approved').length;
    final completed = myConsults.where((c) => c.status == 'Completed').length;

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1,
      children: [
        _DashCard(
          icon: Icons.assignment,
          title: 'Pending Requests',
          subtitle: '$pending pending',
          color: pending > 0 ? Colors.orange : null,
          onTap: () => onTabChange?.call(1),
        ),
        _DashCard(
          icon: Icons.event_available,
          title: 'Approved',
          subtitle: '$approved appointments',
          color: Colors.blue,
          onTap: () => onTabChange?.call(1),
        ),
        _DashCard(
          icon: Icons.check_circle,
          title: 'Completed',
          subtitle: '$completed consultations',
          color: Colors.green,
          onTap: () => onTabChange?.call(1),
        ),
        _DashCard(
          icon: Icons.add_circle,
          title: 'New Request',
          subtitle: 'Request a consultation',
          color: const Color(0xFFE040FB),
          onTap: () => onTabChange?.call(1),
        ),
      ],
    );
  }

  Widget _adviserCards(BuildContext context, AppState state) {
    final pending   = state.pendingForAdviser.length;
    final approved  = state.approvedForAdviser.length;
    final completed = state.completedConsultations
        .where((c) => c.formData.advisorName == state.displayName)
        .length;
    final reschedule = state.rescheduleRequestsForAdviser.length;

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1,
      children: [
        _DashCard(
          icon: Icons.schedule,
          title: "Approved",
          subtitle: '$approved appointments',
          color: Colors.blue,
          onTap: () => onTabChange?.call(2),
        ),
        _DashCard(
          icon: Icons.assignment_late,
          title: 'Pending Requests',
          subtitle: '$pending pending',
          color: pending > 0 ? Colors.orange : null,
          onTap: () => onTabChange?.call(1),
        ),
        _DashCard(
          icon: Icons.check_circle,
          title: 'Completed',
          subtitle: '$completed consultations',
          color: Colors.green,
          onTap: () => onTabChange?.call(3),
        ),
        _DashCard(
          icon: Icons.edit_calendar,
          title: 'Reschedule Requests',
          subtitle: '$reschedule requests',
          color: reschedule > 0 ? const Color(0xFFE040FB) : null,
          onTap: () => onTabChange?.call(1),
        ),
      ],
    );
  }

  Widget _adminCards(BuildContext context, AppState state) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1,
      children: [
        _DashCard(icon: Icons.pending_actions, title: 'Pending', subtitle: '${state.totalPending}', color: Colors.orange, onTap: () => onTabChange?.call(1)),
        _DashCard(icon: Icons.event_available, title: 'Approved', subtitle: '${state.totalApproved}', color: Colors.blue, onTap: () => onTabChange?.call(2)),
        _DashCard(icon: Icons.check_circle, title: 'Completed', subtitle: '${state.totalCompleted}', color: Colors.green, onTap: () => onTabChange?.call(3)),
        _DashCard(icon: Icons.cancel, title: 'Rejected', subtitle: '${state.totalRejected}', color: Colors.red, onTap: () => onTabChange?.call(1)),
        _DashCard(
          icon: Icons.people,
          title: 'Total Requests',
          subtitle: '${state.allConsultations.length}',
          onTap: () => onTabChange?.call(1),
        ),
        _DashCard(
          icon: Icons.bar_chart,
          title: 'See Reports',
          subtitle: 'Go to Reports tab',
          color: const Color(0xFF7C4DFF),
          onTap: () => onTabChange?.call(4),
        ),
      ],
    );
  }
}

class _DashCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? color;
  final VoidCallback? onTap;

  const _DashCard({required this.icon, required this.title, required this.subtitle, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: c),
              const SizedBox(height: 10),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              if (onTap != null) ...[
                const SizedBox(height: 6),
                Icon(Icons.arrow_forward_ios, size: 10, color: c.withOpacity(0.6)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}