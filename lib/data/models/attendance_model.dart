// lib/data/models/attendance_model.dart

class AttendanceModel {
  final String id;
  final String studentId;
  final String studentName;
  final String rollNumber; // Changed from studentRollNumber
  final String classId;
  final String className;
  final String section;
  final DateTime date;
  final String status; // 'present', 'absent', 'late', 'excused'
  final String? remarks;
  final String markedBy; // Teacher ID
  final String markedByName; // Teacher name
  final DateTime markedAt;
  final DateTime? updatedAt;
  final String? subject; // Subject for which attendance is marked
  final int? period; // Changed from String? to int?
  final String? leaveRequestId; // If linked to leave request
  final bool parentNotified; // Changed from isNotified
  final Map<String, dynamic>? metadata;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.classId,
    required this.className,
    required this.section,
    required this.date,
    required this.status,
    this.remarks,
    required this.markedBy,
    required this.markedByName,
    required this.markedAt,
    this.updatedAt,
    this.subject,
    this.period,
    this.leaveRequestId,
    this.parentNotified = false,
    this.metadata,
  });

  // From JSON
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? '',
      studentId: json['student_id'] ?? '',
      studentName: json['student_name'] ?? '',
      rollNumber: json['roll_number'] ?? json['student_roll_number'] ?? '',
      classId: json['class_id'] ?? '',
      className: json['class_name'] ?? '',
      section: json['section'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      status: json['status'] ?? 'present',
      remarks: json['remarks'],
      markedBy: json['marked_by'] ?? '',
      markedByName: json['marked_by_name'] ?? '',
      markedAt: json['marked_at'] != null
          ? DateTime.parse(json['marked_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      subject: json['subject'],
      period: json['period'] is int ? json['period'] : (json['period'] != null ? int.tryParse(json['period'].toString()) : null),
      leaveRequestId: json['leave_request_id'],
      parentNotified: json['parent_notified'] ?? json['is_notified'] ?? false,
      metadata: json['metadata'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'roll_number': rollNumber,
      'class_id': classId,
      'class_name': className,
      'section': section,
      'date': date.toIso8601String(),
      'status': status,
      'remarks': remarks,
      'marked_by': markedBy,
      'marked_by_name': markedByName,
      'marked_at': markedAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'subject': subject,
      'period': period,
      'leave_request_id': leaveRequestId,
      'parent_notified': parentNotified,
      'metadata': metadata,
    };
  }

  // Copy with
  AttendanceModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? rollNumber,
    String? classId,
    String? className,
    String? section,
    DateTime? date,
    String? status,
    String? remarks,
    String? markedBy,
    String? markedByName,
    DateTime? markedAt,
    DateTime? updatedAt,
    String? subject,
    int? period,
    String? leaveRequestId,
    bool? parentNotified,
    Map<String, dynamic>? metadata,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      rollNumber: rollNumber ?? this.rollNumber,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      section: section ?? this.section,
      date: date ?? this.date,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      markedBy: markedBy ?? this.markedBy,
      markedByName: markedByName ?? this.markedByName,
      markedAt: markedAt ?? this.markedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subject: subject ?? this.subject,
      period: period ?? this.period,
      leaveRequestId: leaveRequestId ?? this.leaveRequestId,
      parentNotified: parentNotified ?? this.parentNotified,
      metadata: metadata ?? this.metadata,
    );
  }

  // Get status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'present':
        return '#4CAF50'; // Green
      case 'absent':
        return '#F44336'; // Red
      case 'late':
        return '#FF9800'; // Orange
      case 'excused':
        return '#2196F3'; // Blue
      default:
        return '#9E9E9E'; // Grey
    }
  }

  // Get status icon
  String get statusIcon {
    switch (status.toLowerCase()) {
      case 'present':
        return '✓';
      case 'absent':
        return '✗';
      case 'late':
        return '⏰';
      case 'excused':
        return '📝';
      default:
        return '?';
    }
  }

  // Check if attendance is marked today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Get formatted date
  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// Bulk Attendance Entry Model (for teachers marking multiple students)
class BulkAttendanceEntry {
  final String classId;
  final String className;
  final String section;
  final DateTime date;
  final String? subject;
  final String? period;
  final List<StudentAttendanceEntry> students;
  final String markedBy;
  final String markedByName;

  BulkAttendanceEntry({
    required this.classId,
    required this.className,
    required this.section,
    required this.date,
    this.subject,
    this.period,
    required this.students,
    required this.markedBy,
    required this.markedByName,
  });

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'class_name': className,
      'section': section,
      'date': date.toIso8601String(),
      'subject': subject,
      'period': period,
      'students': students.map((s) => s.toJson()).toList(),
      'marked_by': markedBy,
      'marked_by_name': markedByName,
    };
  }
}

// Individual student attendance entry
class StudentAttendanceEntry {
  final String studentId;
  final String studentName;
  final String rollNumber;
  final String status;
  final String? remarks;

  StudentAttendanceEntry({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.status,
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'roll_number': rollNumber,
      'status': status,
      'remarks': remarks,
    };
  }
}