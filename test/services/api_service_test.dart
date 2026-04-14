import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:namer_app/models/consultation_form_data.dart';
import 'package:namer_app/services/api_service.dart';

void main() {
  group('ApiService', () {
    test('login normalizes credentials and returns the user on success', () async {
      late Uri requestUri;
      late Map<String, dynamic> requestBody;

      final service = ApiService(
        client: MockClient((request) async {
          requestUri = request.url;
          requestBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'success': true,
              'user': {
                'id': 'u1',
                'username': 'jane',
                'role': 'Student',
                'display_name': 'Jane Student',
              },
            }),
            200,
          );
        }),
      );

      final result = await service.login('  Jane ', ' pass123 ');

      expect(requestUri.toString(), '$baseUrl/login');
      expect(requestBody, {'username': 'jane', 'password': 'pass123'});
      expect(result?['id'], 'u1');
      service.dispose();
    });

    test('login returns null when backend rejects the credentials', () async {
      final service = ApiService(
        client: MockClient(
          (_) async => http.Response(jsonEncode({'success': false}), 401),
        ),
      );

      expect(await service.login('bad', 'creds'), isNull);
      service.dispose();
    });

    test('register trims fields and returns backend error when unsuccessful', () async {
      late Map<String, dynamic> requestBody;

      final service = ApiService(
        client: MockClient((request) async {
          requestBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({'success': false, 'error': 'Username already exists'}),
            200,
          );
        }),
      );

      final error = await service.register(
        username: ' Student ',
        password: ' secret ',
        role: 'Student',
        displayName: ' Jane Student ',
        courseProgram: ' BSIT ',
        yearLevel: ' 4 ',
        email: ' jane@example.com ',
        phone: ' 09123 ',
      );

      expect(error, 'Username already exists');
      expect(requestBody['username'], 'student');
      expect(requestBody['display_name'], 'Jane Student');
      expect(requestBody['course_program'], 'BSIT');
      expect(requestBody['year_level'], '4');
      expect(requestBody['email'], 'jane@example.com');
      expect(requestBody['phone'], '09123');
      service.dispose();
    });

    test('getAdvisers and fetchConsultations parse list responses', () async {
      final service = ApiService(
        client: MockClient((request) async {
          if (request.url.path.endsWith('/advisers')) {
            return http.Response(
              jsonEncode({
                'data': [
                  {'display_name': 'Prof. Cruz'},
                ],
              }),
              200,
            );
          }

          return http.Response(
            jsonEncode({
              'data': [
                {'id': 'c1'},
              ],
            }),
            200,
          );
        }),
      );

      final advisers = await service.getAdvisers();
      final consultations = await service.fetchConsultations();

      expect(advisers, [
        {'display_name': 'Prof. Cruz'},
      ]);
      expect(consultations, [
        {'id': 'c1'},
      ]);
      service.dispose();
    });

    test('submitConsultation serializes the form payload expected by the backend', () async {
      late Uri requestUri;
      late Map<String, dynamic> requestBody;

      final service = ApiService(
        client: MockClient((request) async {
          requestUri = request.url;
          requestBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('{}', 200);
        }),
      );

      final form = ConsultationFormData(
        fullName: 'Jane Student',
        studentId: '2024-0001',
        courseProgram: 'BSIT',
        yearLevel: '4',
        phoneNumber: '09123456789',
        emailAddress: 'jane@example.com',
        subjectClassTitle: 'Capstone',
        consultationDate: DateTime(2026, 4, 15),
        consultationTime: const TimeOfDay(hour: 14, minute: 5),
        venue: 'Online',
        advisorName: 'Prof. Cruz',
        purposeCategories: const ['Academic', 'Personal'],
        detailedConcerns: 'Needs guidance',
        issuesDiscussed: 'Thesis',
        actionTaken: 'Planned milestones',
        recommendations: 'Follow up weekly',
        studentSignature: 'Jane Student',
        facultySignature: 'Prof. Cruz',
        deanSignature: 'Dean Santos',
      );

      await service.submitConsultation(form, 'student-1');

      expect(requestUri.toString(), '$baseUrl/consultations');
      expect(requestBody['student_id'], 'student-1');
      expect(requestBody['consultation_date'], '2026-04-15');
      expect(requestBody['consultation_time'], '14:5');
      expect(requestBody['purpose_categories'], ['Academic', 'Personal']);
      expect(requestBody['dean_signature'], 'Dean Santos');
      service.dispose();
    });

    test('updateConsultationStatus maps statuses to backend actions', () async {
      final recordedActions = <String>[];

      final service = ApiService(
        client: MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          recordedActions.add(body['action'] as String);
          return http.Response('{}', 200);
        }),
      );

      await service.updateConsultationStatus('c1', status: 'Pending Dean Approval');
      await service.updateConsultationStatus('c1', status: 'Approved');
      await service.updateConsultationStatus(
        'c1',
        status: 'Approved',
        deanSignature: 'Dean Santos',
      );
      await service.updateConsultationStatus('c1', status: 'Rejected');
      await service.updateConsultationStatus('c1', status: 'Completed');

      expect(
        recordedActions,
        ['approve', 'approve', 'dean_sign', 'reject', 'complete'],
      );
      service.dispose();
    });

    test('requestReschedule and approveReschedule send the expected payloads', () async {
      final captured = <Map<String, dynamic>>[];

      final service = ApiService(
        client: MockClient((request) async {
          captured.add(jsonDecode(request.body) as Map<String, dynamic>);
          return http.Response('{}', 200);
        }),
      );

      await service.requestReschedule(
        'c1',
        newDate: DateTime(2026, 4, 20),
        newTime: const TimeOfDay(hour: 9, minute: 30),
        newVenue: 'Room 201',
        note: 'Schedule conflict',
      );
      await service.approveReschedule('c1');

      expect(captured.first, {
        'reschedule_date': '2026-04-20',
        'reschedule_time': '9:30',
        'reschedule_venue': 'Room 201',
        'reschedule_note': 'Schedule conflict',
      });
      expect(captured.last, {'action': 'approve_reschedule'});
      service.dispose();
    });
  });
}
