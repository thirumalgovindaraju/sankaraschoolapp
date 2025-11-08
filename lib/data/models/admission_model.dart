import 'package:flutter/material.dart';

// lib/data/models/admission_model.dart
class AdmissionModel {
  final String studentName;
  final String email;
  final String phone;
  final String grade;

  AdmissionModel({
    required this.studentName,
    required this.email,
    required this.phone,
    required this.grade,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentName': studentName,
      'email': email,
      'phone': phone,
      'grade': grade,
    };
  }
}

