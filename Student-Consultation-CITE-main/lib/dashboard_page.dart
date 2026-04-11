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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 600;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 24 : 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome header
                    _buildWelcomeHeader(state),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _buildCards(context, state, role, constraints),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader(AppState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6200EA), Color(0xFFD500F9)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6200EA).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.waving_hand, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Welcome back, ${state.displayName}!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Text(
              'Role: ${state.displayRole}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCards(
    BuildContext context,
    AppState state,
    String role,
    BoxConstraints constraints,
  ) {
    int crossAxisCount = 2;
    double aspectRatio = 1.1;

    if (constraints.maxWidth > 1000) {
      crossAxisCount = 4;
      aspectRatio = 1.3;
    } else if (constraints.maxWidth > 700) {
      crossAxisCount = 3;
      aspectRatio = 1.2;
    } else if (constraints.maxWidth < 400) {
      crossAxisCount = 1;
      aspectRatio = 2.5;
    }

    if (role == 'Student') {
      return _studentCards(context, state, crossAxisCount, aspectRatio);
    }
    if (role == 'Adviser') {
      return _adviserCards(context, state, crossAxisCount, aspectRatio);
    }
    return _adminCards(context, state, crossAxisCount, aspectRatio);
  }

  Widget _studentCards(
    BuildContext context,
    AppState state,
    int crossAxisCount,
    double aspectRatio,
  ) {
    final myConsults = state.myConsultations;
    final pending = myConsults.where((c) => c.status == 'Pending').length;
    final approved = myConsults.where((c) => c.status == 'Approved').length;
    final completed = myConsults.where((c) => c.status == 'Completed').length;

    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: aspectRatio,
      ),
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

  Widget _adviserCards(
    BuildContext context,
    AppState state,
    int crossAxisCount,
    double aspectRatio,
  ) {
    final pending = state.pendingForAdviser.length;
    final approved = state.approvedForAdviser.length;
    final completed =
        state.completedConsultations
            .where((c) => c.formData.advisorName == state.displayName)
            .length;
    final reschedule = state.rescheduleRequestsForAdviser.length;

    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: aspectRatio,
      ),
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

  Widget _adminCards(
    BuildContext context,
    AppState state,
    int crossAxisCount,
    double aspectRatio,
  ) {
    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: aspectRatio,
      ),
      children: [
        _DashCard(
          icon: Icons.pending_actions,
          title: 'Pending',
          subtitle: '${state.totalPending}',
          color: Colors.orange,
          onTap: () => onTabChange?.call(1),
        ),
        _DashCard(
          icon: Icons.event_available,
          title: 'Approved',
          subtitle: '${state.totalApproved}',
          color: Colors.blue,
          onTap: () => onTabChange?.call(2),
        ),
        _DashCard(
          icon: Icons.check_circle,
          title: 'Completed',
          subtitle: '${state.totalCompleted}',
          color: Colors.green,
          onTap: () => onTabChange?.call(3),
        ),
        _DashCard(
          icon: Icons.cancel,
          title: 'Rejected',
          subtitle: '${state.totalRejected}',
          color: Colors.red,
          onTap: () => onTabChange?.call(1),
        ),
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

  const _DashCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).colorScheme.primary;
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: themeColor),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(height: 12),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: themeColor.withValues(alpha: 0.8),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}