// // lib/presentation/providers/admin_provider.dart
//
// import 'package:flutter/foundation.dart';
// import '../../data/services/admin_service.dart';
//
// class AdminProvider with ChangeNotifier {
//   final AdminService _adminService;
//
//   AdminProvider(this._adminService);
//
//   bool _isLoading = false;
//   List<Map<String, dynamic>> _students = [];
//   List<Map<String, dynamic>> _teachers = [];
//   Map<String, dynamic>? _statistics;
//
//   bool get isLoading => _isLoading;
//   List<Map<String, dynamic>> get students => _students;
//   List<Map<String, dynamic>> get teachers => _teachers;
//   Map<String, dynamic>? get statistics => _statistics;
//
//   // Load all users (students and teachers)
//   Future<void> loadAllUsers() async {
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       _students = await _adminService.getAllStudents();
//       _teachers = await _adminService.getAllTeachers();
//     } catch (e) {
//       debugPrint('Error loading users: $e');
//     }
//
//     _isLoading = false;
//     notifyListeners();
//   }
//
//   // Load dashboard statistics
//   Future<void> loadStatistics() async {
//     try {
//       _statistics = await _adminService.getDashboardStatistics();
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error loading statistics: $e');
//     }
//   }
//
//   // Add new student
//   Future<bool> addStudent(Map<String, dynamic> studentData) async {
//     try {
//       final success = await _adminService.addStudent(studentData);
//       if (success) {
//         await loadAllUsers(); // Reload the list
//       }
//       return success;
//     } catch (e) {
//       debugPrint('Error adding student: $e');
//       return false;
//     }
//   }
//
//   // Update student
//   Future<bool> updateStudent(String studentId, Map<String, dynamic> studentData) async {
//     try {
//       final success = await _adminService.updateStudent(studentId, studentData);
//       if (success) {
//         await loadAllUsers(); // Reload the list
//       }
//       return success;
//     } catch (e) {
//       debugPrint('Error updating student: $e');
//       return false;
//     }
//   }
//
//   // Delete student
//   Future<bool> deleteStudent(String studentId) async {
//     try {
//       final success = await _adminService.deleteStudent(studentId);
//       if (success) {
//         _students.removeWhere((s) => s['student_id'] == studentId);
//         notifyListeners();
//       }
//       return success;
//     } catch (e) {
//       debugPrint('Error deleting student: $e');
//       return false;
//     }
//   }
//
//   // Add new teacher
//   Future<bool> addTeacher(Map<String, dynamic> teacherData) async {
//     try {
//       final success = await _adminService.addTeacher(teacherData);
//       if (success) {
//         await loadAllUsers(); // Reload the list
//       }
//       return success;
//     } catch (e) {
//       debugPrint('Error adding teacher: $e');
//       return false;
//     }
//   }
//
//   // Update teacher
//   Future<bool> updateTeacher(String teacherId, Map<String, dynamic> teacherData) async {
//     try {
//       final success = await _adminService.updateTeacher(teacherId, teacherData);
//       if (success) {
//         await loadAllUsers(); // Reload the list
//       }
//       return success;
//     } catch (e) {
//       debugPrint('Error updating teacher: $e');
//       return false;
//     }
//   }
//
//   // Delete teacher
//   Future<bool> deleteTeacher(String teacherId) async {
//     try {
//       final success = await _adminService.deleteTeacher(teacherId);
//       if (success) {
//         _teachers.removeWhere((t) => t['teacher_id'] == teacherId);
//         notifyListeners();
//       }
//       return success;
//     } catch (e) {
//       debugPrint('Error deleting teacher: $e');
//       return false;
//     }
//   }
//
//   // Search students
//   List<Map<String, dynamic>> searchStudents(String query) {
//     if (query.isEmpty) return _students;
//
//     final lowerQuery = query.toLowerCase();
//     return _students.where((student) {
//       return student['name'].toString().toLowerCase().contains(lowerQuery) ||
//           student['email'].toString().toLowerCase().contains(lowerQuery) ||
//           student['student_id'].toString().toLowerCase().contains(lowerQuery);
//     }).toList();
//   }
//
//   // Search teachers
//   List<Map<String, dynamic>> searchTeachers(String query) {
//     if (query.isEmpty) return _teachers;
//
//     final lowerQuery = query.toLowerCase();
//     return _teachers.where((teacher) {
//       return teacher['name'].toString().toLowerCase().contains(lowerQuery) ||
//           teacher['email'].toString().toLowerCase().contains(lowerQuery) ||
//           teacher['subject'].toString().toLowerCase().contains(lowerQuery);
//     }).toList();
//   }
//
//   // Get students by class
//   List<Map<String, dynamic>> getStudentsByClass(String className, String section) {
//     return _students.where((s) =>
//     s['class'] == className && s['section'] == section
//     ).toList();
//   }
// }

// lib/presentation/providers/admin_provider.dart

import 'package:flutter/material.dart';
import '../../data/services/test_data_service.dart';

class AdminProvider with ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _teachers = [];

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get students => _students;
  List<Map<String, dynamic>> get teachers => _teachers;

  // Load all users
  Future<void> loadAllUsers() async {
    _isLoading = true;
    notifyListeners();

    await TestDataService.instance.loadTestData();
    _students = TestDataService.instance.getStudents();
    _teachers = TestDataService.instance.getTeachers();

    _isLoading = false;
    notifyListeners();
  }

  // Add Student
  Future<bool> addStudent(Map<String, dynamic> studentData) async {
    try {
      final studentId = 'S${DateTime.now().millisecondsSinceEpoch}';
      studentData['student_id'] = studentId;

      _students.add(studentData);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding student: $e');
      return false;
    }
  }

  // Update Student
  Future<bool> updateStudent(String studentId, Map<String, dynamic> studentData) async {
    try {
      final index = _students.indexWhere((s) => s['student_id'] == studentId);
      if (index != -1) {
        _students[index] = {..._students[index], ...studentData};
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating student: $e');
      return false;
    }
  }

  // Delete Student
  Future<bool> deleteStudent(String studentId) async {
    try {
      _students.removeWhere((s) => s['student_id'] == studentId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting student: $e');
      return false;
    }
  }

  // Add Teacher
  Future<bool> addTeacher(Map<String, dynamic> teacherData) async {
    try {
      final teacherId = 'T${DateTime.now().millisecondsSinceEpoch}';
      teacherData['teacher_id'] = teacherId;

      _teachers.add(teacherData);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding teacher: $e');
      return false;
    }
  }

  // Update Teacher
  Future<bool> updateTeacher(String teacherId, Map<String, dynamic> teacherData) async {
    try {
      final index = _teachers.indexWhere((t) => t['teacher_id'] == teacherId);
      if (index != -1) {
        _teachers[index] = {..._teachers[index], ...teacherData};
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating teacher: $e');
      return false;
    }
  }

  // Delete Teacher
  Future<bool> deleteTeacher(String teacherId) async {
    try {
      _teachers.removeWhere((t) => t['teacher_id'] == teacherId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting teacher: $e');
      return false;
    }
  }
}