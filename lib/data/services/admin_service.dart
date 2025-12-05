// lib/data/services/admin_service.dart
// ✅ COMPLETE VERSION - All methods included

import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'api_service.dart';
import 'test_data_service.dart';

class AdminService {
  final ApiService _apiService;
  static const bool _useTestData = true; // Toggle for production

  AdminService(this._apiService);

  // ============================================================================
  // USER APPROVAL MANAGEMENT
  // ============================================================================

  /// Get all pending user registrations
  Future<List<Map<String, dynamic>>> getPendingApprovals() async {
    try {
      if (_useTestData) {
        await TestDataService.instance.loadTestData();
        final pendingUsers = TestDataService.instance.getPendingUsers();
        debugPrint('📊 Found ${pendingUsers.length} pending users (test mode)');
        return pendingUsers;
      }

      final response = await _apiService.get('/admin/pending-approvals');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error fetching pending approvals: $e');
      return [];
    }
  }

  /// Get count of pending approvals
  Future<int> getPendingApprovalsCount() async {
    try {
      final pendingUsers = await getPendingApprovals();
      return pendingUsers.length;
    } catch (e) {
      debugPrint('❌ Error getting pending count: $e');
      return 0;
    }
  }

  /// Approve a user registration
  Future<bool> approveUser({
    required String userId,
    required String userType,
    required String approvedBy,
  }) async {
    try {
      debugPrint('🔄 Approving user: $userId ($userType)');

      if (_useTestData) {
        final success = await TestDataService.instance.approveUser(
          userId,
          userType,
          approvedBy,
        );

        if (success) {
          debugPrint('✅ User approved successfully (test mode)');
        } else {
          debugPrint('❌ Failed to approve user (test mode)');
        }

        return success;
      }

      final response = await _apiService.post('/admin/approve-user', {
        'user_id': userId,
        'user_type': userType,
        'approved_by': approvedBy,
      });

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Error approving user: $e');
      return false;
    }
  }

  /// Reject a user registration
  Future<bool> rejectUser({
    required String userId,
    required String userType,
    required String rejectedBy,
    String? reason,
  }) async {
    try {
      debugPrint('🔄 Rejecting user: $userId ($userType)');

      if (_useTestData) {
        final success = await TestDataService.instance.rejectUser(
          userId,
          userType,
          rejectedBy,
        );

        if (success) {
          debugPrint('✅ User rejected successfully (test mode)');
        } else {
          debugPrint('❌ Failed to reject user (test mode)');
        }

        return success;
      }

      final response = await _apiService.post('/admin/reject-user', {
        'user_id': userId,
        'user_type': userType,
        'rejected_by': rejectedBy,
        if (reason != null) 'reason': reason,
      });

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Error rejecting user: $e');
      return false;
    }
  }

  // ============================================================================
  // STUDENT MANAGEMENT
  // ============================================================================

  /// Get all students
  Future<List<Map<String, dynamic>>> getAllStudents() async {
    try {
      if (_useTestData) {
        await TestDataService.instance.loadTestData();
        return TestDataService.instance.getStudents();
      }

      final response = await _apiService.get('/admin/students');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error fetching students: $e');
      return [];
    }
  }

  /// Get student by ID
  Future<Map<String, dynamic>?> getStudentById(String studentId) async {
    try {
      if (_useTestData) {
        await TestDataService.instance.loadTestData();
        return TestDataService.instance.getStudentById(studentId);
      }

      final response = await _apiService.get('/admin/students/$studentId');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error fetching student: $e');
      return null;
    }
  }

  /// Add new student
  Future<bool> addStudent(Map<String, dynamic> studentData) async {
    try {
      if (_useTestData) {
        await Future.delayed(const Duration(seconds: 1));
        debugPrint('✅ Student added (test mode): ${studentData['name']}');
        return true;
      }

      final response = await _apiService.post('/admin/students', studentData);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ Error adding student: $e');
      return false;
    }
  }

