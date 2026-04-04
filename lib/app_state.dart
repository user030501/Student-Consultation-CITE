import 'package:flutter/material.dart';
import 'models/consultation_form_data.dart';
import 'services/api_service.dart';

class AppUser {
  final String id;
  final String username;
  final String role;
  final String displayName;
  final String? courseProgram;
  final String? yearLevel;

  const AppUser({
    required this.id,
    required this.username,
    required this.role,
    required this.displayName,
    this.courseProgram,
    this.yearLevel,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
    id: map['id'] as String,
    username: map['username'] as String,
    role: map['role'] as String,
    displayName: map['display_name'] as String,
    courseProgram: map['course_program'] as String?,
    yearLevel: map['year_level'] as String?,
  );
}

class ConsultationEntry {
  final String id;
  final String studentUserId;
  final ConsultationFormData formData;
  String status;
  String? adviserNote;
  String? adviserRecommendation;
  DateTime? approvedAt;
  DateTime? completedAt;
  DateTime submittedAt;
  DateTime? rescheduleDate;
  TimeOfDay? rescheduleTime;
  String? rescheduleVenue;
  String? rescheduleNote;

  ConsultationEntry({
    required this.id,
    required this.studentUserId,
    required this.formData,
    this.status = 'Pending',
    this.adviserNote,
    this.adviserRecommendation,
    this.approvedAt,
    this.completedAt,
    DateTime? submittedAt,
    this.rescheduleDate,
    this.rescheduleTime,
    this.rescheduleVenue,
    this.rescheduleNote,
  }) : submittedAt = submittedAt ?? DateTime.now();

