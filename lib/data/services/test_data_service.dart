// lib/data/services/test_data_service.dart
// ✅ FIXED VERSION - All duplicates removed

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/attendance_model.dart';
import '../models/attendance_summary_model.dart';

class TestDataService {
  static TestDataService? _instance;
  static TestDataService get instance {
    _instance ??= TestDataService._();
    return _instance!;
  }

  TestDataService._();

  Map<String, dynamic>? _testData;
  bool _isLoaded = false;

  // Registration storage
  final Map<String, String> _registeredPasswords = {}; // email -> password
  bool _registrationInitialized = false;

  // ============================================================================
  // LOAD TEST DATA
  // ============================================================================

  Future<void> loadTestData() async {
    if (_isLoaded) return;

    try {
      final String jsonString = await rootBundle.loadString('assets/test_data.json');
      _testData = json.decode(jsonString);
      _isLoaded = true;
      print('✅ Test data loaded successfully from JSON');

      // DEBUG: Print student emails
      final students = getStudents();
      print('📧 Student emails in test data:');
      for (var s in students) {
        print('  - ${s['email']}');
      }
    } catch (e) {
      print('❌ Error loading test data: $e');
      print('⚠️ Using fallback data');
      _testData = _getFallbackData();
      _isLoaded = true;

      // DEBUG: Print student emails from fallback
      final students = getStudents();
      print('📧 Student emails in fallback data:');
      for (var s in students) {
        print('  - ${s['email']}');
      }
    }

    // Load registered users
    await _loadRegisteredUsers();
  }

  // ============================================================================
  // REGISTRATION FUNCTIONALITY
  // ============================================================================

  /// Load registered users from SharedPreferences
  Future<void> _loadRegisteredUsers() async {
    if (_registrationInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final registeredPasswordsJson = prefs.getString('test_registered_passwords');
      final registeredUsersJson = prefs.getString('test_registered_users_data');

      // Load passwords
      if (registeredPasswordsJson != null) {
        final Map<String, dynamic> passwordsMap = json.decode(registeredPasswordsJson);
        passwordsMap.forEach((email, password) {
          _registeredPasswords[email] = password as String;
        });
      }

      // Load and merge registered users into test data
      if (registeredUsersJson != null) {
        final List<dynamic> registeredUsers = json.decode(registeredUsersJson);

        // Merge into appropriate lists based on role
        for (var userData in registeredUsers) {
          final role = userData['role'];

          if (role == 'admin') {
            _testData!['admin'] = userData;
          } else if (role == 'teacher') {
            final teachers = List<Map<String, dynamic>>.from(_testData?['teachers'] ?? []);
            if (!teachers.any((t) => t['email'] == userData['email'])) {
              teachers.add(userData);
              _testData!['teachers'] = teachers;
            }
          } else if (role == 'student') {
            final students = List<Map<String, dynamic>>.from(_testData?['students'] ?? []);
            if (!students.any((s) => s['email'] == userData['email'])) {
              students.add(userData);
              _testData!['students'] = students;
            }
          }
        }
      }

      _registrationInitialized = true;
      print('✅ Loaded ${_registeredPasswords.length} registered users');
    } catch (e) {
      print('⚠️ Error loading registered users: $e');
    }
  }

  /// Save registered users to SharedPreferences
  Future<void> _saveRegisteredUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save passwords
      await prefs.setString('test_registered_passwords', json.encode(_registeredPasswords));

      // Collect all registered users (those not in default data)
      final List<Map<String, dynamic>> registeredUsers = [];

      // Get default emails to exclude
      final defaultEmails = <String>{
        'admin@school.com',
        'teacher@school.com',
        'student@school.com',
        'parent@school.com',
      };

      // Add registered teachers
      for (var teacher in getTeachers()) {
        if (!defaultEmails.contains(teacher['email'])) {
          registeredUsers.add(teacher);
        }
      }

      // Add registered students
      for (var student in getStudents()) {
        if (!defaultEmails.contains(student['email'])) {
          registeredUsers.add(student);
        }
      }

      // Add registered admin if not default
      final admin = getAdmin();
      if (admin != null && !defaultEmails.contains(admin['email'])) {
        registeredUsers.add(admin);
      }

      await prefs.setString('test_registered_users_data', json.encode(registeredUsers));

