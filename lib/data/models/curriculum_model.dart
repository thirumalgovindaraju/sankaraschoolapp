import 'package:flutter/material.dart';

// lib/data/models/curriculum_model.dart


class CurriculumModel {
  final String id;
  final String title;
  final String description;
  final String grade;
  final List<Subject> subjects;
  final String? imageUrl;

  CurriculumModel({
    required this.id,
    required this.title,
    required this.description,
    required this.grade,
    required this.subjects,
    this.imageUrl,
  });

  factory CurriculumModel.fromJson(Map<String, dynamic> json) {
    return CurriculumModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      grade: json['grade'] ?? '',
      subjects: (json['subjects'] as List?)
          ?.map((s) => Subject.fromJson(s))
          .toList() ??
          [],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'grade': grade,
      'subjects': subjects.map((s) => s.toJson()).toList(),
      'image_url': imageUrl,
    };
  }
}

class Subject {
  final String id;
  final String name;
  final String code;
  final String description;
  final int credits;
  final String? teacher;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.credits,
    this.teacher,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      credits: json['credits'] ?? 0,
      teacher: json['teacher'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'credits': credits,
      'teacher': teacher,
    };
  }
}