  /// Update student
  Future<bool> updateStudent(String studentId, Map<String, dynamic> studentData) async {
    try {
      if (_useTestData) {
        await Future.delayed(const Duration(seconds: 1));
        debugPrint('✅ Student updated (test mode): $studentId');
        return true;
      }

      final response = await _apiService.put('/admin/students/$studentId', studentData);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('❌ Error updating student: $e');
      return false;
    }
  }

  /// Delete student
  Future<bool> deleteStudent(String studentId) async {
    try {
      if (_useTestData) {
        await Future.delayed(const Duration(seconds: 1));
        debugPrint('✅ Student deleted (test mode): $studentId');
        return true;
      }

      final response = await _apiService.delete('/admin/students/$studentId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('❌ Error deleting student: $e');
      return false;
    }
  }

  // ============================================================================
  // TEACHER MANAGEMENT
  // ============================================================================

  /// Get all teachers
  Future<List<Map<String, dynamic>>> getAllTeachers() async {
    try {
      if (_useTestData) {
        await TestDataService.instance.loadTestData();
        return TestDataService.instance.getTeachers();
      }

      final response = await _apiService.get('/admin/teachers');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error fetching teachers: $e');
      return [];
    }
  }

  /// Get teacher by ID
  Future<Map<String, dynamic>?> getTeacherById(String teacherId) async {
    try {
      if (_useTestData) {
        await TestDataService.instance.loadTestData();
        return TestDataService.instance.getTeacherById(teacherId);
      }

      final response = await _apiService.get('/admin/teachers/$teacherId');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error fetching teacher: $e');
      return null;
    }
  }

  /// Add new teacher
  Future<bool> addTeacher(Map<String, dynamic> teacherData) async {
    try {
      if (_useTestData) {
        await Future.delayed(const Duration(seconds: 1));
        debugPrint('✅ Teacher added (test mode): ${teacherData['name']}');
        return true;
      }

      final response = await _apiService.post('/admin/teachers', teacherData);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ Error adding teacher: $e');
      return false;
    }
  }

  /// Update teacher
  Future<bool> updateTeacher(String teacherId, Map<String, dynamic> teacherData) async {
    try {
      if (_useTestData) {
        await Future.delayed(const Duration(seconds: 1));
        debugPrint('✅ Teacher updated (test mode): $teacherId');
        return true;
      }

      final response = await _apiService.put('/admin/teachers/$teacherId', teacherData);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('❌ Error updating teacher: $e');
      return false;
    }
  }

  /// Delete teacher
  Future<bool> deleteTeacher(String teacherId) async {
    try {
      if (_useTestData) {
        await Future.delayed(const Duration(seconds: 1));
        debugPrint('✅ Teacher deleted (test mode): $teacherId');
        return true;
      }

      final response = await _apiService.delete('/admin/teachers/$teacherId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('❌ Error deleting teacher: $e');
      return false;
    }
  }

  // ============================================================================
  // DASHBOARD & STATISTICS
  // ============================================================================

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStatistics() async {
    try {
      if (_useTestData) {
        await TestDataService.instance.loadTestData();
        return {
          'total_students': TestDataService.instance.getStudents().length,
          'total_teachers': TestDataService.instance.getTeachers().length,
          'total_classes': 13,
          'average_attendance': 92.5,
          'pending_applications': TestDataService.instance.getPendingUsers().length,
          'active_events': 3,
        };
      }

      final response = await _apiService.get('/admin/statistics');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? {};
      }

      return {};
    } catch (e) {
      debugPrint('❌ Error fetching statistics: $e');
      return {};
    }
  }

  // ============================================================================
  // CLASS MANAGEMENT
  // ============================================================================

  /// Get all classes
  Future<List<Map<String, dynamic>>> getAllClasses() async {
    try {
      if (_useTestData) {
        return [
          {'id': '1', 'name': '1st', 'sections': ['A', 'B']},
          {'id': '2', 'name': '2nd', 'sections': ['A', 'B']},
          {'id': '3', 'name': '3rd', 'sections': ['A', 'B']},
          {'id': '4', 'name': '4th', 'sections': ['A', 'B']},
          {'id': '5', 'name': '5th', 'sections': ['A', 'B', 'C']},
          {'id': '6', 'name': '6th', 'sections': ['A', 'B', 'C']},
          {'id': '7', 'name': '7th', 'sections': ['A', 'B', 'C']},
          {'id': '8', 'name': '8th', 'sections': ['A', 'B', 'C']},
          {'id': '9', 'name': '9th', 'sections': ['A', 'B', 'C']},
          {'id': '10', 'name': '10th', 'sections': ['A', 'B', 'C']},
          {'id': '11', 'name': '11th', 'sections': ['Science', 'Commerce']},
          {'id': '12', 'name': '12th', 'sections': ['Science', 'Commerce']},
        ];
      }

      final response = await _apiService.get('/admin/classes');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error fetching classes: $e');
      return [];
    }
  }

  /// Assign teacher to class
  Future<bool> assignTeacherToClass({
    required String teacherId,
    required String classId,
    required String section,
    required String subject,
  }) async {
    try {
      if (_useTestData) {
        await Future.delayed(const Duration(milliseconds: 500));
        debugPrint('✅ Teacher assigned to class (test mode)');
        return true;
      }

      final response = await _apiService.post('/admin/class-assignments', {
        'teacher_id': teacherId,
        'class_id': classId,
        'section': section,
        'subject': subject,
      });

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ Error assigning teacher: $e');
      return false;
    }
  }

  // ============================================================================
  // BULK OPERATIONS
  // ============================================================================

  /// Import students from CSV/Excel data
  Future<Map<String, dynamic>> importStudents(List<Map<String, dynamic>> studentsData) async {
    try {
      if (_useTestData) {
        await Future.delayed(const Duration(seconds: 2));
        debugPrint('✅ Imported ${studentsData.length} students (test mode)');

        return {
          'success': true,
          'imported': studentsData.length,
          'failed': 0,
        };
      }

      final response = await _apiService.post('/admin/students/bulk-import', {
        'students': studentsData,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'imported': data['imported'] ?? 0,
          'failed': data['failed'] ?? 0,
          'errors': data['errors'] ?? [],
        };
      }

      return {
        'success': false,
        'imported': 0,
        'failed': studentsData.length,
      };
    } catch (e) {
      debugPrint('❌ Error importing students: $e');
      return {
        'success': false,
        'imported': 0,
        'failed': studentsData.length,
        'error': e.toString(),
      };
    }
  }

  /// Import teachers from CSV/Excel data
  Future<Map<String, dynamic>> importTeachers(List<Map<String, dynamic>> teachersData) async {
    try {
      if (_useTestData) {
        await Future.delayed(const Duration(seconds: 2));
        debugPrint('✅ Imported ${teachersData.length} teachers (test mode)');

        return {
          'success': true,
          'imported': teachersData.length,
          'failed': 0,
        };
      }

      final response = await _apiService.post('/admin/teachers/bulk-import', {
        'teachers': teachersData,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'imported': data['imported'] ?? 0,
          'failed': data['failed'] ?? 0,
          'errors': data['errors'] ?? [],
        };
      }

      return {
        'success': false,
        'imported': 0,
        'failed': teachersData.length,
      };
    } catch (e) {
      debugPrint('❌ Error importing teachers: $e');
      return {
        'success': false,
        'imported': 0,
        'failed': teachersData.length,
        'error': e.toString(),
      };
    }
  }

  // ============================================================================
  // REPORTS
  // ============================================================================

  /// Generate school report
  Future<Map<String, dynamic>> generateSchoolReport({
    required String reportType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (_useTestData) {
        await Future.delayed(const Duration(seconds: 2));
        return {
          'report_type': reportType,
          'generated_at': DateTime.now().toIso8601String(),
          'data': {
            'summary': 'School report generated successfully',
          },
        };
      }

      final queryParams = {
        'report_type': reportType,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await _apiService.get(
        '/admin/reports',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      return {};
    } catch (e) {
      debugPrint('❌ Error generating report: $e');
      return {};
    }
  }
}