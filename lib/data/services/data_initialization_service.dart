// lib/data/services/data_initialization_service.dart (FIXED VERSION)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'student_service.dart';
import 'teacher_service.dart';

class DataInitializationService {
  static const String _initKey = 'data_initialized';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Load test data from JSON
  static Future<Map<String, dynamic>?> _loadTestData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/test_data.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;
      print('✅ Test data loaded from JSON');
      return data;
    } catch (e) {
      print('❌ Error loading test data: $e');
      return null;
    }
  }

  /// Initialize all data from test_data.json to Firestore
  static Future<bool> initializeAllData({bool forceReinit = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isInitialized = prefs.getBool(_initKey) ?? false;

      // Skip if already initialized and not forcing
      if (isInitialized && !forceReinit) {
        print('ℹ️ Data already initialized, skipping...');
        return true;
      }

      print('🚀 Starting Firestore data initialization...');

      // Load test data
      final testData = await _loadTestData();
      if (testData == null) {
        print('❌ Failed to load test data');
        return false;
      }

      // Initialize students
      final studentService = StudentService();
      final students = testData['students'] as List<dynamic>? ?? [];

      if (students.isNotEmpty) {
        print('📝 Initializing ${students.length} students...');

        // Clear existing data if forcing reinit
        if (forceReinit) {
          await studentService.clearAllStudents();
        }

        final studentsData = students.map((s) => s as Map<String, dynamic>).toList();
        await studentService.initializeSampleData(studentsData);
        print('✅ Students initialized successfully');
      }

      // Initialize teachers
      final teacherService = TeacherService();
      final teachers = testData['teachers'] as List<dynamic>? ?? [];

      if (teachers.isNotEmpty) {
        print('📝 Initializing ${teachers.length} teachers...');

        // Clear existing data if forcing reinit
        if (forceReinit) {
          await teacherService.clearAllTeachers();
        }

        // Add teachers one by one
        for (var teacherData in teachers) {
          await teacherService.addTeacher(teacherData as Map<String, dynamic>);
        }
        print('✅ Teachers initialized successfully');
      }

      // Initialize sample activities
      await _initializeSampleActivities();

      // Mark as initialized
      await prefs.setBool(_initKey, true);
      print('✅ All data initialization complete!');

      return true;
    } catch (e) {
      print('❌ Data initialization error: $e');
      return false;
    }
  }

  /// Initialize sample activities
  static Future<void> _initializeSampleActivities() async {
    try {
      final activitiesRef = _firestore.collection('activities');

      // Check if activities already exist
      final existingActivities = await activitiesRef.limit(1).get();
      if (existingActivities.docs.isNotEmpty) {
        print('ℹ️ Activities already exist, skipping initialization');
        return;
      }

      final sampleActivities = [
        {
          'type': 'student',
          'title': 'New Student Admission',
          'description': 'Rahul Kumar admitted to Class 5-A',
          'userName': 'Rahul Kumar',
          'timestamp': FieldValue.serverTimestamp(),
          'metadata': {'student_name': 'Rahul Kumar', 'class': '5-A'}
        },
        {
          'type': 'teacher',
          'title': 'New Teacher Joined',
          'description': 'Ms. Priya Singh joined as Mathematics teacher',
          'userName': 'Ms. Priya Singh',
          'timestamp': FieldValue.serverTimestamp(),
          'metadata': {'teacher_name': 'Priya Singh', 'subject': 'Mathematics'}
        },
        {
          'type': 'announcement',
          'title': 'School Event',
          'description': 'Annual Day celebrations scheduled for next month',
          'userName': 'Admin',
          'timestamp': FieldValue.serverTimestamp(),
          'metadata': {'event_type': 'Annual Day'}
        },
      ];

      final batch = _firestore.batch();
      for (var activity in sampleActivities) {
        final docRef = activitiesRef.doc();
        batch.set(docRef, activity);
      }
      await batch.commit();

      print('✅ Sample activities initialized');
    } catch (e) {
      print('❌ Error initializing activities: $e');
    }
  }

  /// Get initialization status
  static Future<Map<String, dynamic>> getInitializationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isInitialized = prefs.getBool(_initKey) ?? false;

      if (!isInitialized) {
        return {
          'initialized': false,
          'student_count': 0,
          'teacher_count': 0,
        };
      }

      // Get counts from Firestore
      final studentsSnapshot = await _firestore.collection('students').get();
      final teachersSnapshot = await _firestore.collection('teachers').get();

      return {
        'initialized': true,
        'student_count': studentsSnapshot.docs.length,
        'teacher_count': teachersSnapshot.docs.length,
      };
    } catch (e) {
      print('❌ Error getting initialization status: $e');
      return {
        'initialized': false,
        'student_count': 0,
        'teacher_count': 0,
      };
    }
  }

  /// Clear initialization flag
  static Future<void> clearInitializationFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_initKey);
    print('✅ Initialization flag cleared');
  }

  /// Reset all data (use with caution!)
  static Future<bool> resetAllData() async {
    try {
      print('⚠️ Resetting all data...');

      // Clear students
      final studentService = StudentService();
      await studentService.clearAllStudents();

      // Clear teachers
      final teacherService = TeacherService();
      await teacherService.clearAllTeachers();

      // Clear activities
      final activitiesSnapshot = await _firestore.collection('activities').get();
      final batch = _firestore.batch();
      for (var doc in activitiesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Clear initialization flag
      await clearInitializationFlag();

      print('✅ All data reset complete');
      return true;
    } catch (e) {
      print('❌ Error resetting data: $e');
      return false;
    }
  }
}