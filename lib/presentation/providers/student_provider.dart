// lib/presentation/providers/student_provider.dart (FINAL VERSION)

import 'package:flutter/material.dart';
import '../../data/services/student_service.dart';
import '../../data/models/student_model.dart';

class StudentProvider with ChangeNotifier {
  final StudentService _studentService = StudentService();

  List<StudentModel> _students = [];
  List<StudentModel> _filteredStudents = [];
  bool _isLoading = false;
  String? _error;

  // Current filters
  String _currentSearchQuery = '';
  String _currentClassFilter = 'All';
  String _currentSectionFilter = 'All';

  // Getters
  List<StudentModel> get students => _filteredStudents;
  List<StudentModel> get allStudents => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalStudents => _students.length;

  Map<String, int> get studentsByClass {
    final map = <String, int>{};
    for (var student in _students) {
      final key = '${student.className}-${student.section}';
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> get studentsByGender {
    final map = <String, int>{};
    for (var student in _students) {
      map[student.gender] = (map[student.gender] ?? 0) + 1;
    }
    return map;
  }

  // Load all students from Firestore
  Future<void> loadStudents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _students = await _studentService.getAllStudents();
      _applyFilters();
      print('✅ Loaded ${_students.length} students from Firestore');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load students: $e';
      _isLoading = false;
      print('❌ Error loading students: $e');
      notifyListeners();
    }
  }

  // Add new student to Firestore
  Future<bool> addStudent(StudentModel student) async {
    try {
      final success = await _studentService.addStudent(student);
      if (success) {
        await loadStudents(); // Reload to get updated list
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error adding student: $e');
      _error = 'Failed to add student: $e';
      notifyListeners();
      return false;
    }
  }

  // Update existing student in Firestore
  Future<bool> updateStudent(StudentModel student) async {
    try {
      final success = await _studentService.updateStudent(student);
      if (success) {
        await loadStudents(); // Reload to get updated list
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error updating student: $e');
      _error = 'Failed to update student: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete student from Firestore
  Future<bool> deleteStudent(String studentId) async {
    try {
      final success = await _studentService.deleteStudent(studentId);
      if (success) {
        await loadStudents(); // Reload to get updated list
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error deleting student: $e');
      _error = 'Failed to delete student: $e';
      notifyListeners();
      return false;
    }
  }

  // Search students
  void searchStudents(String query) {
    _currentSearchQuery = query.toLowerCase();
    _applyFilters();
  }

  // Filter by class
  void filterByClass(String className) {
    _currentClassFilter = className;
    _applyFilters();
  }

  // Filter by section
  void filterBySection(String section) {
    _currentSectionFilter = section;
    _applyFilters();
  }

  // Clear all filters
  void clearFilters() {
    _currentSearchQuery = '';
    _currentClassFilter = 'All';
    _currentSectionFilter = 'All';
    _applyFilters();
  }

  // Apply all filters
  void _applyFilters() {
    _filteredStudents = _students.where((student) {
      // Search filter
      bool matchesSearch = _currentSearchQuery.isEmpty ||
          student.name.toLowerCase().contains(_currentSearchQuery) ||
          student.studentId.toLowerCase().contains(_currentSearchQuery);

      // Class filter
      bool matchesClass = _currentClassFilter == 'All' ||
          student.className == _currentClassFilter;

      // Section filter
      bool matchesSection = _currentSectionFilter == 'All' ||
          student.section == _currentSectionFilter;

      return matchesSearch && matchesClass && matchesSection;
    }).toList();

    notifyListeners();
  }

  // Get student by ID
  Future<StudentModel?> getStudentById(String studentId) async {
    try {
      return await _studentService.getStudentById(studentId);
    } catch (e) {
      print('❌ Error getting student: $e');
      return null;
    }
  }

  // Initialize with sample data (for testing)
  Future<bool> initializeSampleData(List<Map<String, dynamic>> sampleData) async {
    try {
      final success = await _studentService.initializeSampleData(sampleData);
      if (success) {
        await loadStudents();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error initializing sample data: $e');
      return false;
    }
  }

  // Clear all students (use with caution!)
  Future<bool> clearAllStudents() async {
    try {
      final success = await _studentService.clearAllStudents();
      if (success) {
        _students = [];
        _filteredStudents = [];
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error clearing students: $e');
      return false;
    }
  }
}