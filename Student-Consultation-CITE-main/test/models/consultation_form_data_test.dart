import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namer_app/models/consultation_form_data.dart';

void main() {
  group('ConsultationFormData', () {
    test('reports incomplete form until required fields are filled', () {
      final form = ConsultationFormData();

      expect(form.isFormComplete, isFalse);
      expect(form.isBasicInfoComplete, isFalse);
      expect(form.isConsultationDetailsComplete, isFalse);
      expect(form.isPurposeComplete, isFalse);
      expect(form.isActionPlanComplete, isFalse);
      expect(form.isSignatureComplete, isFalse);
    });

    test('reports complete form when all required fields are present', () {
      final form = ConsultationFormData(
        fullName: 'Jane Student',
        studentId: '2024-0001',
        courseProgram: 'BSIT',
        yearLevel: '4',
        phoneNumber: '09123456789',
        emailAddress: 'jane@example.com',
        consultationDate: DateTime(2026, 4, 9),
        consultationTime: const TimeOfDay(hour: 14, minute: 30),
        advisorName: 'Prof. Cruz',
        purposeCategories: const ['Academic'],
        detailedConcerns: 'Needs guidance',
        issuesDiscussed: 'Thesis timeline',
        actionTaken: 'Created milestones',
        recommendations: 'Weekly follow-up',
        studentSignature: 'Jane Student',
      );

      expect(form.isFormComplete, isTrue);
      expect(form.isBasicInfoComplete, isTrue);
      expect(form.isConsultationDetailsComplete, isTrue);
      expect(form.isPurposeComplete, isTrue);
      expect(form.isActionPlanComplete, isTrue);
      expect(form.isSignatureComplete, isTrue);
    });

    test('serializes and deserializes consistently', () {
      final form = ConsultationFormData(
        fullName: 'Jane Student',
        studentId: '2024-0001',
        courseProgram: 'BSIT',
        yearLevel: '4',
        phoneNumber: '09123456789',
        emailAddress: 'jane@example.com',
        subjectClassTitle: 'Capstone',
        consultationDate: DateTime(2026, 4, 9),
        consultationTime: const TimeOfDay(hour: 14, minute: 30),
        venue: 'Online',
        advisorName: 'Prof. Cruz',
        purposeCategories: const ['Academic', 'Personal'],
        detailedConcerns: 'Needs guidance',
        issuesDiscussed: 'Thesis timeline',
        actionTaken: 'Created milestones',
        recommendations: 'Weekly follow-up',
        studentSignature: 'Jane Student',
        facultySignature: 'Prof. Cruz',
        deanSignature: 'Dean Santos',
        submittedAt: DateTime.utc(2026, 4, 9, 6),
      );

      final restored = ConsultationFormData.fromJson(form.toJson());

      expect(restored.fullName, form.fullName);
      expect(restored.studentId, form.studentId);
      expect(restored.courseProgram, form.courseProgram);
      expect(restored.yearLevel, form.yearLevel);
      expect(restored.phoneNumber, form.phoneNumber);
      expect(restored.emailAddress, form.emailAddress);
      expect(restored.subjectClassTitle, form.subjectClassTitle);
      expect(restored.consultationDate, form.consultationDate);
      expect(restored.consultationTime?.hour, form.consultationTime?.hour);
      expect(restored.consultationTime?.minute, form.consultationTime?.minute);
      expect(restored.venue, form.venue);
      expect(restored.advisorName, form.advisorName);
      expect(restored.purposeCategories, form.purposeCategories);
      expect(restored.detailedConcerns, form.detailedConcerns);
      expect(restored.issuesDiscussed, form.issuesDiscussed);
      expect(restored.actionTaken, form.actionTaken);
      expect(restored.recommendations, form.recommendations);
      expect(restored.studentSignature, form.studentSignature);
      expect(restored.facultySignature, form.facultySignature);
      expect(restored.deanSignature, form.deanSignature);
      expect(restored.submittedAt, form.submittedAt);
    });
  });
}
