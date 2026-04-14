import 'package:flutter/material.dart';
import 'dart:convert' show utf8;
import 'package:url_launcher/url_launcher.dart';
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
  AppState({ApiService? service}) : _service = service ?? ApiService();

  final ApiService _service;


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


  // ── Reports State ───────────────────────────────────────────────────────────
  DateTimeRange _reportRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 6)),
    end: DateTime.now(),
  );


  DateTimeRange get reportRange => _reportRange;


  void setReportRange(DateTimeRange range) {
    _reportRange = range;
    notifyListeners();
  }


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


  // ── Reports Data ────────────────────────────────────────────────────────────
 
  /// Returns weekly/daily stats for the selected report range
  Map<String, dynamic> getFilteredWeeklyStats() {
    final start = _reportRange.start;
    final end = _reportRange.end;
    final totalDays = end.difference(start).inDays + 1;
   
    final servedByDay = List.filled(totalDays, 0);
    final missedByDay = List.filled(totalDays, 0);


    for (final c in _consultations) {
      final date = c.completedAt ?? c.submittedAt;
      if (date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          date.isBefore(end.add(const Duration(days: 1)))) {
        final dayIndex = date.difference(start).inDays;
        if (dayIndex >= 0 && dayIndex < totalDays) {
          if (c.status == 'Completed') {
            servedByDay[dayIndex]++;
          } else if (c.status == 'Rejected') {
            missedByDay[dayIndex]++;
          }
        }
      }
    }
   
    return {
      'served': servedByDay,
      'missed': missedByDay,
      'days': totalDays,
    };
  }


  /// Returns top performing advisers based on completed consultations
  List<Map<String, dynamic>> getTopAdvisers() {
    final counts = <String, int>{};
    for (final c in _consultations) {
      if (c.status == 'Completed') {
        final name = c.formData.advisorName;
        counts[name] = (counts[name] ?? 0) + 1;
      }
    }
   
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
   
    int max = sorted.isEmpty ? 1 : sorted.first.value;
   
    return sorted.take(5).map((e) => {
      'name': e.key,
      'count': e.value,
      'rating': (e.value / max) * 100, // Mock "rating" based on relative performance
    }).toList();
  }


  /// Returns distribution of first reply/approval time
  Map<String, int> getApprovalTimeDistribution() {
    final distribution = {
      '0-1h': 0,
      '1-2h': 0,
      '2-4h': 0,
      '4-8h': 0,
      '>8h': 0,
    };


    for (final c in _consultations) {
      if (c.approvedAt != null) {
        final duration = c.approvedAt!.difference(c.submittedAt);
        final hours = duration.inHours;


        if (hours < 1) {
          distribution['0-1h'] = distribution['0-1h']! + 1;
        } else if (hours < 2) {
          distribution['1-2h'] = distribution['1-2h']! + 1;
        } else if (hours < 4) {
          distribution['2-4h'] = distribution['2-4h']! + 1;
        } else if (hours < 8) {
          distribution['4-8h'] = distribution['4-8h']! + 1;
        } else {
          distribution['>8h'] = distribution['>8h']! + 1;
        }
      }
    }
    return distribution;
  }


  /// Exports current filtered consultations to CSV
  Future<void> exportToCSV() async {
    final filtered = _consultations.where((c) {
      final date = c.completedAt ?? c.submittedAt;
      return date.isAfter(_reportRange.start.subtract(const Duration(seconds: 1))) &&
             date.isBefore(_reportRange.end.add(const Duration(days: 1)));
    }).toList();


    String csv = 'Date,Student ID,Student Name,Adviser,Status,Purpose,Venue,Submitted At\n';
    for (final c in filtered) {
      final d = c.formData.consultationDate;
      final dateStr = d != null ? '${d.year}-${d.month}-${d.day}' : 'N/A';
      csv += '"$dateStr",'
             '"${c.formData.studentId}",'
             '"${c.formData.fullName}",'
             '"${c.formData.advisorName}",'
             '"${c.status}",'
             '"${c.formData.purposeCategories.join(" | ")}",'
             '"${c.formData.venue}",'
             '"${c.submittedAt}"\n';
    }


    final bytes = utf8.encode(csv);
    final uri = Uri.dataFromBytes(bytes, mimeType: 'text/csv');
    await launchUrl(uri);
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
