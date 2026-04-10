import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/consultation_form_data.dart';

const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000/api',
);

class ApiService {
  // ── Auth ────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username.trim().toLowerCase(),
              'password': password.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (data['success'] == true) return data['user'];
      return null;
    } catch (e) {
      throw Exception('Login error: $e');
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
    final response = await http
        .post(
          Uri.parse('$baseUrl/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username.trim().toLowerCase(),
            'password': password.trim(),
            'role': role,
            'display_name': displayName.trim(),
            'course_program': courseProgram?.trim(),
            'year_level': yearLevel?.trim(),
            'email': email?.trim(),
            'phone': phone?.trim(),
          }),
        )
        .timeout(const Duration(seconds: 15));

    final data = jsonDecode(response.body);
    if (data['success'] == true) return null;
    return data['error'] ?? 'Registration failed.';
  }

  // ── Users ───────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getAdvisers() async {
    final response = await http
        .get(Uri.parse('$baseUrl/advisers'))
        .timeout(const Duration(seconds: 15));

    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['data'] ?? []);
  }

  // ── Consultations ───────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> fetchConsultations() async {
    final response = await http
        .get(Uri.parse('$baseUrl/consultations'))
        .timeout(const Duration(seconds: 15));

    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['data'] ?? []);
  }

  Future<void> submitConsultation(
    ConsultationFormData data,
    String studentUserId,
  ) async {
    await http
        .post(
          Uri.parse('$baseUrl/consultations'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'student_id': studentUserId,
            'full_name': data.fullName,
            'student_number': data.studentId,
            'course_program': data.courseProgram,
            'year_level': data.yearLevel,
            'phone_number': data.phoneNumber,
            'email_address': data.emailAddress,
            'subject_class_title': data.subjectClassTitle,
            'consultation_date': data.consultationDate?.toIso8601String().split(
              'T',
            )[0],
            'consultation_time': data.consultationTime != null
                ? '${data.consultationTime!.hour}:${data.consultationTime!.minute}'
                : null,
            'venue': data.venue,
            'advisor_name': data.advisorName,
            'purpose_categories': data.purposeCategories,
            'detailed_concerns': data.detailedConcerns,
            'issues_discussed': data.issuesDiscussed,
            'action_taken': data.actionTaken,
            'recommendations': data.recommendations,
            'student_signature': data.studentSignature,
            'faculty_signature': data.facultySignature,
            'dean_signature': data.deanSignature,
          }),
        )
        .timeout(const Duration(seconds: 15));
  }

  Future<void> updateConsultationStatus(
    String id, {
    required String status,
    String? adviserNote,
    String? adviserRecommendation,
    String? adviserSignature,
    String? deanSignature,
  }) async {
    String action;
    switch (status) {
      case 'Pending Dean Approval':
        action = 'approve';
      case 'Approved':
        action = deanSignature != null ? 'dean_sign' : 'approve';
      case 'Rejected':
        action = 'reject';
      case 'Completed':
        action = 'complete';
      default:
        action = 'approve';
    }

    await http
        .post(
          Uri.parse('$baseUrl/consultations/$id/status'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': id,
            'action': action,
            'adviser_note': adviserNote,
            'adviser_recommendation': adviserRecommendation,
            'adviser_signature': adviserSignature,
            'dean_signature': deanSignature,
          }),
        )
        .timeout(const Duration(seconds: 15));
  }

  // ── Reschedule ──────────────────────────────────────────────────────────────
  Future<void> requestReschedule(
    String id, {
    required DateTime newDate,
    required TimeOfDay newTime,
    String? newVenue,
    String? note,
  }) async {
    await http
        .post(
          Uri.parse('$baseUrl/consultations/$id/reschedule'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'reschedule_date': newDate.toIso8601String().split('T')[0],
            'reschedule_time': '${newTime.hour}:${newTime.minute}',
            'reschedule_venue': newVenue,
            'reschedule_note': note,
          }),
        )
        .timeout(const Duration(seconds: 15));
  }

  Future<void> approveReschedule(String id) async {
    await http
        .post(
          Uri.parse('$baseUrl/consultations/$id/status'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'action': 'approve_reschedule'}),
        )
        .timeout(const Duration(seconds: 15));
  }
}
