// lib/presentation/providers/admin_provider.dart

import 'package:flutter/foundation.dart';
import '../../data/services/admin_service.dart';
import '../../data/services/api_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService(ApiService());

  // Students
  List<Map<String, dynamic>> _students = [];
  // Teachers
  List<Map<String, dynamic>> _teachers = [];
  // Statistics
  Map<String, dynamic> _statistics = {};

  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get students => _students;
  List<Map<String, dynamic>> get teachers => _teachers;
  Map<String, dynamic> get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ============================================================================
  // LOAD ALL DATA
  // ============================================================================

  Future<void> loadAllUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadStudents(),
        _loadTeachers(),
        _loadStatistics(),
      ]);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // STUDENT MANAGEMENT
  // ============================================================================

  Future<void> _loadStudents() async {
    try {
      _students = await _adminService.getAllStudents();
    } catch (e) {
      debugPrint('Error loading students: $e');
      throw e;
    }
  }

  Future<bool> addStudent(Map<String, dynamic> studentData) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _adminService.addStudent(studentData);
      if (success) {
        await _loadStudents();
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStudent(String studentId, Map<String, dynamic> studentData) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _adminService.updateStudent(studentId, studentData);
      if (success) {
        await _loadStudents();
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteStudent(String studentId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _adminService.deleteStudent(studentId);
      if (success) {
        await _loadStudents();
        await _loadStatistics(); // Refresh statistics
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // TEACHER MANAGEMENT
  // ============================================================================

  Future<void> _loadTeachers() async {
    try {
      _teachers = await _adminService.getAllTeachers();
    } catch (e) {
      debugPrint('Error loading teachers: $e');
      throw e;
    }
  }

  Future<bool> addTeacher(Map<String, dynamic> teacherData) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _adminService.addTeacher(teacherData);
      if (success) {
        await _loadTeachers();
        await _loadStatistics(); // Refresh statistics
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTeacher(String teacherId, Map<String, dynamic> teacherData) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _adminService.updateTeacher(teacherId, teacherData);
      if (success) {
        await _loadTeachers();
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTeacher(String teacherId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _adminService.deleteTeacher(teacherId);
      if (success) {
        await _loadTeachers();
        await _loadStatistics(); // Refresh statistics
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // STATISTICS
  // ============================================================================

  Future<void> _loadStatistics() async {
    try {
      _statistics = await _adminService.getDashboardStatistics();
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    }
  }

  // ============================================================================
  // BULK OPERATIONS
  // ============================================================================

  Future<Map<String, dynamic>> importStudents(List<Map<String, dynamic>> studentsData) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _adminService.importStudents(studentsData);

      if (result['success']) {
        await _loadStudents();
        await _loadStatistics();
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'imported': 0,
        'failed': studentsData.length,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> importTeachers(List<Map<String, dynamic>> teachersData) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _adminService.importTeachers(teachersData);

      if (result['success']) {
        await _loadTeachers();
        await _loadStatistics();
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'imported': 0,
        'failed': teachersData.length,
        'error': e.toString(),
      };
    }
  }

  // ============================================================================
  // SEARCH & FILTER
  // ============================================================================

  List<Map<String, dynamic>> searchStudents(String query) {
    if (query.isEmpty) return _students;

    final lowerQuery = query.toLowerCase();
    return _students.where((student) {
      return student['name'].toString().toLowerCase().contains(lowerQuery) ||
          student['student_id'].toString().toLowerCase().contains(lowerQuery) ||
          student['email'].toString().toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<Map<String, dynamic>> searchTeachers(String query) {
    if (query.isEmpty) return _teachers;

    final lowerQuery = query.toLowerCase();
    return _teachers.where((teacher) {
      return teacher['name'].toString().toLowerCase().contains(lowerQuery) ||
          teacher['teacher_id'].toString().toLowerCase().contains(lowerQuery) ||
          teacher['subject'].toString().toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<Map<String, dynamic>> filterStudentsByClass(String className) {
    if (className == 'All') return _students;
    return _students.where((s) => s['class'] == className).toList();
  }

  List<Map<String, dynamic>> filterTeachersBySubject(String subject) {
    if (subject == 'All') return _teachers;
    return _teachers.where((t) => t['subject'] == subject).toList();
  }

  // ============================================================================
  // REPORTS
  // ============================================================================

  Future<Map<String, dynamic>> generateReport({
    required String reportType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _adminService.generateSchoolReport(
        reportType: reportType,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      debugPrint('Error generating report: $e');
      return {};
    }
  }

  // ============================================================================
  // ANALYTICS
  // ============================================================================

  Map<String, int> getStudentsByClass() {
    final Map<String, int> classCount = {};
    for (var student in _students) {
      final className = student['class'] as String;
      classCount[className] = (classCount[className] ?? 0) + 1;
    }
    return classCount;
  }

  Map<String, int> getTeachersBySubject() {
    final Map<String, int> subjectCount = {};
    for (var teacher in _teachers) {
      final subject = teacher['subject'] as String;
      subjectCount[subject] = (subjectCount[subject] ?? 0) + 1;
    }
    return subjectCount;
  }

  Map<String, int> getStudentsByGender() {
    final Map<String, int> genderCount = {};
    for (var student in _students) {
      final gender = student['gender'] as String;
      genderCount[gender] = (genderCount[gender] ?? 0) + 1;
    }
    return genderCount;
  }

  // ============================================================================
  // UTILITIES
  // ============================================================================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadAllUsers();
  }
}