  factory ConsultationEntry.fromMap(Map<String, dynamic> map) {
    TimeOfDay? time;
    if (map['consultation_time'] != null) {
      final parts = (map['consultation_time'] as String).split(':');
      time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    TimeOfDay? rescheduleTime;
    if (map['reschedule_time'] != null) {
      final parts = (map['reschedule_time'] as String).split(':');
      rescheduleTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    final formData = ConsultationFormData(
      fullName: map['full_name'] ?? '',
      studentId: map['student_number'] ?? '',
      courseProgram: map['course_program'] ?? '',
      yearLevel: map['year_level'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      emailAddress: map['email_address'] ?? '',
      subjectClassTitle: map['subject_class_title'],
      consultationDate: map['consultation_date'] != null
          ? DateTime.parse(map['consultation_date'])
          : null,
      consultationTime: time,
      venue: map['venue'] ?? 'In-person',
      advisorName: map['advisor_name'] ?? '',
      purposeCategories: map['purpose_categories'] != null
          ? List<String>.from(map['purpose_categories'])
          : [],
      detailedConcerns: map['detailed_concerns'] ?? '',
      issuesDiscussed: map['issues_discussed'] ?? '',
      actionTaken: map['action_taken'] ?? '',
      recommendations: map['recommendations'] ?? '',
      studentSignature: map['student_signature'] ?? '',
      facultySignature: map['faculty_signature'] ?? '',
      deanSignature: map['dean_signature'],
    );

    return ConsultationEntry(
      id: map['id'] as String,
      studentUserId: map['student_id'] ?? '',
      formData: formData,
      status: map['status'] ?? 'Pending',
      adviserNote: map['adviser_note'],
      adviserRecommendation: map['adviser_recommendation'],
      approvedAt: map['approved_at'] != null ? DateTime.parse(map['approved_at']) : null,
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at']) : null,
      submittedAt: map['submitted_at'] != null ? DateTime.parse(map['submitted_at']) : DateTime.now(),
      rescheduleDate: map['reschedule_date'] != null ? DateTime.parse(map['reschedule_date']) : null,
      rescheduleTime: rescheduleTime,
      rescheduleVenue: map['reschedule_venue'],
      rescheduleNote: map['reschedule_note'],
    );
  }
}

class AppState extends ChangeNotifier {
  final _service = ApiService();

  AppUser? _currentUser;
  List<ConsultationEntry> _consultations = [];
  List<String> _adviserNames = [];
  bool isLoading = false;

  AppUser? get currentUser => _currentUser;
  String get userRole {
    final role = _currentUser?.role?? 'Student';
    return (role == 'Dean') ? 'Admin' : role;
  }
  String get displayRole => _currentUser?.role ?? 'Student';
  String get displayName => _currentUser?.displayName ?? '';
  String get userId => _currentUser?.id ?? '';
  bool get isAuthenticated => _currentUser != null;
  List<String> get adviserNames => _adviserNames;

  // ── Auth ────────────────────────────────────────────────────────────────────
  Future<String?> login(String username, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await _service.login(username, password);
      if (data == null) {
        isLoading = false;
        notifyListeners();
        return 'Invalid username or password.';
      }
      _currentUser = AppUser.fromMap(data);
      await _loadConsultations();
      await _loadAdvisers();
      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return 'Error: ${e.toString()}';
    }
  }

  Future<String?> register({
    required String username,
    required String password,
    required String role,
    required String displayName,
    String? courseProgram,
    String? yearLevel,
    String? email,
    String? phone,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      final error = await _service.register(
        username: username,
        password: password,
        role: role,
        displayName: displayName,
        courseProgram: courseProgram,
        yearLevel: yearLevel,
        email: email,
        phone: phone,
      );
      isLoading = false;
      notifyListeners();
      return error;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return 'Registration failed. Please try again.';
    }
  }

  void logout() {
    _currentUser = null;
    _consultations = [];
    notifyListeners();
  }

  // ── Data ────────────────────────────────────────────────────────────────────
  Future<void> _loadConsultations() async {
    final data = await _service.fetchConsultations();
    _consultations = data.map((m) => ConsultationEntry.fromMap(m)).toList();
  }

  Future<void> _loadAdvisers() async {
    final data = await _service.getAdvisers();
    _adviserNames = data.map((m) => m['display_name'] as String).toList();
  }

  Future<void> refreshConsultations() async {
    await _loadConsultations();
    notifyListeners();
  }

  // ── Filters ─────────────────────────────────────────────────────────────────
  List<ConsultationEntry> get allConsultations =>
      List.unmodifiable(_consultations);

  List<ConsultationEntry> get myConsultations =>
      _consultations.where((c) => c.studentUserId == userId).toList();

  List<ConsultationEntry> get pendingForAdviser => _consultations
      .where((c) =>
  c.formData.advisorName == displayName && c.status == 'Pending')
      .toList();

  // Adviser Schedule shows Approved (dean already signed, meeting can happen)
  List<ConsultationEntry> get approvedForAdviser => _consultations
      .where((c) =>
  c.formData.advisorName == displayName && c.status == 'Approved')
      .toList();

  // Admin Appointments tab shows Pending Dean Approval
  List<ConsultationEntry> get pendingDeanApproval => _consultations
      .where((c) => c.status == 'Pending Dean Approval')
      .toList();

  List<ConsultationEntry> get myApprovedAppointments => _consultations
      .where((c) => c.studentUserId == userId)
      .toList();

  List<ConsultationEntry> get rescheduleRequestsForAdviser => _consultations
      .where((c) =>
  c.formData.advisorName == displayName &&
      c.status == 'Reschedule Requested')
      .toList();

  List<ConsultationEntry> get completedConsultations =>
      _consultations.where((c) => c.status == 'Completed').toList();

  // ── Actions ─────────────────────────────────────────────────────────────────
  Future<void> submitConsultation(ConsultationFormData data) async {
    await _service.submitConsultation(data, userId);
    await refreshConsultations();
  }

  Future<void> approveConsultation(String id, {String? note, String? adviserSignature}) async {
    await _service.updateConsultationStatus(id,
        status: 'Pending Dean Approval', adviserNote: note, adviserSignature: adviserSignature);
    await refreshConsultations();
  }

  Future<void> rejectConsultation(String id, {String? note, String? recommendation}) async {
    await _service.updateConsultationStatus(id,
        status: 'Rejected', adviserNote: note, adviserRecommendation: recommendation);
    await refreshConsultations();
  }

  Future<void> completeConsultation(String id) async {
    await _service.updateConsultationStatus(id, status: 'Completed');
    await refreshConsultations();
  }

  Future<void> deanSign(String id, {required String deanSignature}) async {
    await _service.updateConsultationStatus(id,
        status: 'Approved', deanSignature: deanSignature);
    await refreshConsultations();
  }

  Future<void> requestReschedule(String id, {
    required DateTime newDate,
    required TimeOfDay newTime,
    String? newVenue,
    String? note,
  }) async {
    await _service.requestReschedule(id, newDate: newDate, newTime: newTime, newVenue: newVenue, note: note);
    await refreshConsultations();
  }

  Future<void> approveReschedule(String id) async {
    await _service.approveReschedule(id);
    await refreshConsultations();
  }

  // ── Stats ───────────────────────────────────────────────────────────────────
  int get totalPending =>
      _consultations.where((c) => c.status == 'Pending').length;
  int get totalApproved =>
      _consultations.where((c) => c.status == 'Approved').length;
  int get totalCompleted =>
      _consultations.where((c) => c.status == 'Completed').length;
  int get totalRejected =>
      _consultations.where((c) => c.status == 'Rejected').length;

  Map<String, int> get purposeBreakdown {
    final map = <String, int>{};
    for (final c in _consultations) {
      for (final p in c.formData.purposeCategories) {
        map[p] = (map[p] ?? 0) + 1;
      }
    }
    return map;
  }
}