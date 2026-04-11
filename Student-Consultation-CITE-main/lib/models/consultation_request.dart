import 'package:flutter/material.dart';

class ConsultationRequest {
  final String studentName;
  final String studentId;
  final String adviser;
  final String mode;
  final DateTime? preferredDate;
  final TimeOfDay? preferredTime;
  final String subject;
  final String details;
  final DateTime submittedAt;

  ConsultationRequest({
    required this.studentName,
    required this.studentId,
    required this.adviser,
    required this.mode,
    this.preferredDate,
    this.preferredTime,
    required this.subject,
    required this.details,
    DateTime? submittedAt,
  }) : submittedAt = submittedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'studentName': studentName,
        'studentId': studentId,
        'adviser': adviser,
        'mode': mode,
        'preferredDate': preferredDate?.toIso8601String(),
        'preferredTime': preferredTime != null ? '${preferredTime!.hour}:${preferredTime!.minute}' : null,
        'subject': subject,
        'details': details,
        'submittedAt': submittedAt.toIso8601String(),
      };

  static ConsultationRequest fromJson(Map<String, dynamic> json) => ConsultationRequest(
        studentName: json['studentName'] as String,
        studentId: json['studentId'] as String,
        adviser: json['adviser'] as String,
        mode: json['mode'] as String,
        preferredDate: json['preferredDate'] != null ? DateTime.parse(json['preferredDate'] as String) : null,
        preferredTime: json['preferredTime'] != null
            ? TimeOfDay(
                hour: int.parse((json['preferredTime'] as String).split(':')[0]),
                minute: int.parse((json['preferredTime'] as String).split(':')[1]),
              )
            : null,
        subject: json['subject'] as String,
        details: json['details'] as String,
        submittedAt: json['submittedAt'] != null ? DateTime.parse(json['submittedAt'] as String) : DateTime.now(),
      );
}
