import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namer_app/app_state.dart';
import 'package:namer_app/services/api_service.dart';

class _FakeApiService extends ApiService {
  _FakeApiService() : super();

  Map<String, dynamic>? loginResult;
  String? registerResult;
  List<Map<String, dynamic>> consultations = [];
  List<Map<String, dynamic>> advisers = [];

  String? lastStatusId;
  String? lastStatusValue;
  String? lastAdviserNote;
  String? lastAdviserRecommendation;
  String? lastAdviserSignature;
  String? lastDeanSignature;
  String? lastApprovedRescheduleId;
  String? lastRescheduleId;
  DateTime? lastRescheduleDate;
  TimeOfDay? lastRescheduleTime;
  String? lastRescheduleVenue;
  String? lastRescheduleNote;
  String? lastSubmittedStudentId;

  @override
  Future<Map<String, dynamic>?> login(String username, String password) async =>
      loginResult;

  @override
  Future<String?> register({
    required String username,
    required String password,
    required String role,
    required String displayName,
    String? courseProgram,
    String? yearLevel,
    String? email,
    String? phone,
  }) async => registerResult;

  @override
  Future<List<Map<String, dynamic>>> fetchConsultations() async => consultations;

  @override
  Future<List<Map<String, dynamic>>> getAdvisers() async => advisers;

  @override
  Future<void> submitConsultation(data, String studentUserId) async {
    lastSubmittedStudentId = studentUserId;
  }

  @override
  Future<void> updateConsultationStatus(
    String id, {
    required String status,
    String? adviserNote,
    String? adviserRecommendation,
    String? adviserSignature,
    String? deanSignature,
  }) async {
    lastStatusId = id;
    lastStatusValue = status;
    lastAdviserNote = adviserNote;
    lastAdviserRecommendation = adviserRecommendation;
    lastAdviserSignature = adviserSignature;
    lastDeanSignature = deanSignature;
  }

  @override
  Future<void> requestReschedule(
    String id, {
    required DateTime newDate,
    required TimeOfDay newTime,
    String? newVenue,
    String? note,
  }) async {
    lastRescheduleId = id;
    lastRescheduleDate = newDate;
    lastRescheduleTime = newTime;
    lastRescheduleVenue = newVenue;
    lastRescheduleNote = note;
  }

  @override
  Future<void> approveReschedule(String id) async {
    lastApprovedRescheduleId = id;
  }
}

Map<String, dynamic> _consultation({
  required String id,
  required String studentId,
  required String adviserName,
  required String status,
  required DateTime submittedAt,
  DateTime? completedAt,
  DateTime? approvedAt,
  DateTime? consultationDate,
  String? consultationTime,
  List<String>? purposeCategories,
  String? rescheduleTime,
}) {
  return {
    'id': id,
    'student_id': studentId,
    'full_name': 'Student $id',
    'student_number': '2024-$id',
    'course_program': 'BSIT',
    'year_level': '4',
    'phone_number': '09123456789',
    'email_address': 'student$id@example.com',
    'subject_class_title': 'Capstone',
    'consultation_date': (consultationDate ?? submittedAt).toIso8601String(),
    'consultation_time': consultationTime ?? '14:30',
    'venue': 'Online',
    'advisor_name': adviserName,
    'purpose_categories': purposeCategories ?? ['Academic'],
    'detailed_concerns': 'Needs guidance',
    'issues_discussed': 'Timeline',
    'action_taken': 'Created a plan',
    'recommendations': 'Follow up',
    'student_signature': 'Student $id',
    'faculty_signature': 'Prof. Signature',
    'dean_signature': status == 'Approved' ? 'Dean Signature' : null,
    'status': status,
    'approved_at': approvedAt?.toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
    'submitted_at': submittedAt.toIso8601String(),
    'reschedule_date': status == 'Reschedule Requested'
        ? submittedAt.add(const Duration(days: 2)).toIso8601String()
        : null,
    'reschedule_time': rescheduleTime,
    'reschedule_venue': status == 'Reschedule Requested' ? 'Room 201' : null,
    'reschedule_note': status == 'Reschedule Requested' ? 'Conflict' : null,
  };
}

