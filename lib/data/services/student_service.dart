// ============================================
// 1. lib/data/services/student_service.dart (REPLACE COMPLETELY)
// ============================================
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'students';

  // Get all students
  Future<List<StudentModel>> getAllStudents() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('created_at', descending: true)
          .get();

      print('✅ Fetched ${snapshot.docs.length} students from Firestore');

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID
        return StudentModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('❌ Error getting students: $e');
      // Return empty list instead of throwing
      return [];
    }
  }

  // Add new student
  Future<bool> addStudent(StudentModel student) async {
    try {
      await _firestore.collection(_collection).add({
        'student_id': student.studentId,
        'name': student.name,
        'email': student.email,
        'class': student.className,
        'section': student.section,
        'roll_number': student.rollNumber,
        'date_of_birth': student.dateOfBirth,
        'blood_group': student.bloodGroup,
        'gender': student.gender,
        'address': student.address,
        'admission_date': student.admissionDate,
        'parent_details': {
          'father_name': student.parentDetails.fatherName,
          'father_phone': student.parentDetails.fatherPhone,
          'father_email': student.parentDetails.fatherEmail,
          'father_occupation': student.parentDetails.fatherOccupation,
          'mother_name': student.parentDetails.motherName,
          'mother_phone': student.parentDetails.motherPhone,
          'mother_email': student.parentDetails.motherEmail,
          'mother_occupation': student.parentDetails.motherOccupation,
        },
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      print('✅ Student added to Firestore: ${student.name}');
      return true;
    } catch (e) {
      print('❌ Error adding student to Firestore: $e');
      return false;
    }
  }

  // Update student
  Future<bool> updateStudent(StudentModel student) async {
    try {
      // Find document by student_id
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('student_id', isEqualTo: student.studentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('❌ Student not found: ${student.studentId}');
        return false;
      }

      final docId = querySnapshot.docs.first.id;

      await _firestore.collection(_collection).doc(docId).update({
        'name': student.name,
        'email': student.email,
        'class': student.className,
        'section': student.section,
        'roll_number': student.rollNumber,
        'date_of_birth': student.dateOfBirth,
        'blood_group': student.bloodGroup,
        'gender': student.gender,
        'address': student.address,
        'admission_date': student.admissionDate,
        'parent_details': {
          'father_name': student.parentDetails.fatherName,
          'father_phone': student.parentDetails.fatherPhone,
          'father_email': student.parentDetails.fatherEmail,
          'father_occupation': student.parentDetails.fatherOccupation,
          'mother_name': student.parentDetails.motherName,
          'mother_phone': student.parentDetails.motherPhone,
          'mother_email': student.parentDetails.motherEmail,
          'mother_occupation': student.parentDetails.motherOccupation,
        },
        'updated_at': FieldValue.serverTimestamp(),
      });
      print('✅ Student updated in Firestore: ${student.name}');
      return true;
    } catch (e) {
      print('❌ Error updating student in Firestore: $e');
      return false;
    }
  }

  // Delete student
  Future<bool> deleteStudent(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('student_id', isEqualTo: studentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('❌ Student not found for deletion: $studentId');
        return false;
      }

      await querySnapshot.docs.first.reference.delete();
      print('✅ Student deleted from Firestore: $studentId');
      return true;
    } catch (e) {
      print('❌ Error deleting student from Firestore: $e');
      return false;
    }
  }

  // Get student by ID
  Future<StudentModel?> getStudentById(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('student_id', isEqualTo: studentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final data = querySnapshot.docs.first.data();
      data['id'] = querySnapshot.docs.first.id;
      return StudentModel.fromJson(data);
    } catch (e) {
      print('❌ Error getting student by ID: $e');
      return null;
    }
  }

  // Get students by class and section
  Future<List<StudentModel>> getStudentsByClass(String className, String section) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('class', isEqualTo: className)
          .where('section', isEqualTo: section)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return StudentModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('❌ Error filtering students: $e');
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
      print('❌ Error searching students: $e');
      return [];
    }
  }

  // Initialize sample data
  Future<bool> initializeSampleData(List<Map<String, dynamic>> sampleData) async {
    try {
      final batch = _firestore.batch();

      for (var data in sampleData) {
        final docRef = _firestore.collection(_collection).doc();
        data['created_at'] = FieldValue.serverTimestamp();
        data['updated_at'] = FieldValue.serverTimestamp();
        batch.set(docRef, data);
      }

      await batch.commit();
      print('✅ Sample data initialized in Firestore');
      return true;
    } catch (e) {
      print('❌ Error initializing sample data: $e');
      return false;
    }
  }

  // Clear all students (use with caution!)
  Future<bool> clearAllStudents() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final batch = _firestore.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ All students cleared from Firestore');
      return true;
    } catch (e) {
      print('❌ Error clearing students: $e');
      return false;
    }
  }
}
