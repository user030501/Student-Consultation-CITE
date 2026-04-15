import 'package:flutter/material.dart';

class ConsultationFormData {
  String fullName;
  String studentId;
  String courseProgram;
  String yearLevel;
  String phoneNumber;
  String emailAddress;
  String? subjectClassTitle;

  DateTime? consultationDate;
  TimeOfDay? consultationTime;
  String venue;
  String advisorName;

  List<String> purposeCategories;
  String detailedConcerns;

  String issuesDiscussed;
  String actionTaken;
  String recommendations;

  String studentSignature;
  String facultySignature;
  String? deanSignature;
  DateTime submittedAt;

  ConsultationFormData({
    this.fullName = '',
    this.studentId = '',
    this.courseProgram = '',
    this.yearLevel = '',
    this.phoneNumber = '',
    this.emailAddress = '',
    this.subjectClassTitle,
    this.consultationDate,
    this.consultationTime,
    this.venue = 'In-person',
    this.advisorName = '',
    List<String>? purposeCategories,
    this.detailedConcerns = '',
    this.issuesDiscussed = '',
    this.actionTaken = '',
    this.recommendations = '',
    this.studentSignature = '',
    this.facultySignature = '',
    this.deanSignature,
    DateTime? submittedAt,
  })  : purposeCategories = purposeCategories ?? [],
        submittedAt = submittedAt ?? DateTime.now();

  bool get isBasicInfoComplete =>
      fullName.isNotEmpty &&
          studentId.isNotEmpty &&
          courseProgram.isNotEmpty &&
          yearLevel.isNotEmpty &&
          phoneNumber.isNotEmpty &&
          emailAddress.isNotEmpty;

  bool get isConsultationDetailsComplete =>
      consultationDate != null &&
          consultationTime != null &&
          venue.isNotEmpty &&
          advisorName.isNotEmpty;

  bool get isPurposeComplete =>
      purposeCategories.isNotEmpty && detailedConcerns.isNotEmpty;

  bool get isActionPlanComplete =>
      issuesDiscussed.isNotEmpty &&
          actionTaken.isNotEmpty &&
          recommendations.isNotEmpty;

  bool get isSignatureComplete => studentSignature.isNotEmpty;

  bool get isFormComplete =>
      isBasicInfoComplete &&
          isConsultationDetailsComplete &&
          isPurposeComplete &&
          isActionPlanComplete &&
          isSignatureComplete;

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'studentId': studentId,
    'courseProgram': courseProgram,
    'yearLevel': yearLevel,
    'phoneNumber': phoneNumber,
    'emailAddress': emailAddress,
    'subjectClassTitle': subjectClassTitle,
    'consultationDate': consultationDate?.toIso8601String(),
    'consultationTime': consultationTime != null
        ? '${consultationTime!.hour}:${consultationTime!.minute}'
        : null,
    'venue': venue,
    'advisorName': advisorName,
    'purposeCategories': purposeCategories,
    'detailedConcerns': detailedConcerns,
    'issuesDiscussed': issuesDiscussed,
    'actionTaken': actionTaken,
    'recommendations': recommendations,
    'studentSignature': studentSignature,
    'facultySignature': facultySignature,
    'deanSignature': deanSignature,
    'submittedAt': submittedAt.toIso8601String(),
  };

  static ConsultationFormData fromJson(Map<String, dynamic> json) =>
      ConsultationFormData(
        fullName: json['fullName'] as String? ?? '',
        studentId: json['studentId'] as String? ?? '',
        courseProgram: json['courseProgram'] as String? ?? '',
        yearLevel: json['yearLevel'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String? ?? '',
        emailAddress: json['emailAddress'] as String? ?? '',
        subjectClassTitle: json['subjectClassTitle'] as String?,
        consultationDate: json['consultationDate'] != null
            ? DateTime.parse(json['consultationDate'] as String)
            : null,
        consultationTime: json['consultationTime'] != null
            ? TimeOfDay(
          hour: int.parse(
              (json['consultationTime'] as String).split(':')[0]),
          minute: int.parse(
              (json['consultationTime'] as String).split(':')[1]),
        )
            : null,
        venue: json['venue'] as String? ?? 'In-person',
        advisorName: json['advisorName'] as String? ?? '',
        purposeCategories: List<String>.from(
          json['purposeCategories'] as List? ?? [],
        ),
        detailedConcerns: json['detailedConcerns'] as String? ?? '',
        issuesDiscussed: json['issuesDiscussed'] as String? ?? '',
        actionTaken: json['actionTaken'] as String? ?? '',
        recommendations: json['recommendations'] as String? ?? '',
        studentSignature: json['studentSignature'] as String? ?? '',
        facultySignature: json['facultySignature'] as String? ?? '',
        deanSignature: json['deanSignature'] as String?,
        submittedAt: json['submittedAt'] != null
            ? DateTime.parse(json['submittedAt'] as String)
            : DateTime.now(),
      );
}