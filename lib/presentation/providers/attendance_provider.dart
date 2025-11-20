// lib/presentation/providers/attendance_provider.dart (FIXED)

import 'package:flutter/material.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/attendance_summary_model.dart';
import '../../data/services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _attendanceService;

  AttendanceProvider() : _attendanceService = AttendanceService();

  // State variables
  List<AttendanceModel> _attendanceRecords = [];
  List<AttendanceModel> _classAttendanceRecords = [];
  AttendanceSummaryModel? _attendanceSummary;
  Map<String, AttendanceSummaryModel> _classSummaries = {};

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  String? _successMessage;

  // Getters
  List<AttendanceModel> get attendanceRecords => _attendanceRecords;
  List<AttendanceModel> get classAttendanceRecords => _classAttendanceRecords;
  AttendanceSummaryModel? get attendanceSummary => _attendanceSummary;
  Map<String, AttendanceSummaryModel> get classSummaries => _classSummaries;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  String? get successMessage => _successMessage;

  // Clear messages
  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  // ==================== FETCH METHODS ====================

  /// Fetch student attendance records
  Future<void> fetchStudentAttendance({
    required String studentId,
    DateTime? startDate,
    DateTime? endDate,
    String? subject,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _attendanceRecords = await _attendanceService.getStudentAttendance(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
        subject: subject,
      );

      print('✅ Fetched ${_attendanceRecords.length} attendance records for student: $studentId');
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch attendance: ${e.toString()}';
      print('❌ Error fetching student attendance: $e');
      _attendanceRecords = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch class attendance for a specific date
  Future<void> fetchClassAttendance({
    required String classId,
    required DateTime date,
    String? subject,
    String? period,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _classAttendanceRecords = await _attendanceService.getClassAttendance(
        classId: classId,
        date: date,
        subject: subject,
        period: period,
      );

      print('✅ Fetched ${_classAttendanceRecords.length} attendance records for class: $classId');
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch class attendance: ${e.toString()}';
      print('❌ Error fetching class attendance: $e');
      _classAttendanceRecords = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch attendance summary for a student
  Future<void> fetchAttendanceSummary({
    required String studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _attendanceSummary = await _attendanceService.getAttendanceSummary(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      );

      print('✅ Fetched attendance summary for student: $studentId');
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch attendance summary: ${e.toString()}';
      print('❌ Error fetching attendance summary: $e');
      notifyListeners();
    }
  }

  /// Fetch attendance summaries for multiple students (for class view)
  Future<void> fetchClassAttendanceSummaries({
    required List<String> studentIds,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _classSummaries.clear();

      for (String studentId in studentIds) {
        final summary = await _attendanceService.getAttendanceSummary(
          studentId: studentId,
          startDate: startDate,
          endDate: endDate,
        );

        if (summary != null) {
          _classSummaries[studentId] = summary;
        }
      }

      print('✅ Fetched summaries for ${_classSummaries.length} students');
    } catch (e) {
      _error = 'Failed to fetch class summaries: ${e.toString()}';
      print('❌ Error fetching class summaries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== MARK ATTENDANCE METHODS ====================

  /// Mark single student attendance
  Future<bool> markSingleAttendance({
    required String studentId,
    required String studentName,
    required String rollNumber,
    required String classId,
    required String className,
    required String section,
    required DateTime date,
    required String status,
    required String markedBy,
    required String markedByName,
    String? remarks,
    String? subject,
    int? period,
  }) async {
    _isSubmitting = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _attendanceService.markSingleAttendance(
        studentId: studentId,
        studentName: studentName,
        rollNumber: rollNumber,
        classId: classId,
        className: className,
        section: section,
        date: date,
        status: status,
        markedBy: markedBy,
        markedByName: markedByName,
        remarks: remarks,
        subject: subject,
        period: period,
      );

      if (result) {
        _successMessage = 'Attendance marked successfully for $studentName';

        // Refresh attendance records
        await fetchClassAttendance(
          classId: classId,
          date: date,
          subject: subject,
          period: period?.toString(),
        );

        print('✅ Attendance marked successfully for $studentName');
        return true;
      } else {
        _error = 'Failed to mark attendance';
        print('❌ Failed to mark attendance');
        return false;
      }
    } catch (e) {
      _error = 'Error marking attendance: ${e.toString()}';
      print('❌ Error marking attendance: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Mark bulk attendance for entire class
  Future<bool> markBulkAttendance({
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
    _isSubmitting = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _attendanceService.markBulkAttendance(
        classId: classId,
        className: className,
        section: section,
        date: date,
        students: students,
        markedBy: markedBy,
        markedByName: markedByName,
        subject: subject,
        period: period,
      );

      if (result['success'] == true) {
        _successMessage = result['message'] ?? 'Bulk attendance marked successfully';

        // Refresh attendance records
        await fetchClassAttendance(
          classId: classId,
          date: date,
          subject: subject,
          period: period,
        );

        print('✅ Bulk attendance marked successfully for ${students.length} students');
        return true;
      } else {
        _error = result['message'] ?? 'Failed to mark bulk attendance';
        print('❌ Failed to mark bulk attendance');
        return false;
      }
    } catch (e) {
      _error = 'Error marking bulk attendance: ${e.toString()}';
      print('❌ Error marking bulk attendance: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Update existing attendance record
  Future<bool> updateAttendance({
    required String attendanceId,
    required String newStatus,
    String? remarks,
  }) async {
    _isSubmitting = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _attendanceService.updateAttendance(
        attendanceId: attendanceId,
        status: newStatus,
        remarks: remarks,
      );

      if (result) {
        _successMessage = 'Attendance updated successfully';

        // Update local record
        final index = _attendanceRecords.indexWhere((a) => a.id == attendanceId);
        if (index != -1) {
          _attendanceRecords[index] = _attendanceRecords[index].copyWith(
            status: newStatus,
            remarks: remarks,
            updatedAt: DateTime.now(),
          );
        }

        final classIndex = _classAttendanceRecords.indexWhere((a) => a.id == attendanceId);
        if (classIndex != -1) {
          _classAttendanceRecords[classIndex] = _classAttendanceRecords[classIndex].copyWith(
            status: newStatus,
            remarks: remarks,
            updatedAt: DateTime.now(),
          );
        }

        print('✅ Attendance updated successfully');
        return true;
      } else {
        _error = 'Failed to update attendance';
        print('❌ Failed to update attendance');
        return false;
      }
    } catch (e) {
      _error = 'Error updating attendance: ${e.toString()}';
      print('❌ Error updating attendance: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Get today's attendance for a student
  Future<AttendanceModel?> getTodayAttendance(String studentId) async {
    try {
      return await _attendanceService.getTodayAttendance(studentId);
    } catch (e) {
      print('❌ Error getting today\'s attendance: $e');
      return null;
    }
  }

  /// Check if attendance is already marked for a class on a specific date
  Future<bool> isAttendanceMarked({
    required String classId,
    required DateTime date,
    String? subject,
    String? period,
  }) async {
    try {
      return await _attendanceService.isAttendanceMarkedForClass(
        classId: classId,
        date: date,
        subject: subject,
        period: period,
      );
    } catch (e) {
      print('❌ Error checking attendance: $e');
      return false;
    }
  }

  /// Calculate attendance percentage for a student
  Future<double> calculateAttendancePercentage({
    required String studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final summary = await _attendanceService.getAttendanceSummary(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      );

      return summary?.attendancePercentage ?? 0.0;
    } catch (e) {
      print('❌ Error calculating attendance percentage: $e');
      return 0.0;
    }
  }

  /// Get attendance statistics for admin dashboard
  Future<Map<String, dynamic>> getAttendanceStatistics({
    String? classId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _attendanceService.getAttendanceStatistics(
        classId: classId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      print('❌ Error getting attendance statistics: $e');
      return {
        'total_students': 0,
        'present_today': 0,
        'absent_today': 0,
        'average_attendance': 0.0,
      };
    }
  }

  /// Get students with low attendance (below threshold)
  Future<List<Map<String, dynamic>>> getStudentsWithLowAttendance({
    String? classId,
    double threshold = 75.0,
  }) async {
    try {
      return await _attendanceService.getStudentsWithLowAttendance(
        classId: classId,
        threshold: threshold,
      );
    } catch (e) {
      print('❌ Error getting low attendance students: $e');
      return [];
    }
  }

  // ==================== HELPER METHODS ====================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Clear all data
  void clearData() {
    _attendanceRecords = [];
    _classAttendanceRecords = [];
    _attendanceSummary = null;
    _classSummaries.clear();
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Refresh all attendance data for a student
  Future<void> refreshStudentAttendance(String studentId) async {
    await Future.wait([
      fetchStudentAttendance(studentId: studentId),
      fetchAttendanceSummary(studentId: studentId),
    ]);
  }

  /// Refresh all attendance data for a class
  Future<void> refreshClassAttendance({
    required String classId,
    required DateTime date,
  }) async {
    await fetchClassAttendance(classId: classId, date: date);
  }
}