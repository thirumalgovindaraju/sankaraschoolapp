// lib/data/models/grade_model.dart

class GradeModel {
  final String id;
  final String studentId;
  final String subjectId;
  final String subjectName;
  final String examType; // midterm, final, quiz, assignment
  final double marks;
  final double maxMarks;
  final String grade;
  final DateTime examDate;
  final String? remarks;

  GradeModel({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.subjectName,
    required this.examType,
    required this.marks,
    required this.maxMarks,
    required this.grade,
    required this.examDate,
    this.remarks,
  });

  double get percentage => (marks / maxMarks) * 100;

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json['id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      subjectId: json['subject_id']?.toString() ?? '',
      subjectName: json['subject_name'] ?? '',
      examType: json['exam_type'] ?? '',
      marks: (json['marks'] ?? 0).toDouble(),
      maxMarks: (json['max_marks'] ?? 0).toDouble(),
      grade: json['grade'] ?? '',
      examDate: DateTime.parse(json['exam_date']),
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'subject_id': subjectId,
      'subject_name': subjectName,
      'exam_type': examType,
      'marks': marks,
      'max_marks': maxMarks,
      'grade': grade,
      'exam_date': examDate.toIso8601String(),
      'remarks': remarks,
    };
  }
}