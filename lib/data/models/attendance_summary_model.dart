// lib/data/models/attendance_summary_model.dart

class AttendanceSummaryModel {
  final String studentId;
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int sickDays;
  final int excusedDays;
  final double attendancePercentage;

  AttendanceSummaryModel({
    required this.studentId,
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.sickDays,
    required this.excusedDays,
    required this.attendancePercentage,
  });

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryModel(
      studentId: json['student_id']?.toString() ?? '',
      totalDays: json['total_days'] ?? 0,
      presentDays: json['present_days'] ?? 0,
      absentDays: json['absent_days'] ?? 0,
      lateDays: json['late_days'] ?? 0,
      sickDays: json['sick_days'] ?? 0,
      excusedDays: json['excused_days'] ?? 0,
      attendancePercentage: (json['attendance_percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'total_days': totalDays,
      'present_days': presentDays,
      'absent_days': absentDays,
      'late_days': lateDays,
      'sick_days': sickDays,
      'excused_days': excusedDays,
      'attendance_percentage': attendancePercentage,
    };
  }
}