      print('✅ Saved ${_registeredPasswords.length} registered users');
    } catch (e) {
      print('⚠️ Error saving registered users: $e');
    }
  }

  /// Register a new user in test mode (WITH APPROVAL STATUS)
  Future<bool> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    try {
      await loadTestData();

      if (emailExists(email)) {
        print('❌ User with email $email already exists');
        return false;
      }

      _registeredPasswords[email] = password;
      final userId = '${role.name.toUpperCase()}_${DateTime.now().millisecondsSinceEpoch}';

      // ✅ All registrations start as pending (except admin can be auto-approved)
      final approvalStatus = (role == UserRole.admin) ? 'approved' : 'pending';
      final approvalDate = (role == UserRole.admin)
          ? DateTime.now().toIso8601String()
          : null;
      final approvedBy = (role == UserRole.admin) ? 'SYSTEM' : null;

      if (role == UserRole.admin) {
        _testData!['admin'] = {
          'admin_id': userId,
          'name': name,
          'role': 'Administrator',
          'email': email,
          'phone': phone,
          'qualification': 'Registered User',
          'joining_date': DateTime.now().toIso8601String().split('T')[0],
          'approval_status': "approved",
          'approval_date': approvalDate,
          'approved_by': approvedBy,
        };
      } else if (role == UserRole.teacher) {
        final teachers = List<Map<String, dynamic>>.from(_testData?['teachers'] ?? []);
        teachers.add({
          'teacher_id': userId,
          'name': name,
          'email': email,
          'phone': phone,
          'subject': 'General',
          'classes_assigned': [],
          'qualification': 'Registered Teacher',
          'joining_date': DateTime.now().toIso8601String().split('T')[0],
          'role': 'teacher',
          'approval_status': 'pending',
          'approval_date': null,
          'approved_by': null,
        });
        _testData!['teachers'] = teachers;
      } else if (role == UserRole.student) {
        final students = List<Map<String, dynamic>>.from(_testData?['students'] ?? []);
        students.add({
          'student_id': userId,
          'name': name,
          'class': 'Not Assigned',
          'section': 'N/A',
          'roll_number': students.length + 1,
          'email': email,
          'date_of_birth': '2010-01-01',
          'blood_group': 'Unknown',
          'parent_details': {
            'father_name': 'Parent of $name',
            'father_phone': phone,
            'father_email': '',
            'father_occupation': 'Not specified',
            'mother_name': '',
            'mother_phone': '',
            'mother_email': '',
            'mother_occupation': '',
          },
          'role': 'student',
          'approval_status': 'pending',
          'approval_date': null,
          'approved_by': null,
        });
        _testData!['students'] = students;
      } else if (role == UserRole.parent) {
        final students = List<Map<String, dynamic>>.from(_testData?['students'] ?? []);
        final studentId = 'S_${DateTime.now().millisecondsSinceEpoch}';
        students.add({
          'student_id': studentId,
          'name': 'Child of $name',
          'class': 'Not Assigned',
          'section': 'N/A',
          'roll_number': students.length + 1,
          'email': '',
          'date_of_birth': '2010-01-01',
          'blood_group': 'Unknown',
          'parent_details': {
            'father_name': name,
            'father_phone': phone,
            'father_email': email,
            'father_occupation': 'Parent',
            'mother_name': '',
            'mother_phone': '',
            'mother_email': '',
            'mother_occupation': '',
          },
          'role': 'student',
          'approval_status': 'pending',
          'approval_date': null,
          'approved_by': null,
        });
        _testData!['students'] = students;
      }

      await _saveRegisteredUsers();
      print('✅ User registered successfully (PENDING APPROVAL): $email (${role.name})');
      return true;
    } catch (e) {
      print('❌ Registration error: $e');
      return false;
    }
  }

  /// Check if email exists
  bool emailExists(String email) {
    // Check admin
    final admin = getAdmin();
    if (admin != null && admin['email'] == email) return true;

    // Check teachers
    final teachers = getTeachers();
    if (teachers.any((t) => t['email'] == email)) return true;

    // Check students
    final students = getStudents();
    if (students.any((s) => s['email'] == email)) return true;

    // Check parent emails
    for (var student in students) {
      final parentDetails = student['parent_details'];
      if (parentDetails['father_email'] == email ||
          parentDetails['mother_email'] == email) {
        return true;
      }
    }

    return false;
  }

  /// Clear all registered users (except defaults)
  Future<void> clearRegisteredUsers() async {
    _registeredPasswords.clear();
    _registrationInitialized = false;
    _isLoaded = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('test_registered_users_data');
    await prefs.remove('test_registered_passwords');

    // Reload defaults
    await loadTestData();
    print('✅ Cleared all registered users, defaults restored');
  }

  // ============================================================================
  // APPROVAL MANAGEMENT (NEW)
  // ============================================================================

  /// Get all pending users (awaiting approval)
  List<Map<String, dynamic>> getPendingUsers() {
    final pending = <Map<String, dynamic>>[];

    // Check teachers
    for (var teacher in getTeachers()) {
      if (teacher['approval_status'] == 'pending') {
        pending.add({
          ...teacher,
          'user_type': 'teacher',
        });
      }
    }

    // Check students
    for (var student in getStudents()) {
      if (student['approval_status'] == 'pending') {
        pending.add({
          ...student,
          'user_type': 'student',
        });
      }
    }

    return pending;
  }

  /// Approve a user
  Future<bool> approveUser(String userId, String userType, String approvedBy) async {
    try {
      final now = DateTime.now().toIso8601String();

      if (userType == 'teacher') {
        final teachers = getTeachers();
        final index = teachers.indexWhere((t) => t['teacher_id'] == userId);
        if (index != -1) {
          teachers[index]['approval_status'] = 'approved';
          teachers[index]['approval_date'] = now;
          teachers[index]['approved_by'] = approvedBy;
          _testData!['teachers'] = teachers;
          await _saveRegisteredUsers();
          print('✅ Teacher approved: $userId');
          return true;
        }
      } else if (userType == 'student') {
        final students = getStudents();
        final index = students.indexWhere((s) => s['student_id'] == userId);
        if (index != -1) {
          students[index]['approval_status'] = 'approved';
          students[index]['approval_date'] = now;
          students[index]['approved_by'] = approvedBy;
          _testData!['students'] = students;
          await _saveRegisteredUsers();
          print('✅ Student approved: $userId');
          return true;
        }
      }

      return false;
    } catch (e) {
      print('❌ Error approving user: $e');
      return false;
    }
  }

  /// Reject a user
  Future<bool> rejectUser(String userId, String userType, String rejectedBy) async {
    try {
      final now = DateTime.now().toIso8601String();

      if (userType == 'teacher') {
        final teachers = getTeachers();
        final index = teachers.indexWhere((t) => t['teacher_id'] == userId);
        if (index != -1) {
          teachers[index]['approval_status'] = 'rejected';
          teachers[index]['approval_date'] = now;
          teachers[index]['approved_by'] = rejectedBy;
          _testData!['teachers'] = teachers;
          await _saveRegisteredUsers();
          print('❌ Teacher rejected: $userId');
          return true;
        }
      } else if (userType == 'student') {
        final students = getStudents();
        final index = students.indexWhere((s) => s['student_id'] == userId);
        if (index != -1) {
          students[index]['approval_status'] = 'rejected';
          students[index]['approval_date'] = now;
          students[index]['approved_by'] = rejectedBy;
          _testData!['students'] = students;
          await _saveRegisteredUsers();
          print('❌ Student rejected: $userId');
          return true;
        }
      }

      return false;
    } catch (e) {
      print('❌ Error rejecting user: $e');
      return false;
    }
  }

  // ============================================================================
  // DATA GETTERS
  // ============================================================================

  // Get all teachers
  List<Map<String, dynamic>> getTeachers() {
    return List<Map<String, dynamic>>.from(_testData?['teachers'] ?? []);
  }

  // Get all students
  List<Map<String, dynamic>> getStudents() {
    return List<Map<String, dynamic>>.from(_testData?['students'] ?? []);
  }

  // Get admin
  Map<String, dynamic>? getAdmin() {
    return _testData?['admin'];
  }

  // Get teacher by ID
  Map<String, dynamic>? getTeacherById(String teacherId) {
    final teachers = getTeachers();
    try {
      return teachers.firstWhere((t) => t['teacher_id'] == teacherId);
    } catch (e) {
      return null;
    }
  }

  // Get student by ID
  Map<String, dynamic>? getStudentById(String studentId) {
    final students = getStudents();
    try {
      return students.firstWhere((s) => s['student_id'] == studentId);
    } catch (e) {
      return null;
    }
  }

  // Get students by class and section
  List<Map<String, dynamic>> getStudentsByClass(String className, String section) {
    final students = getStudents();
    return students.where((s) =>
    s['class'] == className && s['section'] == section
    ).toList();
  }

  // Get attendance records
  List<Map<String, dynamic>> getAttendanceRecords() {
    return List<Map<String, dynamic>>.from(_testData?['sample_attendance_records'] ?? []);
  }

  // ============================================================================
  // MODEL CONVERTERS (WITH APPROVAL STATUS)
  // ============================================================================

  /// Convert teacher data to UserModel
  UserModel teacherToUserModel(Map<String, dynamic> teacher) {
    return UserModel(
      id: teacher['teacher_id'],
      email: teacher['email'],
      name: teacher['name'],
      phone: teacher['phone'],
      role: UserRole.teacher,
      isActive: true,
      metadata: {
        'subject': teacher['subject'],
        'classes_assigned': teacher['classes_assigned'],
        'qualification': teacher['qualification'],
        'joining_date': teacher['joining_date'],
      },
      approvalStatus: _parseApprovalStatus(teacher['approval_status']),
      approvalDate: teacher['approval_date'] != null
          ? DateTime.parse(teacher['approval_date'])
          : null,
      approvedBy: teacher['approved_by'],
    );
  }

  /// Convert student data to UserModel
  UserModel studentToUserModel(Map<String, dynamic> student) {
    return UserModel(
      id: student['student_id'],
      email: student['email'],
      name: student['name'],
      phone: student['parent_details']['father_phone'],
      role: UserRole.student,
      isActive: true,
      metadata: {
        'class': student['class'],
        'section': student['section'],
        'roll_number': student['roll_number'],
        'date_of_birth': student['date_of_birth'],
        'blood_group': student['blood_group'],
        'parent_details': student['parent_details'],
      },
      approvalStatus: _parseApprovalStatus(student['approval_status']),
      approvalDate: student['approval_date'] != null
          ? DateTime.parse(student['approval_date'])
          : null,
      approvedBy: student['approved_by'],
    );
  }

  /// Convert admin data to UserModel
  UserModel adminToUserModel(Map<String, dynamic> admin) {
    return UserModel(
      id: admin['admin_id'],
      email: admin['email'],
      name: admin['name'],
      phone: admin['phone'],
      role: UserRole.admin,
      isActive: true,
      metadata: {
        'role': admin['role'],
        'qualification': admin['qualification'],
        'joining_date': admin['joining_date'],
      },
      approvalStatus: _parseApprovalStatus(admin['approval_status']),
      approvalDate: admin['approval_date'] != null
          ? DateTime.parse(admin['approval_date'])
          : null,
      approvedBy: admin['approved_by'],
    );
  }

  /// Helper method to parse approval status
  static ApprovalStatus _parseApprovalStatus(String? statusString) {
    switch (statusString?.toLowerCase()) {
      case 'approved':
        return ApprovalStatus.approved;
      case 'rejected':
        return ApprovalStatus.rejected;
      case 'pending':
      default:
        return ApprovalStatus.pending;
    }
  }

  // ============================================================================
  // AUTHENTICATION
  // ============================================================================

  /// Login with test data (UPDATED to check passwords and approval)
  Future<UserModel?> loginWithTestData(String email, String password) async {
    await loadTestData();

    print('🔍 Attempting login for: $email');

    // Check if this is a registered user with password
    if (_registeredPasswords.containsKey(email)) {
      if (_registeredPasswords[email] != password) {
        print('❌ Invalid password for registered user: $email');
        return null;
      }
      print('✅ Password verified for registered user: $email');
    } else {
      // Default test users accept any password
      print('ℹ️ Using default test user (no password check): $email');
    }

    // Check admin
    final admin = getAdmin();
    if (admin != null && admin['email'] == email) {
      print('✅ Login successful as admin');
      return adminToUserModel(admin);
    }

    // Check teachers
    final teachers = getTeachers();
    for (var teacher in teachers) {
      if (teacher['email'] == email) {
        print('✅ Login successful as teacher');
        return teacherToUserModel(teacher);
      }
    }

    // Check students
    final students = getStudents();
    for (var student in students) {
      if (student['email'] == email) {
        print('✅ Login successful as student');
        return studentToUserModel(student);
      }
    }

    // Check parents (using parent email from student data)
    for (var student in students) {
      final parentDetails = student['parent_details'];
      if (parentDetails['father_email'] == email || parentDetails['mother_email'] == email) {
        print('✅ Login successful as parent');
        return UserModel(
          id: 'P${student['student_id']}',
          email: email,
          name: parentDetails['father_name'],
          phone: parentDetails['father_phone'],
          role: UserRole.parent,
          isActive: true,
          metadata: {
            'children': [student['student_id']],
            'student_name': student['name'],
            'student_class': student['class'],
            'student_section': student['section'],
          },
          approvalStatus: _parseApprovalStatus(student['approval_status']),
          approvalDate: student['approval_date'] != null
              ? DateTime.parse(student['approval_date'])
              : null,
          approvedBy: student['approved_by'],
        );
      }
    }

    print('❌ User not found: $email');
    return null;
  }

  // ============================================================================
  // ATTENDANCE
  // ============================================================================

  /// Generate attendance summary for a student
  AttendanceSummaryModel generateAttendanceSummary(String studentId) {
    final attendanceRecords = getAttendanceRecords();
    final studentRecords = attendanceRecords.where((r) => r['student_id'] == studentId).toList();

    final totalDays = 100; // Mock total school days
    final presentDays = studentRecords.where((r) => r['status'] == 'Present').length + 85;
    final absentDays = studentRecords.where((r) => r['status'] == 'Absent').length + 5;
    final lateDays = 3;
    final sickDays = 4;
    final excusedDays = 3;

    final percentage = (presentDays / totalDays) * 100;

    return AttendanceSummaryModel(
      studentId: studentId,
      totalDays: totalDays,
      presentDays: presentDays,
      absentDays: absentDays,
      lateDays: lateDays,
      sickDays: sickDays,
      excusedDays: excusedDays,
      attendancePercentage: percentage,
    );
  }

  // ============================================================================
  // FALLBACK DATA
  // ============================================================================

  /// Fallback data if JSON file is not found
  Map<String, dynamic> _getFallbackData() {
    return {
      'teachers': [
        {
          'teacher_id': 'T001',
          'name': 'Demo Teacher',
          'email': 'teacher@school.com',
          'phone': '+91-9876543210',
          'subject': 'Mathematics',
          'classes_assigned': ['10th-A', '10th-B'],
          'qualification': 'B.Ed, M.Sc. Mathematics',
          'joining_date': '2015-06-01',
          'approval_status': 'approved',
          'approval_date': '2015-06-01',
          'approved_by': 'SYSTEM',
        }
      ],
      'students': [
        {
          'student_id': 'S001',
          'name': 'Demo Student',
          'class': '10th',
          'section': 'A',
          'roll_number': 1,
          'email': 'student@school.com',
          'date_of_birth': '2010-01-15',
          'blood_group': 'O+',
          'parent_details': {
            'father_name': 'Demo Parent',
            'father_phone': '+91-9123456001',
            'father_email': 'parent@school.com',
            'father_occupation': 'Engineer',
            'mother_name': '',
            'mother_phone': '',
            'mother_email': '',
            'mother_occupation': '',
          },
          'approval_status': 'approved',
          'approval_date': '2010-01-15',
          'approved_by': 'SYSTEM',
        }
      ],
      'admin': {
        'admin_id': 'ADM001',
        'name': 'Admin User',
        'role': 'Principal',
        'email': 'admin@school.com',
        'phone': '+91-9876500001',
        'qualification': 'Ph.D. Education',
        'joining_date': '2010-01-01',
        'approval_status': 'approved',
        'approval_date': '2010-01-01',
        'approved_by': 'SYSTEM',
      },
      'sample_attendance_records': []
    };
  }

  // ============================================================================
  // UTILITIES
  // ============================================================================

  // Get metadata
  Map<String, dynamic> getMetadata() {
    return Map<String, dynamic>.from(_testData?['metadata'] ?? {});
  }

  // Check if test data is loaded
  bool get isLoaded => _isLoaded;
}