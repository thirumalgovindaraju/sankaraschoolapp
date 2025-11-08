// lib/presentation/providers/academic_provider.dart
import 'package:flutter/material.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/attendance_summary_model.dart';
import '../../data/models/curriculum_model.dart';
import '../../data/models/grade_model.dart';
import '../../data/models/leave_request_model.dart';
import '../../data/models/report_card_model.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../data/services/academic_service.dart';
import '../../data/services/api_service.dart';
import '../../data/services/notification_service.dart';

class AcademicProvider extends ChangeNotifier {
  final AcademicService _academicService;
  final AttendanceRepository _attendanceRepository;

  AcademicProvider()
      : _academicService = AcademicService(
    ApiService(),
    NotificationService(ApiService()),
  ),
        _attendanceRepository = AttendanceRepository();

  // Attendance State
  List<AttendanceModel> _attendanceRecords = [];
  AttendanceSummaryModel? _attendanceSummary;
  bool _isLoadingAttendance = false;
  String? _attendanceError;

  // Curriculum State
  List<CurriculumModel> _curriculumList = [];
  bool _isLoadingCurriculum = false;
  String? _curriculumError;

  // Grades State
  List<GradeModel> _grades = [];
  bool _isLoadingGrades = false;
  String? _gradesError;

  // Leave Requests State
  List<LeaveRequestModel> _leaveRequests = [];
  bool _isLoadingLeaveRequests = false;
  String? _leaveRequestsError;

  // Report Card State
  ReportCardModel? _reportCard;
  bool _isLoadingReportCard = false;
  String? _reportCardError;

  // Getters
  List<AttendanceModel> get attendanceRecords => _attendanceRecords;
  AttendanceSummaryModel? get attendanceSummary => _attendanceSummary;
  bool get isLoadingAttendance => _isLoadingAttendance;
  String? get attendanceError => _attendanceError;

  List<CurriculumModel> get curriculumList => _curriculumList;
  bool get isLoadingCurriculum => _isLoadingCurriculum;
  String? get curriculumError => _curriculumError;

  List<GradeModel> get grades => _grades;
  bool get isLoadingGrades => _isLoadingGrades;
  String? get gradesError => _gradesError;

  List<LeaveRequestModel> get leaveRequests => _leaveRequests;
  bool get isLoadingLeaveRequests => _isLoadingLeaveRequests;
  String? get leaveRequestsError => _leaveRequestsError;

  ReportCardModel? get reportCard => _reportCard;
  bool get isLoadingReportCard => _isLoadingReportCard;
  String? get reportCardError => _reportCardError;

  // ATTENDANCE METHODS

  // Fetch student attendance
  Future<void> fetchStudentAttendance(
      String studentId, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    _isLoadingAttendance = true;
    _attendanceError = null;
    notifyListeners();

    try {
      _attendanceRecords = await _attendanceRepository.getStudentAttendance(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      );
      _attendanceError = null;
    } catch (e) {
      _attendanceError = e.toString();
      _attendanceRecords = [];
    } finally {
      _isLoadingAttendance = false;
      notifyListeners();
    }
  }

  // Fetch class attendance (for teachers)
  Future<void> fetchClassAttendance(String classId, DateTime date) async {
    _isLoadingAttendance = true;
    _attendanceError = null;
    notifyListeners();

    try {
      _attendanceRecords = await _attendanceRepository.getClassAttendance(
        classId: classId,
        date: date,
      );
      _attendanceError = null;
    } catch (e) {
      _attendanceError = e.toString();
      _attendanceRecords = [];
    } finally {
      _isLoadingAttendance = false;
      notifyListeners();
    }
  }

  // Fetch attendance summary
  Future<void> fetchAttendanceSummary(
      String studentId, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    try {
      final summaryData = await _attendanceRepository.getAttendanceSummary(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      );
      _attendanceSummary = AttendanceSummaryModel.fromJson(summaryData);
      notifyListeners();
    } catch (e) {
      _attendanceError = e.toString();
      notifyListeners();
    }
  }

