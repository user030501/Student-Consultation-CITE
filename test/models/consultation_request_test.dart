import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namer_app/models/consultation_request.dart';

void main() {
  group('ConsultationRequest', () {
    test('serializes and deserializes consistently', () {
      final request = ConsultationRequest(
        studentName: 'Jane Student',
        studentId: '2024-0001',
        adviser: 'Prof. Cruz',
        mode: 'Online',
        preferredDate: DateTime(2026, 4, 21),
        preferredTime: const TimeOfDay(hour: 10, minute: 45),
        subject: 'Capstone',
        details: 'Need advice on project scope',
        submittedAt: DateTime.utc(2026, 4, 20, 7, 30),
      );

      final restored = ConsultationRequest.fromJson(request.toJson());

      expect(restored.studentName, request.studentName);
      expect(restored.studentId, request.studentId);
      expect(restored.adviser, request.adviser);
      expect(restored.mode, request.mode);
      expect(restored.preferredDate, request.preferredDate);
      expect(restored.preferredTime?.hour, request.preferredTime?.hour);
      expect(restored.preferredTime?.minute, request.preferredTime?.minute);
      expect(restored.subject, request.subject);
      expect(restored.details, request.details);
      expect(restored.submittedAt, request.submittedAt);
    });

    test('handles missing optional fields', () {
      final restored = ConsultationRequest.fromJson({
        'studentName': 'Jane Student',
        'studentId': '2024-0001',
        'adviser': 'Prof. Cruz',
        'mode': 'In-person',
        'subject': 'Enrollment',
        'details': 'Question about schedule',
      });

      expect(restored.preferredDate, isNull);
      expect(restored.preferredTime, isNull);
      expect(restored.subject, 'Enrollment');
      expect(restored.details, 'Question about schedule');
    });
  });
}
