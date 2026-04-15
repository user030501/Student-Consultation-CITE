import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'consultation_page.dart';
import 'adviser_appointment_page.dart';
import 'records_page.dart';
import 'reports_page.dart';
import 'dashboard_page.dart';
import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(create: (_) => AppState(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Consultation System(CITE)',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFF7C4DFF),
          onPrimary: Colors.white,
          secondary: Color(0xFFE040FB),
          onSecondary: Colors.white,
          error: Colors.redAccent,
          onError: Colors.white,
          surface: Color(0xFF2A103A),
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF2A1740),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE040FB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 20,
          ),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
      ),
      builder: (context, child) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF12002B), Color(0xFF311B92), Color(0xFF5E35B1)],
          ),
        ),
        child: child,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginPage(),
        '/home': (_) => const MyHomePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  List<_NavItem> _navItems(String role) {
    final items = [_NavItem(Icons.dashboard, 'Dashboard')];
    if (role == 'Student') {
      items.addAll([_NavItem(Icons.assignment, 'Consultation')]);
    } else if (role == 'Adviser') {
      items.addAll([
        _NavItem(Icons.assignment, 'Requests'),
        _NavItem(Icons.calendar_today, 'Schedule'),
        _NavItem(Icons.folder, 'Records'),
      ]);
    } else if (role == 'Admin' || role == 'Dean') {
      // Admin
      items.addAll([
        _NavItem(Icons.assignment, 'Consultations'),
        _NavItem(Icons.folder, 'Records'),
        _NavItem(Icons.bar_chart, 'Reports'),
      ]);
    }
    return items;
  }

  Widget _pageForIndex(int index, String role) {
    if (role == 'Student') {
      switch (index) {
        case 0:
          return DashboardPage(
            onTabChange: (i) => setState(() => _selectedIndex = i),
          );
        case 1:
          return const StudentConsultationPage();
      }
    } else if (role == 'Adviser') {
      switch (index) {
        case 0:
          return DashboardPage(
            onTabChange: (i) => setState(() => _selectedIndex = i),
          );
        case 1:
          return const AdviserAppointmentPage();
        case 2:
          return const AdviserSchedulePage();
        case 3:
          return const RecordsPage();
      }
    } else if (role == 'Admin' || role == 'Dean') {
      switch (index) {
        case 0:
          return DashboardPage(
            onTabChange: (i) => setState(() => _selectedIndex = i),
          );
        case 1:
          return const AdminConsultationsPage();
        case 2:
          return const RecordsPage();
        case 3:
          return const ReportsPage();
      }
    }
    return DashboardPage(
      onTabChange: (i) => setState(() => _selectedIndex = i),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final role = appState.userRole;
    final navItems = _navItems(role);

    // Clamp index if role changes
    if (_selectedIndex >= navItems.length) {
      _selectedIndex = 0;
    }

    final page = _pageForIndex(_selectedIndex, role);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        if (isNarrow) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Student Consultation System'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                  onPressed: () {
                    appState.logout();
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
              ],
            ),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: KeyedSubtree(key: ValueKey(_selectedIndex), child: page),
            ),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: const Color(0xFF1A0030),
              selectedItemColor: const Color(0xFFE040FB),
              unselectedItemColor: Colors.white54,
              currentIndex: _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i),
              type: BottomNavigationBarType.fixed,
              items: navItems
                  .map(
                    (n) => BottomNavigationBarItem(
                      icon: Icon(n.icon),
                      label: n.label,
                    ),
                  )
                  .toList(),
            ),
          );
        }

        // Wide layout
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: Container(
                  width: 200,
                  color: const Color(0xFF1A0030),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appState.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              appState.displayRole,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.white24),
                      Expanded(
                        child: ListView.builder(
                          itemCount: navItems.length,
                          itemBuilder: (ctx, i) => ListTile(
                            leading: Icon(
                              navItems[i].icon,
                              color: _selectedIndex == i
                                  ? const Color(0xFFE040FB)
                                  : Colors.white54,
                            ),
                            title: Text(
                              navItems[i].label,
                              style: TextStyle(
                                color: _selectedIndex == i
                                    ? const Color(0xFFE040FB)
                                    : Colors.white70,
                              ),
                            ),
                            selected: _selectedIndex == i,
                            onTap: () => setState(() => _selectedIndex = i),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.white54,
                        ),
                        title: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.white70),
                        ),
                        onTap: () {
                          appState.logout();
                          Navigator.pushReplacementNamed(context, '/');
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: KeyedSubtree(
                    key: ValueKey(_selectedIndex),
                    child: page,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

// ── Placeholder pages for Admin ───────────────────────────────────────────────
class AdminConsultationsPage extends StatelessWidget {
  const AdminConsultationsPage({super.key});

  void _showDeanSignDialog(
    BuildContext context,
    AppState state,
    String id,
    String studentName,
  ) {
    final signatureController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign as Dean'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Student: $studentName',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 14),
              const Text(
                'Dean Signature *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: signatureController,
                decoration: InputDecoration(
                  hintText: 'Type your full name as signature',
                  prefixIcon: const Icon(Icons.create),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
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
                        'Signing will mark this consultation as Approved. '
                        'The adviser will then schedule the actual meeting.',
                        style: TextStyle(fontSize: 11, color: Colors.white60),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.draw, size: 16),
            label: const Text('Sign & Approve'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              if (signatureController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your signature.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              state.deanSign(
                id,
                deanSignature: signatureController.text.trim(),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Consultation signed and approved!'),
                  backgroundColor: Colors.teal,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final consultations = state.allConsultations;

    return Scaffold(
      appBar: AppBar(title: const Text('All Consultations')),
      body: consultations.isEmpty
          ? const Center(child: Text('No consultations yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
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
                        ? BorderSide(
                            color: Colors.teal.withValues(alpha: 0.5),
                            width: 1,
                          )
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.formData.fullName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Adviser: ${c.formData.advisorName}',
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${d != null ? "${d.month}/${d.day}/${d.year}" : "-"}  ${t?.format(context) ?? "-"}  •  ${c.formData.venue}',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _StatusChip(c.status),
                          ],
                        ),
                        if (isPendingDean) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.draw, size: 16),
                              label: const Text('Sign as Dean'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => _showDeanSignDialog(
                                context,
                                state,
                                c.id,
                                c.formData.fullName,
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
}

class AdviserSchedulePage extends StatelessWidget {
  const AdviserSchedulePage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final approved = state.approvedForAdviser;
    return Scaffold(
      appBar: AppBar(title: const Text("My Schedule")),
      body: approved.isEmpty
          ? const Center(child: Text('No approved appointments yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: approved.length,
              itemBuilder: (ctx, i) {
                final c = approved[i];
                final d = c.formData.consultationDate;
                final t = c.formData.consultationTime;
                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF7C4DFF),
                    ),
                    title: Text(c.formData.fullName),
                    subtitle: Text(
                      '${d != null ? "${d.month}/${d.day}/${d.year}" : "-"}  ${t?.format(context) ?? "-"}\n${c.formData.venue}',
                    ),
                    isThreeLine: true,
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        state.completeConsultation(c.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Marked ${c.formData.fullName} as completed',
                            ),
                          ),
                        );
                      },
                      child: const Text('Complete'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip(this.status);

  Color get _color {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Pending Dean Approval':
        return Colors.teal;
      case 'Approved':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Reschedule Requested':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: _color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status,
      style: const TextStyle(color: Colors.white, fontSize: 12),
    ),
  );
}
