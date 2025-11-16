// lib/data/services/teacher_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherService {
  static const String _teachersKey = 'teachers_data';

  // Load all teachers from local storage
  Future<List<Map<String, dynamic>>> getAllTeachers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final teachersJson = prefs.getString(_teachersKey);

      if (teachersJson != null) {
        final List<dynamic> teachersList = json.decode(teachersJson);
        return teachersList.cast<Map<String, dynamic>>();
      }

      return [];
    } catch (e) {
      print('Error loading teachers: $e');
      return [];
    }
  }

  // Save all teachers to local storage
  Future<bool> saveAllTeachers(List<Map<String, dynamic>> teachers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final teachersJson = json.encode(teachers);
      return await prefs.setString(_teachersKey, teachersJson);
    } catch (e) {
      print('Error saving teachers: $e');
      return false;
    }
  }

  // Add a new teacher
  Future<bool> addTeacher(Map<String, dynamic> teacher) async {
    try {
      final teachers = await getAllTeachers();
      teachers.add(teacher);
      return await saveAllTeachers(teachers);
    } catch (e) {
      print('Error adding teacher: $e');
      return false;
    }
  }

  // Update existing teacher
  Future<bool> updateTeacher(String teacherId, Map<String, dynamic> updatedTeacher) async {
    try {
      final teachers = await getAllTeachers();
      final index = teachers.indexWhere((t) => t['teacher_id'] == teacherId);

      if (index != -1) {
        teachers[index] = updatedTeacher;
        return await saveAllTeachers(teachers);
      }
      return false;
    } catch (e) {
      print('Error updating teacher: $e');
      return false;
    }
  }

  // Delete a teacher
  Future<bool> deleteTeacher(String teacherId) async {
    try {
      final teachers = await getAllTeachers();
      teachers.removeWhere((t) => t['teacher_id'] == teacherId);
      return await saveAllTeachers(teachers);
    } catch (e) {
      print('Error deleting teacher: $e');
      return false;
    }
  }

  // Get teacher by ID
  Future<Map<String, dynamic>?> getTeacherById(String teacherId) async {
    try {
      final teachers = await getAllTeachers();
      return teachers.firstWhere(
            (t) => t['teacher_id'] == teacherId,
        orElse: () => {},
      );
    } catch (e) {
      print('Error getting teacher: $e');
      return null;
    }
  }

  // Get teachers by subject
  Future<List<Map<String, dynamic>>> getTeachersBySubject(String subject) async {
    try {
      final teachers = await getAllTeachers();
      return teachers.where((t) => t['subject'] == subject).toList();
    } catch (e) {
      print('Error filtering teachers: $e');
      return [];
    }
  }

  // Search teachers by name
  Future<List<Map<String, dynamic>>> searchTeachers(String query) async {
    try {
      final teachers = await getAllTeachers();
      return teachers.where((t) =>
      t['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
          t['teacher_id'].toString().toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      print('Error searching teachers: $e');
      return [];
    }
  }

  // Get teachers count by subject
  Future<Map<String, int>> getTeacherCountBySubject() async {
    try {
      final teachers = await getAllTeachers();
      final Map<String, int> subjectCount = {};

      for (var teacher in teachers) {
        final subject = teacher['subject'] as String;
        subjectCount[subject] = (subjectCount[subject] ?? 0) + 1;
      }

      return subjectCount;
    } catch (e) {
      print('Error getting teacher count by subject: $e');
      return {};
    }
  }

  // Clear all teachers
  Future<bool> clearAllTeachers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_teachersKey);
    } catch (e) {
      print('Error clearing teachers: $e');
      return false;
    }
  }
}