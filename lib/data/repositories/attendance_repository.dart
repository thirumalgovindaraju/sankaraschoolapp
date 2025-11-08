// lib/data/repositories/attendance_repository.dart

import '../models/attendance_model.dart';
import '../models/attendance_summary_model.dart';
import '../services/academic_service.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class AttendanceRepository {
  final AcademicService _academicService;

  AttendanceRepository({AcademicService? academicService})
      : _academicService = academicService ??
      AcademicService(ApiService(), NotificationService(ApiService()));

  // Mark single attendance
  Future<Map<String, dynamic>> markAttendance({
    required String studentId,
    required String classId,
    required String status,
    required String markedBy,
    String? remarks,
    String? subject,
    String? period,
  }) async {
    try {
      final result = await _academicService.markAttendance(
        studentId: studentId,
        classId: classId,
        status: status,
        markedBy: markedBy,
        remarks: remarks,
        subject: subject,
        period: period,
      );

      return {
        'success': result,
        'message': result ? 'Attendance marked successfully' : 'Failed to mark attendance',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Repository Error: ${e.toString()}',
      };
    }
  }

  // Mark bulk attendance (for entire class)
  Future<Map<String, dynamic>> markBulkAttendance({
    required String classId,
    required String className,
    required String section,
    required DateTime date,
    required List<StudentAttendanceEntry> students,
    required String markedBy,
    required String markedByName,
    String? subject,
    String? period,
  }) async {
    try {
      final bulkEntry = BulkAttendanceEntry(
        classId: classId,
        className: className,
        section: section,
        date: date,
        subject: subject,
        period: period,
        students: students,
        markedBy: markedBy,
        markedByName: markedByName,
      );

      final result = await _academicService.markBulkAttendance(bulkEntry);

      return {
        'success': result,
        'message': result ? 'Bulk attendance marked successfully' : 'Failed to mark bulk attendance',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Repository Error: ${e.toString()}',
      };
    }
  }

  // Get student attendance
  Future<List<AttendanceModel>> getStudentAttendance({
    required String studentId,
    DateTime? startDate,
    DateTime? endDate,
    String? subject,
  }) async {
    try {
      return await _academicService.fetchAttendanceRecords(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
        subject: subject,
      );
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return [];
    }
  }

  // Get class attendance
  Future<List<AttendanceModel>> getClassAttendance({
    required String classId,
    required DateTime date,
    String? subject,
    String? period,
  }) async {
    try {
      // Extract section from classId (assuming format like "10-A")
      final parts = classId.split('-');
      final className = parts.isNotEmpty ? parts[0] : classId;
      final section = parts.length > 1 ? parts[1] : 'A';

      return await _academicService.fetchClassAttendance(
        classId: classId,
        section: section,
        date: date,
        subject: subject,
        period: period,
      );
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return [];
    }
  }

  // Get attendance summary
  Future<Map<String, dynamic>> getAttendanceSummary({
    required String studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final summary = await _academicService.fetchAttendanceSummary(studentId);

      if (summary != null) {
        return summary.toJson();
      }

      return {
        'total_days': 0,
        'present': 0,
        'absent': 0,
        'late': 0,
        'excused': 0,
        'percentage': 0.0,
      };
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return {
        'total_days': 0,
        'present': 0,
        'absent': 0,
        'late': 0,
        'excused': 0,
        'percentage': 0.0,
      };
    }
  }

  // Update attendance
  Future<Map<String, dynamic>> updateAttendance({
    required String attendanceId,
    String? status,
    String? remarks,
  }) async {
    try {
      final result = await _academicService.updateAttendance(
        attendanceId: attendanceId,
        status: status,
        remarks: remarks,
      );

      return {
        'success': result,
        'message': result ? 'Attendance updated successfully' : 'Failed to update attendance',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Repository Error: ${e.toString()}',
      };
    }
  }

  // Get today's attendance for student
  Future<AttendanceModel?> getTodayAttendance(String studentId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final attendance = await getStudentAttendance(
        studentId: studentId,
        startDate: startOfDay,
        endDate: endOfDay,
      );

      return attendance.isNotEmpty ? attendance.first : null;
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return null;
    }
  }

  // Get attendance for current week
  Future<List<AttendanceModel>> getWeeklyAttendance(String studentId) async {
    try {
      final today = DateTime.now();
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      return await getStudentAttendance(
        studentId: studentId,
        startDate: startOfWeek,
        endDate: endOfWeek,
      );
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return [];
    }
  }

  // Get attendance for current month
  Future<List<AttendanceModel>> getMonthlyAttendance(String studentId) async {
    try {
      final today = DateTime.now();
      final startOfMonth = DateTime(today.year, today.month, 1);
      final endOfMonth = DateTime(today.year, today.month + 1, 0);

      return await getStudentAttendance(
        studentId: studentId,
        startDate: startOfMonth,
        endDate: endOfMonth,
      );
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return [];
    }
  }

  // Get absent days for student
  Future<List<AttendanceModel>> getAbsentDays({
    required String studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final attendance = await getStudentAttendance(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      );

      return attendance
          .where((record) => record.status.toLowerCase() == 'absent')
          .toList();
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return [];
    }
  }

  // Calculate attendance percentage
  Future<double> calculateAttendancePercentage({
    required String studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final summary = await getAttendanceSummary(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      );

      if (summary['percentage'] != null) {
        return (summary['percentage'] as num).toDouble();
      }

      final totalDays = summary['total_days'] ?? 0;
      final present = summary['present'] ?? 0;

      if (totalDays == 0) return 0.0;

      return (present / totalDays) * 100;
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return 0.0;
    }
  }

  // Check if attendance is marked for today
  Future<bool> isAttendanceMarkedToday({
    required String classId,
    String? subject,
    String? period,
  }) async {
    try {
      final today = DateTime.now();
      final attendance = await getClassAttendance(
        classId: classId,
        date: today,
        subject: subject,
        period: period,
      );

      return attendance.isNotEmpty;
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return false;
    }
  }

  // Get late arrivals
  Future<List<AttendanceModel>> getLateArrivals({
    required String classId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final today = DateTime.now();
      final attendance = await getClassAttendance(
        classId: classId,
        date: today,
      );

      return attendance
          .where((record) => record.status.toLowerCase() == 'late')
          .toList();
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return [];
    }
  }

  // Get attendance statistics for class
  Future<Map<String, dynamic>> getClassAttendanceStatistics({
    required String classId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // This would ideally come from a specific API endpoint
      // For now, we'll return a placeholder structure
      return {
        'total_students': 0,
        'present_today': 0,
        'absent_today': 0,
        'late_today': 0,
        'average_attendance': 0.0,
      };
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return {
        'total_students': 0,
        'present_today': 0,
        'absent_today': 0,
        'late_today': 0,
        'average_attendance': 0.0,
      };
    }
  }

  // Get students with low attendance
  Future<List<Map<String, dynamic>>> getStudentsWithLowAttendance({
    required String classId,
    double threshold = 75.0,
  }) async {
    try {
      // This would ideally come from a specific API endpoint
      // For now, we'll return an empty list
      return [];
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return [];
    }
  }

  // Get attendance trends (for charts)
  Future<Map<String, dynamic>> getAttendanceTrends({
    required String studentId,
    required int days,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final attendance = await getStudentAttendance(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      );

      // Group by date
      final trendData = <String, Map<String, int>>{};

      for (var record in attendance) {
        final dateKey = record.formattedDate;
        trendData[dateKey] = trendData[dateKey] ?? {
          'present': 0,
          'absent': 0,
          'late': 0,
          'excused': 0,
        };

        final status = record.status.toLowerCase();
        if (trendData[dateKey]!.containsKey(status)) {
          trendData[dateKey]![status] = (trendData[dateKey]![status] ?? 0) + 1;
        }
      }

      return {
        'success': true,
        'trends': trendData,
      };
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return {
        'success': false,
        'trends': {},
      };
    }
  }
}