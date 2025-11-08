// lib/data/models/report_card_model.dart

class ReportCardModel {
  final String id;
  final String studentId;
  final String studentName;
  final String academicYear;
  final String term;
  final String grade;
  final DateTime issueDate;
  final List<SubjectGrade> subjects;
  final double overallPercentage;
  final String overallGrade;
  final int totalMarks;
  final int obtainedMarks;
  final String remarks;
  final String teacherComments;
  final int attendancePercentage;
  final int presentDays;
  final int totalDays;
  final String status; // 'published', 'draft', 'pending'

  ReportCardModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.academicYear,
    required this.term,
    required this.grade,
    required this.issueDate,
    required this.subjects,
    required this.overallPercentage,
    required this.overallGrade,
    required this.totalMarks,
    required this.obtainedMarks,
    required this.remarks,
    required this.teacherComments,
    required this.attendancePercentage,
    required this.presentDays,
    required this.totalDays,
    this.status = 'published',
  });

  factory ReportCardModel.fromJson(Map<String, dynamic> json) {
    return ReportCardModel(
      id: json['id'] ?? '',
      studentId: json['student_id'] ?? json['studentId'] ?? '',
      studentName: json['student_name'] ?? json['studentName'] ?? '',
      academicYear: json['academic_year'] ?? json['academicYear'] ?? '',
      term: json['term'] ?? '',
      grade: json['grade'] ?? '',
      issueDate: json['issue_date'] != null
          ? DateTime.parse(json['issue_date'])
          : json['issueDate'] != null
          ? DateTime.parse(json['issueDate'])
          : DateTime.now(),
      subjects: (json['subjects'] as List<dynamic>?)
          ?.map((s) => SubjectGrade.fromJson(s))
          .toList() ??
          [],
      overallPercentage: (json['overall_percentage'] ?? json['overallPercentage'] ?? 0).toDouble(),
      overallGrade: json['overall_grade'] ?? json['overallGrade'] ?? '',
      totalMarks: json['total_marks'] ?? json['totalMarks'] ?? 0,
      obtainedMarks: json['obtained_marks'] ?? json['obtainedMarks'] ?? 0,
      remarks: json['remarks'] ?? '',
      teacherComments: json['teacher_comments'] ?? json['teacherComments'] ?? '',
      attendancePercentage: json['attendance_percentage'] ?? json['attendancePercentage'] ?? 0,
      presentDays: json['present_days'] ?? json['presentDays'] ?? 0,
      totalDays: json['total_days'] ?? json['totalDays'] ?? 0,
      status: json['status'] ?? 'published',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'academic_year': academicYear,
      'term': term,
      'grade': grade,
      'issue_date': issueDate.toIso8601String(),
      'subjects': subjects.map((s) => s.toJson()).toList(),
      'overall_percentage': overallPercentage,
      'overall_grade': overallGrade,
      'total_marks': totalMarks,
      'obtained_marks': obtainedMarks,
      'remarks': remarks,
      'teacher_comments': teacherComments,
      'attendance_percentage': attendancePercentage,
      'present_days': presentDays,
      'total_days': totalDays,
      'status': status,
    };
  }

  ReportCardModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? academicYear,
    String? term,
    String? grade,
    DateTime? issueDate,
    List<SubjectGrade>? subjects,
    double? overallPercentage,
    String? overallGrade,
    int? totalMarks,
    int? obtainedMarks,
    String? remarks,
    String? teacherComments,
    int? attendancePercentage,
    int? presentDays,
    int? totalDays,
    String? status,
  }) {
    return ReportCardModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      academicYear: academicYear ?? this.academicYear,
      term: term ?? this.term,
      grade: grade ?? this.grade,
      issueDate: issueDate ?? this.issueDate,
      subjects: subjects ?? this.subjects,
      overallPercentage: overallPercentage ?? this.overallPercentage,
      overallGrade: overallGrade ?? this.overallGrade,
      totalMarks: totalMarks ?? this.totalMarks,
      obtainedMarks: obtainedMarks ?? this.obtainedMarks,
      remarks: remarks ?? this.remarks,
      teacherComments: teacherComments ?? this.teacherComments,
      attendancePercentage: attendancePercentage ?? this.attendancePercentage,
      presentDays: presentDays ?? this.presentDays,
      totalDays: totalDays ?? this.totalDays,
      status: status ?? this.status,
    );
  }
}

class SubjectGrade {
  final String subjectId;
  final String subjectName;
  final int totalMarks;
  final int obtainedMarks;
  final double percentage;
  final String grade;
  final String remarks;

  SubjectGrade({
    required this.subjectId,
    required this.subjectName,
    required this.totalMarks,
    required this.obtainedMarks,
    required this.percentage,
    required this.grade,
    this.remarks = '',
  });

  factory SubjectGrade.fromJson(Map<String, dynamic> json) {
    return SubjectGrade(
      subjectId: json['subject_id'] ?? json['subjectId'] ?? '',
      subjectName: json['subject_name'] ?? json['subjectName'] ?? '',
      totalMarks: json['total_marks'] ?? json['totalMarks'] ?? 0,
      obtainedMarks: json['obtained_marks'] ?? json['obtainedMarks'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      grade: json['grade'] ?? '',
      remarks: json['remarks'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject_id': subjectId,
      'subject_name': subjectName,
      'total_marks': totalMarks,
      'obtained_marks': obtainedMarks,
      'percentage': percentage,
      'grade': grade,
      'remarks': remarks,
    };
  }
}