import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_model.dart';

class StudentService {
  static const String _studentsKey = 'students_data';

  // Load all students from local storage
  Future<List<StudentModel>> getAllStudents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentsJson = prefs.getString(_studentsKey);

      if (studentsJson != null) {
        final List<dynamic> studentsList = json.decode(studentsJson);
        return studentsList.map((json) => StudentModel.fromJson(json)).toList();
      }

      // Return empty list if no data
      return [];
    } catch (e) {
      print('Error loading students: $e');
      return [];
    }
  }

  // Save all students to local storage
  Future<bool> saveAllStudents(List<StudentModel> students) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentsJson = json.encode(students.map((s) => s.toJson()).toList());
      return await prefs.setString(_studentsKey, studentsJson);
    } catch (e) {
      print('Error saving students: $e');
      return false;
    }
  }

  // Add a new student
  Future<bool> addStudent(StudentModel student) async {
    try {
      final students = await getAllStudents();
      students.add(student);
      return await saveAllStudents(students);
    } catch (e) {
      print('Error adding student: $e');
      return false;
    }
  }

  // Update existing student
  Future<bool> updateStudent(StudentModel updatedStudent) async {
    try {
      final students = await getAllStudents();
      final index = students.indexWhere((s) => s.studentId == updatedStudent.studentId);

      if (index != -1) {
        students[index] = updatedStudent;
        return await saveAllStudents(students);
      }
      return false;
    } catch (e) {
      print('Error updating student: $e');
      return false;
    }
  }

  // Delete a student
  Future<bool> deleteStudent(String studentId) async {
    try {
      final students = await getAllStudents();
      students.removeWhere((s) => s.studentId == studentId);
      return await saveAllStudents(students);
    } catch (e) {
      print('Error deleting student: $e');
      return false;
    }
  }

  // Get student by ID
  Future<StudentModel?> getStudentById(String studentId) async {
    try {
      final students = await getAllStudents();
      return students.firstWhere(
            (s) => s.studentId == studentId,
        orElse: () => throw Exception('Student not found'),
      );
    } catch (e) {
      print('Error getting student: $e');
      return null;
    }
  }

  // Get students by class and section
  Future<List<StudentModel>> getStudentsByClass(String className, String section) async {
    try {
      final students = await getAllStudents();
      return students.where((s) =>
      s.className == className && s.section == section
      ).toList();
    } catch (e) {
      print('Error filtering students: $e');
      return [];
    }
  }

  // Search students by name
  Future<List<StudentModel>> searchStudents(String query) async {
    try {
      final students = await getAllStudents();
      return students.where((s) =>
      s.name.toLowerCase().contains(query.toLowerCase()) ||
          s.studentId.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      print('Error searching students: $e');
      return [];
    }
  }

  // Initialize with sample data (call this once during app setup)
  Future<bool> initializeSampleData(List<Map<String, dynamic>> sampleStudents) async {
    try {
      final students = sampleStudents.map((json) => StudentModel.fromJson(json)).toList();
      return await saveAllStudents(students);
    } catch (e) {
      print('Error initializing sample data: $e');
      return false;
    }
  }

  // Clear all students
  Future<bool> clearAllStudents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_studentsKey);
    } catch (e) {
      print('Error clearing students: $e');
      return false;
    }
  }
}