  // Mark single attendance (for teachers)
  Future<bool> markAttendance({
    required String studentId,
    required String classId,
    required DateTime date,
    required String status,
    String? remarks,
    String? markedBy,
    String? subject,
    int? period,
  }) async {
    try {
      final result = await _academicService.markAttendance(
        studentId: studentId,
        classId: classId,
        status: status,
        markedBy: markedBy ?? '',
        remarks: remarks,
        subject: subject,
        period: period?.toString(),
      );

      if (result) {
        // Refresh attendance list
        await fetchClassAttendance(classId, date);
      }
      return result;
    } catch (e) {
      _attendanceError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Mark bulk attendance (for teachers)
  Future<bool> markBulkAttendance({
    required String classId,
    required String className,
    required String section,
    required DateTime date,
    required String markedBy,
    required String markedByName,
    required List<StudentAttendanceEntry> students,
    String? subject,
    String? period,
  }) async {
    _isLoadingAttendance = true;
    notifyListeners();

    try {
      final result = await _attendanceRepository.markBulkAttendance(
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

      final success = result['success'] == true;

      if (success) {
        // Refresh attendance list
        await fetchClassAttendance(classId, date);
      }
      return success;
    } catch (e) {
      _attendanceError = e.toString();
      return false;
    } finally {
      _isLoadingAttendance = false;
      notifyListeners();
    }
  }

  // Update attendance
  Future<bool> updateAttendance(
      String attendanceId,
      String newStatus,
      String? remarks,
      ) async {
    try {
      final result = await _academicService.updateAttendance(
        attendanceId: attendanceId,
        status: newStatus,
        remarks: remarks,
      );

      if (result) {
        // Update local list
        final index =
        _attendanceRecords.indexWhere((a) => a.id == attendanceId);
        if (index != -1) {
          final oldRecord = _attendanceRecords[index];
          _attendanceRecords[index] = oldRecord.copyWith(
            status: newStatus,
            remarks: remarks,
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        }
      }
      return result;
    } catch (e) {
      _attendanceError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get today's attendance
  Future<void> fetchTodayAttendance(String studentId) async {
    try {
      final attendance =
      await _attendanceRepository.getTodayAttendance(studentId);
      if (attendance != null) {
        _attendanceRecords = [attendance];
      } else {
        _attendanceRecords = [];
      }
      notifyListeners();
    } catch (e) {
      _attendanceError = e.toString();
      notifyListeners();
    }
  }

  // Calculate attendance percentage
  Future<double> getAttendancePercentage(
      String studentId, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    try {
      return await _attendanceRepository.calculateAttendancePercentage(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      return 0.0;
    }
  }

  // CURRICULUM METHODS

  // Fetch curriculum
  Future<void> fetchCurriculum({String? classId, String? subject}) async {
    _isLoadingCurriculum = true;
    _curriculumError = null;
    notifyListeners();

    try {
      final result = await _academicService.getCurriculum(
        classId: classId,
        subject: subject,
      );

      _curriculumList = result
          .map((json) => CurriculumModel.fromJson(json))
          .toList();
      _curriculumError = null;
    } catch (e) {
      _curriculumError = e.toString();
      _curriculumList = [];
    } finally {
      _isLoadingCurriculum = false;
      notifyListeners();
    }
  }

  // GRADES METHODS

  // Fetch grades
  Future<void> fetchGrades(
      String studentId, {
        String? term,
        String? subject,
      }) async {
    _isLoadingGrades = true;
    _gradesError = null;
    notifyListeners();

    try {
      _grades = await _academicService.fetchGrades(
        studentId: studentId,
        term: term,
      );
      _gradesError = null;
    } catch (e) {
      _gradesError = e.toString();
      _grades = [];
    } finally {
      _isLoadingGrades = false;
      notifyListeners();
    }
  }

  // LEAVE REQUEST METHODS

  // Fetch leave requests
  Future<void> fetchLeaveRequests(String studentId) async {
    _isLoadingLeaveRequests = true;
    _leaveRequestsError = null;
    notifyListeners();

    try {
      final result =
      await _academicService.getLeaveRequests(studentId: studentId);

      _leaveRequests = result
          .map((json) => LeaveRequestModel.fromJson(json))
          .toList();
      _leaveRequestsError = null;
    } catch (e) {
      _leaveRequestsError = e.toString();
      _leaveRequests = [];
    } finally {
      _isLoadingLeaveRequests = false;
      notifyListeners();
    }
  }

  // Submit leave request
  Future<bool> submitLeaveRequest({
    required String studentId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? attachmentUrl,
  }) async {
    _isLoadingLeaveRequests = true;
    notifyListeners();

    try {
      final result = await _academicService.submitLeaveRequest(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        attachmentUrl: attachmentUrl,
      );

      if (result) {
        await fetchLeaveRequests(studentId);
      }
      return result;
    } catch (e) {
      _leaveRequestsError = e.toString();
      return false;
    } finally {
      _isLoadingLeaveRequests = false;
      notifyListeners();
    }
  }

  // REPORT CARD METHODS

  // Fetch report card
  Future<void> fetchReportCard(
      String studentId, String academicYear, String term) async {
    _isLoadingReportCard = true;
    _reportCardError = null;
    notifyListeners();

    try {
      final result = await _academicService.getReportCard(
        studentId: studentId,
        academicYear: academicYear,
        term: term,
      );

      if (result != null) {
        _reportCard = ReportCardModel.fromJson(result);
        _reportCardError = null;
      } else {
        _reportCardError = 'Report card not found';
        _reportCard = null;
      }
    } catch (e) {
      _reportCardError = e.toString();
      _reportCard = null;
    } finally {
      _isLoadingReportCard = false;
      notifyListeners();
    }
  }

  // Clear all data
  void clearData() {
    _attendanceRecords = [];
    _attendanceSummary = null;
    _curriculumList = [];
    _grades = [];
    _leaveRequests = [];
    _reportCard = null;
    _attendanceError = null;
    _curriculumError = null;
    _gradesError = null;
    _leaveRequestsError = null;
    _reportCardError = null;
    notifyListeners();
  }
}