// lib/data/services/data_initialization_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_model.dart';

class DataInitializationService {
  static const String _initialized_key = 'data_initialized_v1';
  static const String _students_key = 'students_data';
  static const String _teachers_key = 'teachers_data';

  /// Check if data has been initialized
  static Future<bool> isDataInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_initialized_key) ?? false;
  }

  /// Initialize all data from test_data.json
  static Future<bool> initializeAllData() async {
    try {
      print('🚀 Starting data initialization...');

      // Check if already initialized
      final alreadyInitialized = await isDataInitialized();
      if (alreadyInitialized) {
        print('ℹ️ Data already initialized, skipping...');
        return true;
      }

      // Load JSON file from assets
      final jsonString = await rootBundle.loadString('assets/test_data.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      print('✅ JSON file loaded successfully');

      // Initialize students
      final studentsData = data['students'] as List<dynamic>;
      final bool studentsInitialized = await _initializeStudents(studentsData);

      // Initialize teachers
      final teachersData = data['teachers'] as List<dynamic>;
      final bool teachersInitialized = await _initializeTeachers(teachersData);

      // Mark as initialized
      if (studentsInitialized && teachersInitialized) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_initialized_key, true);
        print('✅ All data initialized successfully!');
        print('📊 Students: ${studentsData.length}');
        print('👨‍🏫 Teachers: ${teachersData.length}');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error initializing data: $e');
      return false;
    }
  }

  /// Initialize students data
  static Future<bool> _initializeStudents(List<dynamic> studentsData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert to StudentModel list
      final students = studentsData.map((json) => StudentModel.fromJson(json)).toList();

      // Save to SharedPreferences
      final studentsJson = json.encode(students.map((s) => s.toJson()).toList());
      await prefs.setString(_students_key, studentsJson);

      print('✅ Initialized ${students.length} students');
      return true;
    } catch (e) {
      print('❌ Error initializing students: $e');
      return false;
    }
  }

  /// Initialize teachers data
  static Future<bool> _initializeTeachers(List<dynamic> teachersData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save teachers as JSON
      final teachersJson = json.encode(teachersData);
      await prefs.setString(_teachers_key, teachersJson);

      print('✅ Initialized ${teachersData.length} teachers');
      return true;
    } catch (e) {
      print('❌ Error initializing teachers: $e');
      return false;
    }
  }

  /// Force re-initialization (useful for testing or updates)
  static Future<bool> forceReinitialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear initialization flag
      await prefs.remove(_initialized_key);

      // Clear existing data
      await prefs.remove(_students_key);
      await prefs.remove(_teachers_key);

      print('🔄 Cleared existing data, re-initializing...');

      // Re-initialize
      return await initializeAllData();
    } catch (e) {
      print('❌ Error during force re-initialization: $e');
      return false;
    }
  }

  /// Get initialization status details
  static Future<Map<String, dynamic>> getInitializationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isInitialized = prefs.getBool(_initialized_key) ?? false;

      int studentCount = 0;
      int teacherCount = 0;

      if (isInitialized) {
        // Get student count
        final studentsJson = prefs.getString(_students_key);
        if (studentsJson != null) {
          final List<dynamic> studentsList = json.decode(studentsJson);
          studentCount = studentsList.length;
        }

        // Get teacher count
        final teachersJson = prefs.getString(_teachers_key);
        if (teachersJson != null) {
          final List<dynamic> teachersList = json.decode(teachersJson);
          teacherCount = teachersList.length;
        }
      }

      return {
        'is_initialized': isInitialized,
        'student_count': studentCount,
        'teacher_count': teacherCount,
      };
    } catch (e) {
      print('❌ Error getting initialization status: $e');
      return {
        'is_initialized': false,
        'student_count': 0,
        'teacher_count': 0,
      };
    }
  }
}