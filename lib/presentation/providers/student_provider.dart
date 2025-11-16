import 'package:flutter/foundation.dart';
import '../../data/models/student_model.dart';
import '../../data/services/student_service.dart';

class StudentProvider with ChangeNotifier {
  final StudentService _studentService = StudentService();

  List<StudentModel> _students = [];
  List<StudentModel> _filteredStudents = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedClass = 'All';
  String _selectedSection = 'All';

  List<StudentModel> get students => _filteredStudents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedClass => _selectedClass;
  String get selectedSection => _selectedSection;

  int get totalStudents => _students.length;

  Map<String, int> get studentsByClass {
    final Map<String, int> classCount = {};
    for (var student in _students) {
      final key = '${student.className}-${student.section}';
      classCount[key] = (classCount[key] ?? 0) + 1;
    }
    return classCount;
  }

  // Load all students
  Future<void> loadStudents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _students = await _studentService.getAllStudents();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new student
  Future<bool> addStudent(StudentModel student) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _studentService.addStudent(student);
      if (success) {
        await loadStudents();
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

  // Update student
  Future<bool> updateStudent(StudentModel student) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _studentService.updateStudent(student);
      if (success) {
        await loadStudents();
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

  // Delete student
  Future<bool> deleteStudent(String studentId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _studentService.deleteStudent(studentId);
      if (success) {
        await loadStudents();
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

  // Search students
  void searchStudents(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filter by class
  void filterByClass(String className) {
    _selectedClass = className;
    _applyFilters();
    notifyListeners();
  }

  // Filter by section
  void filterBySection(String section) {
    _selectedSection = section;
    _applyFilters();
    notifyListeners();
  }

  // Apply all filters
  void _applyFilters() {
    _filteredStudents = _students.where((student) {
      final matchesSearch = _searchQuery.isEmpty ||
          student.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.studentId.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesClass = _selectedClass == 'All' ||
          student.className == _selectedClass;

      final matchesSection = _selectedSection == 'All' ||
          student.section == _selectedSection;

      return matchesSearch && matchesClass && matchesSection;
    }).toList();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedClass = 'All';
    _selectedSection = 'All';
    _applyFilters();
    notifyListeners();
  }

  // Initialize with sample data
  Future<bool> initializeSampleData(List<Map<String, dynamic>> sampleData) async {
    try {
      final success = await _studentService.initializeSampleData(sampleData);
      if (success) {
        await loadStudents();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
}