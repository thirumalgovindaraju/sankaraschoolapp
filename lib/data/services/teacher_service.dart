// lib/data/services/teacher_service.dart (COMPLETE FIXED VERSION)

import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'teachers';

  // Get all teachers
  Future<List<Map<String, dynamic>>> getAllTeachers() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('created_at', descending: true)
          .get();

      print('✅ Fetched ${snapshot.docs.length} teachers from Firestore');

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID
        return data;
      }).toList();
    } catch (e) {
      print('❌ Error getting teachers: $e');
      return [];
    }
  }

  // Add new teacher
  Future<bool> addTeacher(Map<String, dynamic> teacherData) async {
    try {
      teacherData['created_at'] = FieldValue.serverTimestamp();
      teacherData['updated_at'] = FieldValue.serverTimestamp();

      await _firestore.collection(_collection).add(teacherData);
      print('✅ Teacher added to Firestore: ${teacherData['name']}');
      return true;
    } catch (e) {
      print('❌ Error adding teacher to Firestore: $e');
      return false;
    }
  }

  // Update teacher
  Future<bool> updateTeacher(String teacherId, Map<String, dynamic> teacherData) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('teacher_id', isEqualTo: teacherId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('❌ Teacher not found: $teacherId');
        return false;
      }

      final docId = querySnapshot.docs.first.id;
      teacherData['updated_at'] = FieldValue.serverTimestamp();

      await _firestore.collection(_collection).doc(docId).update(teacherData);
      print('✅ Teacher updated in Firestore: ${teacherData['name']}');
      return true;
    } catch (e) {
      print('❌ Error updating teacher in Firestore: $e');
      return false;
    }
  }

  // Delete teacher
  Future<bool> deleteTeacher(String teacherId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('teacher_id', isEqualTo: teacherId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('❌ Teacher not found for deletion: $teacherId');
        return false;
      }

      await querySnapshot.docs.first.reference.delete();
      print('✅ Teacher deleted from Firestore: $teacherId');
      return true;
    } catch (e) {
      print('❌ Error deleting teacher from Firestore: $e');
      return false;
    }
  }

  // Get teacher by ID
  Future<Map<String, dynamic>?> getTeacherById(String teacherId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('teacher_id', isEqualTo: teacherId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final data = querySnapshot.docs.first.data();
      data['id'] = querySnapshot.docs.first.id;
      return data;
    } catch (e) {
      print('❌ Error getting teacher by ID: $e');
      return null;
    }
  }

  // Get teachers by subject
  Future<List<Map<String, dynamic>>> getTeachersBySubject(String subject) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('subject', isEqualTo: subject)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('❌ Error filtering teachers by subject: $e');
      return [];
    }
  }

  // Search teachers
  Future<List<Map<String, dynamic>>> searchTeachers(String query) async {
    try {
      final teachers = await getAllTeachers();
      return teachers.where((t) =>
      (t['name'] as String).toLowerCase().contains(query.toLowerCase()) ||
          (t['teacher_id'] as String).toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      print('❌ Error searching teachers: $e');
      return [];
    }
  }

  // Get teacher count by subject
  Future<Map<String, int>> getTeacherCountBySubject() async {
    try {
      final teachers = await getAllTeachers();
      final subjectCount = <String, int>{};

      for (var teacher in teachers) {
        final subject = teacher['subject'] as String? ?? 'Unknown';
        subjectCount[subject] = (subjectCount[subject] ?? 0) + 1;
      }

      return subjectCount;
    } catch (e) {
      print('❌ Error getting teacher count by subject: $e');
      return {};
    }
  }

  // Clear all teachers (use with caution!)
  Future<bool> clearAllTeachers() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final batch = _firestore.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ All teachers cleared from Firestore');
      return true;
    } catch (e) {
      print('❌ Error clearing teachers: $e');
      return false;
    }
  }
}