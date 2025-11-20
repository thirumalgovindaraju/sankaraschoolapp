import 'package:flutter/material.dart';

// lib/data/models/faculty_model.dart
// lib/data/models/faculty_model.dart

class FacultyModel {
  final String id; // Firestore document ID
  final String teacherId; // Custom teacher ID (e.g., "TCH001")
  final String name;
  final String email;
  final String phone;
  final String gender;
  final String subject;
  final String qualification;
  final int experience;
  final String joiningDate;
  final List<String> classesAssigned;
  final String address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FacultyModel({
    required this.id,
    required this.teacherId,
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.subject,
    required this.qualification,
    required this.experience,
    required this.joiningDate,
    required this.classesAssigned,
    required this.address,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert from Firestore Map to FacultyModel
  factory FacultyModel.fromMap(Map<String, dynamic> map, String documentId) {
    return FacultyModel(
      id: documentId,
      teacherId: map['teacher_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      gender: map['gender'] ?? 'Male',
      subject: map['subject'] ?? '',
      qualification: map['qualification'] ?? '',
      experience: map['experience'] ?? 0,
      joiningDate: map['joining_date'] ?? '',
      classesAssigned: List<String>.from(map['classes_assigned'] ?? []),
      address: map['address'] ?? '',
      createdAt: map['created_at'] != null
          ? (map['created_at'] as dynamic).toDate()
          : null,
      updatedAt: map['updated_at'] != null
          ? (map['updated_at'] as dynamic).toDate()
          : null,
    );
  }

  /// Convert FacultyModel to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'teacher_id': teacherId,
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'subject': subject,
      'qualification': qualification,
      'experience': experience,
      'joining_date': joiningDate,
      'classes_assigned': classesAssigned,
      'address': address,
      // Note: created_at and updated_at are handled by Firestore FieldValue.serverTimestamp()
    };
  }

  /// Convert to plain Map for UI compatibility
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacher_id': teacherId,
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'subject': subject,
      'qualification': qualification,
      'experience': experience,
      'joining_date': joiningDate,
      'classes_assigned': classesAssigned,
      'address': address,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  FacultyModel copyWith({
    String? id,
    String? teacherId,
    String? name,
    String? email,
    String? phone,
    String? gender,
    String? subject,
    String? qualification,
    int? experience,
    String? joiningDate,
    List<String>? classesAssigned,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FacultyModel(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      subject: subject ?? this.subject,
      qualification: qualification ?? this.qualification,
      experience: experience ?? this.experience,
      joiningDate: joiningDate ?? this.joiningDate,
      classesAssigned: classesAssigned ?? this.classesAssigned,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'FacultyModel(id: $id, teacherId: $teacherId, name: $name, subject: $subject)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FacultyModel &&
        other.id == id &&
        other.teacherId == teacherId;
  }

  @override
  int get hashCode => id.hashCode ^ teacherId.hashCode;
}