void main() {
  group('AppState', () {
    test('login loads user, consultations, and advisers', () async {
      final service = _FakeApiService()
        ..loginResult = {
          'id': 'student-1',
          'username': 'jane',
          'role': 'Dean',
          'display_name': 'Dean Santos',
        }
        ..advisers = [
          {'display_name': 'Prof. Cruz'},
          {'display_name': 'Prof. Reyes'},
        ]
        ..consultations = [
          _consultation(
            id: '1',
            studentId: 'student-1',
            adviserName: 'Prof. Cruz',
            status: 'Completed',
            submittedAt: DateTime(2026, 4, 10, 8),
            completedAt: DateTime(2026, 4, 10, 10),
            approvedAt: DateTime(2026, 4, 10, 9),
            purposeCategories: ['Academic', 'Career'],
          ),
        ];

      final state = AppState(service: service);

      final error = await state.login('jane', 'secret');

      expect(error, isNull);
      expect(state.isAuthenticated, isTrue);
      expect(state.userId, 'student-1');
      expect(state.displayName, 'Dean Santos');
      expect(state.displayRole, 'Dean');
      expect(state.userRole, 'Admin');
      expect(state.adviserNames, ['Prof. Cruz', 'Prof. Reyes']);
      expect(state.allConsultations, hasLength(1));
      expect(state.isLoading, isFalse);
      state.dispose();
    });

    test('login returns an error message when credentials are invalid', () async {
      final state = AppState(service: _FakeApiService());

      final error = await state.login('bad', 'creds');

      expect(error, 'Invalid username or password.');
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isFalse);
      state.dispose();
    });

    test('register forwards backend error and preserves loading state', () async {
      final service = _FakeApiService()..registerResult = 'Username taken';
      final state = AppState(service: service);

      final error = await state.register(
        username: 'jane',
        password: 'secret',
        role: 'Student',
        displayName: 'Jane Student',
      );

      expect(error, 'Username taken');
      expect(state.isLoading, isFalse);
      state.dispose();
    });

    test('consultation filters and totals reflect the loaded data set', () async {
      final service = _FakeApiService()
        ..loginResult = {
          'id': 'student-1',
          'username': 'adviser',
          'role': 'Adviser',
          'display_name': 'Prof. Cruz',
        }
        ..consultations = [
          _consultation(
            id: '1',
            studentId: 'student-1',
            adviserName: 'Prof. Cruz',
            status: 'Pending',
            submittedAt: DateTime(2026, 4, 10, 8),
          ),
          _consultation(
            id: '2',
            studentId: 'student-1',
            adviserName: 'Prof. Cruz',
            status: 'Approved',
            submittedAt: DateTime(2026, 4, 11, 8),
            approvedAt: DateTime(2026, 4, 11, 10),
          ),
          _consultation(
            id: '3',
            studentId: 'student-2',
            adviserName: 'Prof. Cruz',
            status: 'Pending Dean Approval',
            submittedAt: DateTime(2026, 4, 12, 8),
          ),
          _consultation(
            id: '4',
            studentId: 'student-2',
            adviserName: 'Prof. Cruz',
            status: 'Reschedule Requested',
            submittedAt: DateTime(2026, 4, 13, 8),
            rescheduleTime: '9:15',
          ),
          _consultation(
            id: '5',
            studentId: 'student-3',
            adviserName: 'Prof. Reyes',
            status: 'Completed',
            submittedAt: DateTime(2026, 4, 14, 8),
            completedAt: DateTime(2026, 4, 14, 12),
            approvedAt: DateTime(2026, 4, 14, 9),
            purposeCategories: ['Career'],
          ),
          _consultation(
            id: '6',
            studentId: 'student-4',
            adviserName: 'Prof. Cruz',
            status: 'Rejected',
            submittedAt: DateTime(2026, 4, 14, 9),
            purposeCategories: ['Academic'],
          ),
        ];

      final state = AppState(service: service);
      await state.login('adviser', 'secret');

      expect(state.myConsultations, hasLength(2));
      expect(state.pendingForAdviser, hasLength(1));
      expect(state.approvedForAdviser, hasLength(1));
      expect(state.pendingDeanApproval, hasLength(1));
      expect(state.rescheduleRequestsForAdviser, hasLength(1));
      expect(state.completedConsultations, hasLength(1));
      expect(state.myApprovedAppointments, hasLength(2));
      expect(state.totalPending, 1);
      expect(state.totalApproved, 1);
      expect(state.totalCompleted, 1);
      expect(state.totalRejected, 1);
      expect(state.purposeBreakdown, {'Academic': 5, 'Career': 1});
      state.dispose();
    });

    test('report helpers summarize top advisers, approval times, and day buckets', () async {
      final service = _FakeApiService()
        ..loginResult = {
          'id': 'admin-1',
          'username': 'admin',
          'role': 'Dean',
          'display_name': 'Dean Santos',
        }
        ..consultations = [
          _consultation(
            id: '1',
            studentId: 's1',
            adviserName: 'Prof. Cruz',
            status: 'Completed',
            submittedAt: DateTime(2026, 4, 10, 8),
            completedAt: DateTime(2026, 4, 10, 8, 30),
            approvedAt: DateTime(2026, 4, 10, 8, 30),
            purposeCategories: ['Academic'],
          ),
          _consultation(
            id: '2',
            studentId: 's2',
            adviserName: 'Prof. Cruz',
            status: 'Completed',
            submittedAt: DateTime(2026, 4, 11, 8),
            completedAt: DateTime(2026, 4, 11, 12),
            approvedAt: DateTime(2026, 4, 11, 9, 30),
            purposeCategories: ['Career'],
          ),
          _consultation(
            id: '3',
            studentId: 's3',
            adviserName: 'Prof. Reyes',
            status: 'Completed',
            submittedAt: DateTime(2026, 4, 12, 8),
            completedAt: DateTime(2026, 4, 12, 18),
            approvedAt: DateTime(2026, 4, 12, 11),
            purposeCategories: ['Academic'],
          ),
          _consultation(
            id: '4',
            studentId: 's4',
            adviserName: 'Prof. Reyes',
            status: 'Rejected',
            submittedAt: DateTime(2026, 4, 13, 8),
            purposeCategories: ['Academic'],
          ),
          _consultation(
            id: '5',
            studentId: 's5',
            adviserName: 'Prof. Reyes',
            status: 'Approved',
            submittedAt: DateTime(2026, 4, 14, 8),
            approvedAt: DateTime(2026, 4, 14, 17),
            purposeCategories: ['Career'],
          ),
        ];

      final state = AppState(service: service);
      await state.login('admin', 'secret');
      state.setReportRange(
        DateTimeRange(
          start: DateTime(2026, 4, 10),
          end: DateTime(2026, 4, 14),
        ),
      );

      final weekly = state.getFilteredWeeklyStats();
      final topAdvisers = state.getTopAdvisers();
      final approvalTimes = state.getApprovalTimeDistribution();

      expect(weekly['served'], [1, 1, 1, 0, 0]);
      expect(weekly['missed'], [0, 0, 0, 1, 0]);
      expect(weekly['days'], 5);
      expect(topAdvisers.first['name'], 'Prof. Cruz');
      expect(topAdvisers.first['count'], 2);
      expect(topAdvisers.first['rating'], 100.0);
      expect(topAdvisers[1]['name'], 'Prof. Reyes');
      expect(topAdvisers[1]['rating'], 50.0);
      expect(
        approvalTimes,
        {'0-1h': 1, '1-2h': 1, '2-4h': 1, '4-8h': 0, '>8h': 1},
      );
      state.dispose();
    });

    test('action methods delegate to the service with the correct payloads', () async {
      final service = _FakeApiService()
        ..loginResult = {
          'id': 'student-1',
          'username': 'jane',
          'role': 'Student',
          'display_name': 'Jane Student',
        }
        ..consultations = [
          _consultation(
            id: '1',
            studentId: 'student-1',
            adviserName: 'Prof. Cruz',
            status: 'Pending',
            submittedAt: DateTime(2026, 4, 10, 8),
          ),
        ];

      final state = AppState(service: service);
      await state.login('jane', 'secret');

      await state.approveConsultation('1', note: 'Looks good', adviserSignature: 'Prof. Cruz');
      expect(service.lastStatusId, '1');
      expect(service.lastStatusValue, 'Pending Dean Approval');
      expect(service.lastAdviserNote, 'Looks good');
      expect(service.lastAdviserSignature, 'Prof. Cruz');

      await state.rejectConsultation('1', note: 'Need revision', recommendation: 'Resubmit');
      expect(service.lastStatusValue, 'Rejected');
      expect(service.lastAdviserRecommendation, 'Resubmit');

      await state.completeConsultation('1');
      expect(service.lastStatusValue, 'Completed');

      await state.deanSign('1', deanSignature: 'Dean Santos');
      expect(service.lastStatusValue, 'Approved');
      expect(service.lastDeanSignature, 'Dean Santos');

      await state.requestReschedule(
        '1',
        newDate: DateTime(2026, 4, 20),
        newTime: const TimeOfDay(hour: 15, minute: 45),
        newVenue: 'Room 201',
        note: 'Class conflict',
      );
      expect(service.lastRescheduleId, '1');
      expect(service.lastRescheduleDate, DateTime(2026, 4, 20));
      expect(service.lastRescheduleTime, const TimeOfDay(hour: 15, minute: 45));
      expect(service.lastRescheduleVenue, 'Room 201');
      expect(service.lastRescheduleNote, 'Class conflict');

      await state.approveReschedule('1');
      expect(service.lastApprovedRescheduleId, '1');
      state.dispose();
    });

    test('logout clears authentication state and loaded consultations', () async {
      final service = _FakeApiService()
        ..loginResult = {
          'id': 'student-1',
          'username': 'jane',
          'role': 'Student',
          'display_name': 'Jane Student',
        }
        ..consultations = [
          _consultation(
            id: '1',
            studentId: 'student-1',
            adviserName: 'Prof. Cruz',
            status: 'Pending',
            submittedAt: DateTime(2026, 4, 10, 8),
          ),
        ];

      final state = AppState(service: service);
      await state.login('jane', 'secret');

      state.logout();

      expect(state.isAuthenticated, isFalse);
      expect(state.allConsultations, isEmpty);
      expect(state.userId, '');
      state.dispose();
    });
  });
}
