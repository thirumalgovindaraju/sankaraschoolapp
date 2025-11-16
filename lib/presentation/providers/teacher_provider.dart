// lib/presentation/providers/teacher_provider.dart

import 'package:flutter/foundation.dart';
import '../../data/services/teacher_service.dart';

class TeacherProvider with ChangeNotifier {
  final TeacherService _teacherService = TeacherService();

  List<Map<String, dynamic>> _teachers = [];
  List<Map<String, dynamic>> _filteredTeachers = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedSubject = 'All';

  List<Map<String, dynamic>> get teachers => _filteredTeachers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedSubject => _selectedSubject;

  int get totalTeachers => _teachers.length;

  Map<String, int> get teachersBySubject {
    final Map<String, int> subjectCount = {};
    for (var teacher in _teachers) {
      final subject = teacher['subject'] as String;
      subjectCount[subject] = (subjectCount[subject] ?? 0) + 1;
    }
    return subjectCount;
  }

  // Load all teachers
  Future<void> loadTeachers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _teachers = await _teacherService.getAllTeachers();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new teacher
  Future<bool> addTeacher(Map<String, dynamic> teacher) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _teacherService.addTeacher(teacher);
      if (success) {
        await loadTeachers();
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

  // Update teacher
  Future<bool> updateTeacher(String teacherId, Map<String, dynamic> teacher) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _teacherService.updateTeacher(teacherId, teacher);
      if (success) {
        await loadTeachers();
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

  // Delete teacher
  Future<bool> deleteTeacher(String teacherId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _teacherService.deleteTeacher(teacherId);
      if (success) {
        await loadTeachers();
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

  // Search teachers
  void searchTeachers(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filter by subject
  void filterBySubject(String subject) {
    _selectedSubject = subject;
    _applyFilters();
    notifyListeners();
  }

  // Apply all filters
  void _applyFilters() {
    _filteredTeachers = _teachers.where((teacher) {
      final matchesSearch = _searchQuery.isEmpty ||
          teacher['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          teacher['teacher_id'].toString().toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesSubject = _selectedSubject == 'All' ||
          teacher['subject'] == _selectedSubject;

      return matchesSearch && matchesSubject;
    }).toList();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedSubject = 'All';
    _applyFilters();
    notifyListeners();
  }

  // Get unique subjects list
  List<String> getUniqueSubjects() {
    final subjects = _teachers.map((t) => t['subject'] as String).toSet().toList();
    subjects.sort();
    return ['All', ...subjects];
  }
}