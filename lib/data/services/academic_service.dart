// lib/data/services/academic_service.dart

import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/attendance_model.dart';
import '../models/attendance_summary_model.dart';
import '../models/grade_model.dart';
import 'api_service.dart';
import 'notification_service.dart';
import 'test_data_service.dart';

class AcademicService {
  final ApiService _apiService;
  final NotificationService _notificationService;
  static const bool _useTestData = true; // Toggle for production

  AcademicService(this._apiService, this._notificationService);

  // ============================================================================
  // ATTENDANCE - RETRIEVAL METHODS
  // ============================================================================

  /// Fetch attendance summary for a student
  Future<AttendanceSummaryModel?> fetchAttendanceSummary(String studentId) async {
    try {
      if (_useTestData) {
        await TestDataService.instance.loadTestData();
        return TestDataService.instance.generateAttendanceSummary(studentId);
      }

      final response = await _apiService.get(
        '/academic/attendance/summary/$studentId',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AttendanceSummaryModel.fromJson(data['data'] ?? data);
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching attendance summary: $e');
      return null;
    }
  }

  /// Fetch attendance records for a student
  Future<List<AttendanceModel>> fetchAttendanceRecords({
    required String studentId,
    DateTime? startDate,
    DateTime? endDate,
    String? subject,
  }) async {
    try {
      if (_useTestData) {
        await TestDataService.instance.loadTestData();
        final records = TestDataService.instance.getAttendanceRecords();
        final studentRecords = records
            .where((r) => r['student_id'] == studentId)
            .map((r) => AttendanceModel.fromJson(r))
            .toList();

        if (studentRecords.isEmpty) {
          return _generateMockAttendance(studentId);
        }

        return studentRecords;
      }

      final queryParams = {
        'student_id': studentId,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        if (subject != null) 'subject': subject,
      };

      final response = await _apiService.get(
        '/academic/attendance/records',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final recordsList = data['data'] ?? data['attendance'] ?? [];
        return (recordsList as List)
            .map((json) => AttendanceModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching attendance records: $e');
      return [];
    }
  }

  /// Fetch attendance for a class (for teachers)
  Future<List<AttendanceModel>> fetchClassAttendance({
    required String classId,
    required String section,
    required DateTime date,
    String? subject,
    String? period,
  }) async {
    try {
      if (_useTestData) {
        await TestDataService.instance.loadTestData();
        final className = classId.replaceAll('-', '');
        final students = TestDataService.instance.getStudentsByClass(className, section);

        return students.map((student) {
          return AttendanceModel(
            id: 'ATT_${student['student_id']}_${date.toIso8601String()}',
            studentId: student['student_id'],
            studentName: student['name'],
            rollNumber: student['roll_number'].toString(),
            classId: classId,
            className: student['class'],
            section: student['section'],
            date: date,
            status: 'present',
            markedBy: 'T001',
            markedByName: 'Teacher',
            markedAt: DateTime.now(),
          );
        }).toList();
      }

      final queryParams = {
        'class_id': classId,
        'section': section,
        'date': date.toIso8601String(),
        if (subject != null) 'subject': subject,
        if (period != null) 'period': period,
      };

      final response = await _apiService.get(
        '/academic/attendance/class',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final recordsList = data['data'] ?? data['attendance'] ?? [];
        return (recordsList as List)
            .map((json) => AttendanceModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching class attendance: $e');
      return [];
    }
  }

  // ============================================================================
  // ATTENDANCE - MARKING METHODS
  // ============================================================================

  /// Mark attendance for a single student
  Future<bool> markAttendance({
    required String studentId,
    required String classId,
    required String status,
    required String markedBy,
    String? remarks,
    String? subject,
    String? period,
  }) async {
    try {
      if (_useTestData) {
        await Future.delayed(const Duration(seconds: 1));
        debugPrint('✅ Attendance marked (test mode)');
        return true;
      }

      final response = await _apiService.post(
        '/academic/attendance',
        {
          'student_id': studentId,
          'class_id': classId,
          'date': DateTime.now().toIso8601String(),
          'status': status,
          'marked_by': markedBy,
          if (remarks != null) 'remarks': remarks,
          if (subject != null) 'subject': subject,
          if (period != null) 'period': period,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        // Send notification to student and parents
        if (data['student_name'] != null && data['parent_ids'] != null) {
          await _notificationService.sendAttendanceNotification(
            studentId: studentId,
            parentIds: List<String>.from(data['parent_ids']),
            studentName: data['student_name'],
            status: status,
            date: DateTime.now().toString().split(' ')[0],
            markedBy: markedBy,
          );
        }

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error marking attendance: $e');
      return false;
    }
  }

  /// Mark bulk attendance (for teachers marking entire class)
  Future<bool> markBulkAttendance(BulkAttendanceEntry bulkEntry) async {
    try {
      if (_useTestData) {
        await Future.delayed(const Duration(seconds: 1));
        debugPrint('✅ Bulk attendance marked (test mode)');
        return true;
      }

      final response = await _apiService.post(
        '/academic/attendance/bulk',
        bulkEntry.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        // Send notifications to students and parents
        if (data['notifications'] != null) {
          final notificationData = data['notifications'] as List;
          for (var notification in notificationData) {
            await _notificationService.sendAttendanceNotification(
              studentId: notification['student_id'],
              parentIds: List<String>.from(notification['parent_ids'] ?? []),
              studentName: notification['student_name'],
              status: notification['status'],
              date: bulkEntry.date.toString().split(' ')[0],
              markedBy: bulkEntry.markedBy,
            );
          }
        }

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error marking bulk attendance: $e');
      return false;
    }
  }

  /// Update attendance
  Future<bool> updateAttendance({
    required String attendanceId,
    String? status,
    String? remarks,
  }) async {
    try {
      if (_useTestData) {
        await Future.delayed(const Duration(milliseconds: 500));
        debugPrint('✅ Attendance updated (test mode)');
        return true;
      }

      final response = await _apiService.put(
        '/academic/attendance/$attendanceId',
        {
          if (status != null) 'status': status,
          if (remarks != null) 'remarks': remarks,
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error updating attendance: $e');
      return false;
    }
  }

  // ============================================================================
  // GRADES METHODS
  // ============================================================================

  /// Fetch grades for a student
  Future<List<GradeModel>> fetchGrades({
    required String studentId,
    String? academicYear,
    String? term,
  }) async {
    try {
      if (_useTestData) {
        return _generateMockGrades(studentId);
      }

      final queryParams = {
        'student_id': studentId,
        if (academicYear != null) 'academic_year': academicYear,
        if (term != null) 'term': term,
      };

      final response = await _apiService.get(
        '/academic/grades',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final gradesList = data['data'] ?? data['grades'] ?? [];
        return (gradesList as List)
            .map((json) => GradeModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching grades: $e');
      return [];
    }
  }

  /// Submit grades (for teachers)
  Future<bool> submitGrades({
    required String studentId,
    required String subjectId,
    required String examType,
    required double marks,
    required double maxMarks,
    String? remarks,
  }) async {
    try {
      if (_useTestData) {
        await Future.delayed(const Duration(seconds: 1));
        debugPrint('✅ Grades submitted (test mode)');
        return true;
      }

      final response = await _apiService.post(
        '/academic/grades/submit',
        {
          'student_id': studentId,
          'subject_id': subjectId,
          'exam_type': examType,
          'marks': marks,
          'max_marks': maxMarks,
          if (remarks != null) 'remarks': remarks,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Send notification about grade update
        final data = json.decode(response.body);
        if (data['student_name'] != null && data['parent_ids'] != null) {
          final grade = _calculateGrade(marks, maxMarks);
          await _notificationService.sendGradeNotification(
            studentId: studentId,
            parentIds: List<String>.from(data['parent_ids']),
            studentName: data['student_name'],
            subject: data['subject_name'] ?? 'Subject',
            grade: grade,
            teacherId: data['teacher_id'] ?? '',
          );
        }

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error submitting grades: $e');
      return false;
    }
  }

  // ============================================================================
  // CURRICULUM METHODS
  // ============================================================================

  /// Get curriculum for class
  Future<List<Map<String, dynamic>>> getCurriculum({
    String? classId,
    String? subject,
  }) async {
    try {
      if (_useTestData) {
        return _generateMockCurriculum(classId, subject);
      }

      final queryParams = {
        if (classId != null) 'class_id': classId,
        if (subject != null) 'subject': subject,
      };

      final response = await _apiService.get(
        '/academic/curriculum',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? data['curriculum'] ?? []);
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching curriculum: $e');
      return [];
    }
  }

  // ============================================================================
  // LEAVE REQUEST METHODS
  // ============================================================================

  /// Submit leave request
  Future<bool> submitLeaveRequest({
    required String studentId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? attachmentUrl,
  }) async {
    try {
      if (_useTestData) {
        await Future.delayed(const Duration(seconds: 1));
        debugPrint('✅ Leave request submitted (test mode)');
        return true;
      }

      final response = await _apiService.post(
        '/academic/leave-requests',
        {
          'student_id': studentId,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'reason': reason,
          if (attachmentUrl != null) 'attachment_url': attachmentUrl,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error submitting leave request: $e');
      return false;
    }
  }

  /// Get leave requests
  Future<List<Map<String, dynamic>>> getLeaveRequests({
    String? studentId,
    String? status,
  }) async {
    try {
      if (_useTestData) {
        return _generateMockLeaveRequests(studentId);
      }

      final queryParams = {
        if (studentId != null) 'student_id': studentId,
        if (status != null) 'status': status,
      };

      final response = await _apiService.get(
        '/academic/leave-requests',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? data['leave_requests'] ?? []);
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching leave requests: $e');
      return [];
    }
  }

  /// Approve/reject leave request (for teachers/admin)
  Future<bool> updateLeaveRequestStatus({
    required String requestId,
    required String status,
    String? remarks,
  }) async {
    try {
      if (_useTestData) {
        await Future.delayed(const Duration(milliseconds: 500));
        debugPrint('✅ Leave request updated (test mode)');
        return true;
      }

      final response = await _apiService.put(
        '/academic/leave-requests/$requestId',
        {
          'status': status,
          if (remarks != null) 'remarks': remarks,
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error updating leave request: $e');
      return false;
    }
  }

  // ============================================================================
  // REPORT CARD METHODS
  // ============================================================================

  /// Get report card
  Future<Map<String, dynamic>?> getReportCard({
    required String studentId,
    required String academicYear,
    required String term,
  }) async {
    try {
      if (_useTestData) {
        return _generateMockReportCard(studentId, academicYear, term);
      }

      final response = await _apiService.get(
        '/academic/report-card?student_id=$studentId&academic_year=$academicYear&term=$term',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? data;
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching report card: $e');
      return null;
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get students list for a class (for teachers)
  Future<List<Map<String, dynamic>>> getClassStudents({
    required String className,
    required String section,
  }) async {
    try {
      if (_useTestData) {
        await TestDataService.instance.loadTestData();
        return TestDataService.instance.getStudentsByClass(className, section);
      }

      final response = await _apiService.get(
        '/academic/students',
        queryParameters: {
          'class': className,
          'section': section,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching class students: $e');
      return [];
    }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  List<AttendanceModel> _generateMockAttendance(String studentId) {
    final List<AttendanceModel> records = [];
    final now = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      if (date.weekday != DateTime.saturday && date.weekday != DateTime.sunday) {
        records.add(AttendanceModel(
          id: 'ATT_${studentId}_${date.toIso8601String()}',
          studentId: studentId,
          studentName: 'Student',
          rollNumber: '1',
          classId: '10-A',
          className: '10th',
          section: 'A',
          date: date,
          status: i % 10 == 0 ? 'absent' : 'present',
          markedBy: 'T001',
          markedByName: 'Teacher',
          markedAt: date,
        ));
      }
    }

    return records;
  }

  List<GradeModel> _generateMockGrades(String studentId) {
    final subjects = [
      {'id': 'SUB001', 'name': 'Mathematics'},
      {'id': 'SUB002', 'name': 'Science'},
      {'id': 'SUB003', 'name': 'English'},
      {'id': 'SUB004', 'name': 'Social Studies'},
      {'id': 'SUB005', 'name': 'Hindi'},
    ];

    return subjects.map((subject) {
      return GradeModel(
        id: 'GRD_${studentId}_${subject['id']}',
        studentId: studentId,
        subjectId: subject['id']!,
        subjectName: subject['name']!,
        examType: 'midterm',
        marks: 75 + (subject['id']!.hashCode % 20).toDouble(),
        maxMarks: 100,
        grade: 'A',
        examDate: DateTime.now().subtract(const Duration(days: 30)),
      );
    }).toList();
  }

  List<Map<String, dynamic>> _generateMockCurriculum(String? classId, String? subject) {
    return [
      {
        'id': 'CUR001',
        'class_id': classId ?? '10-A',
        'subject': subject ?? 'Mathematics',
        'topic': 'Algebra',
        'description': 'Linear equations and inequalities',
        'duration': '2 weeks',
      },
      {
        'id': 'CUR002',
        'class_id': classId ?? '10-A',
        'subject': subject ?? 'Mathematics',
        'topic': 'Geometry',
        'description': 'Triangles and circles',
        'duration': '3 weeks',
      },
    ];
  }

  List<Map<String, dynamic>> _generateMockLeaveRequests(String? studentId) {
    return [
      {
        'id': 'LR001',
        'student_id': studentId ?? 'S001',
        'start_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'end_date': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'reason': 'Family function',
        'status': 'pending',
        'submitted_at': DateTime.now().toIso8601String(),
      }
    ];
  }

  Map<String, dynamic> _generateMockReportCard(
      String studentId,
      String academicYear,
      String term,
      ) {
    return {
      'student_id': studentId,
      'academic_year': academicYear,
      'term': term,
      'grades': _generateMockGrades(studentId).map((g) => g.toJson()).toList(),
      'attendance_percentage': 92.5,
      'overall_grade': 'A',
      'rank': 5,
      'remarks': 'Excellent performance',
    };
  }

  String _calculateGrade(double marks, double maxMarks) {
    final percentage = (marks / maxMarks) * 100;
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C';
    if (percentage >= 40) return 'D';
    return 'F';
  }
}