// lib/presentation/providers/attendance_provider.dart (FIXED)

import 'package:flutter/material.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/attendance_summary_model.dart';
import '../../data/repositories/attendance_repository.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceRepository _repository;

  AttendanceProvider() : _repository = AttendanceRepository();

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
      _attendanceRecords = await _repository.getStudentAttendance(
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
      _classAttendanceRecords = await _repository.getClassAttendance(
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
      final summaryMap = await _repository.getAttendanceSummary(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      );

      _attendanceSummary = AttendanceSummaryModel.fromJson(summaryMap);

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
        final summaryMap = await _repository.getAttendanceSummary(
          studentId: studentId,
          startDate: startDate,
          endDate: endDate,
        );

        _classSummaries[studentId] = AttendanceSummaryModel.fromJson(summaryMap);
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
    required String classId,
    required String status,
    required String markedBy,
    String? remarks,
    String? subject,
    String? period,
  }) async {
    _isSubmitting = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _repository.markAttendance(
        studentId: studentId,
        classId: classId,
        status: status,
        markedBy: markedBy,
        remarks: remarks,
        subject: subject,
        period: period,
      );

      if (result['success'] == true) {
        _successMessage = result['message'];
        print('✅ Attendance marked successfully');
        return true;
      } else {
        _error = result['message'];
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
      final result = await _repository.markBulkAttendance(
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
        _successMessage = result['message'];

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
        _error = result['message'];
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
      final result = await _repository.updateAttendance(
        attendanceId: attendanceId,
        status: newStatus,
        remarks: remarks,
      );

      if (result['success'] == true) {
        _successMessage = result['message'];

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
        _error = result['message'];
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
      return await _repository.getTodayAttendance(studentId);
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
      return await _repository.isAttendanceMarkedToday(
        classId: classId,
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
      return await _repository.calculateAttendancePercentage(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      );
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
      // Note: Repository method signature might not match - handle accordingly
      // If classId is required in repository, provide a default or skip call
      if (classId == null) {
        return {
          'total_students': 0,
          'present_today': 0,
          'absent_today': 0,
          'average_attendance': 0.0,
        };
      }

      return await _repository.getClassAttendanceStatistics(
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
      // If classId is null, return empty list since repository requires it
      if (classId == null) {
        return [];
      }

      return await _repository.getStudentsWithLowAttendance(
        classId: classId,
        threshold: threshold,
      );
    } catch (e) {
      print('❌ Error getting low attendance students: $e');
      return [];
    }
  }

  /// Get attendance trends (for charts)
  Future<Map<String, dynamic>> getAttendanceTrends({
    required String studentId,
    required int days,
  }) async {
    try {
      return await _repository.getAttendanceTrends(
        studentId: studentId,
        days: days,
      );
    } catch (e) {
      print('❌ Error getting attendance trends: $e');
      return {
        'success': false,
        'trends': {},
      };
    }
  }

  // ==================== HELPER METHODS ====================

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