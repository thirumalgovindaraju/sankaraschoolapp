// lib/data/services/attendance_service.dart
// FINAL VERSION - All parameter name errors fixed

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';
import '../models/attendance_summary_model.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _attendanceCollection = 'attendance';

  // ==================== MARK ATTENDANCE ====================

  /// Mark attendance for a single student
  Future<bool> markSingleAttendance({
    required String studentId,
    required String studentName,
    required String rollNumber,
    required String classId,
    required String className,
    required String section,
    required DateTime date,
    required String status,
    required String markedBy,
    required String markedByName,
    String? remarks,
    String? subject,
    int? period,
  }) async {
    try {
      // Check if attendance already exists
      final existingAttendance = await _checkExistingAttendance(
        studentId: studentId,
        classId: classId,
        date: date,
        subject: subject,
        period: period,
      );

      if (existingAttendance != null) {
        // Update existing attendance
        return await updateAttendance(
          attendanceId: existingAttendance.id,
          status: status,
          remarks: remarks,
        );
      }

      // Create new attendance record
      final attendanceData = {
        'student_id': studentId,
        'student_name': studentName,
        'roll_number': rollNumber,
        'class_id': classId,
        'class_name': className,
        'section': section,
        'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
        'status': status.toLowerCase(),
        'remarks': remarks,
        'marked_by': markedBy,
        'marked_by_name': markedByName,
        'marked_at': FieldValue.serverTimestamp(),
        'updated_at': null,
        'subject': subject,
        'period': period,
        'parent_notified': false,
        'metadata': {
          'source': 'teacher_app',
          'ip_address': null,
        },
      };

      await _firestore.collection(_attendanceCollection).add(attendanceData);

      // print('✅ Attendance marked successfully for $studentName');
      return true;
    } catch (e) {
      // print('❌ Error marking attendance: $e');
      return false;
    }
  }

  /// Mark bulk attendance for entire class
  Future<Map<String, dynamic>> markBulkAttendance({
    required String classId,
    required String className,
    required String section,
    required DateTime date,
    required List<StudentAttendanceEntry> students,
    required String markedBy,
    required String markedByName,
    String? subject,
    String? period,
  }) async {
    try {
      final batch = _firestore.batch();
      int successCount = 0;
      int failureCount = 0;
      final dateOnly = DateTime(date.year, date.month, date.day);

      final periodInt = period != null ? int.tryParse(period) : null;

      for (var student in students) {
        try {
          final existingAttendance = await _checkExistingAttendance(
            studentId: student.studentId,
            classId: classId,
            date: date,
            subject: subject,
            period: periodInt,
          );

          if (existingAttendance != null) {
            final docRef = _firestore.collection(_attendanceCollection).doc(existingAttendance.id);
            batch.update(docRef, {
              'status': student.status.toLowerCase(),
              'remarks': student.remarks,
              'updated_at': FieldValue.serverTimestamp(),
            });
          } else {
            final docRef = _firestore.collection(_attendanceCollection).doc();
            batch.set(docRef, {
              'student_id': student.studentId,
              'student_name': student.studentName,
              'roll_number': student.rollNumber,
              'class_id': classId,
              'class_name': className,
              'section': section,
              'date': Timestamp.fromDate(dateOnly),
              'status': student.status.toLowerCase(),
              'remarks': student.remarks,
              'marked_by': markedBy,
              'marked_by_name': markedByName,
              'marked_at': FieldValue.serverTimestamp(),
              'updated_at': null,
              'subject': subject,
              'period': periodInt,
              'parent_notified': false,
              'metadata': {
                'source': 'teacher_app_bulk',
                'batch_size': students.length,
              },
            });
          }

          successCount++;
        } catch (e) {
          // print('❌ Error processing attendance for ${student.studentName}: $e');
          failureCount++;
        }
      }

      await batch.commit();

      // print('✅ Bulk attendance marked: $successCount success, $failureCount failures');

      return {
        'success': true,
        'message': 'Attendance marked for $successCount out of ${students.length} students',
        'success_count': successCount,
        'failure_count': failureCount,
      };
    } catch (e) {
      // print('❌ Error marking bulk attendance: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
        'success_count': 0,
        'failure_count': students.length,
      };
    }
  }

  /// Update existing attendance record
  Future<bool> updateAttendance({
    required String attendanceId,
    String? status,
    String? remarks,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (status != null) {
        updateData['status'] = status.toLowerCase();
      }

      if (remarks != null) {
        updateData['remarks'] = remarks;
      }

      await _firestore
          .collection(_attendanceCollection)
          .doc(attendanceId)
          .update(updateData);

      // print('✅ Attendance updated successfully: $attendanceId');
      return true;
    } catch (e) {
      // print('❌ Error updating attendance: $e');
      return false;
    }
  }

  // ==================== FETCH ATTENDANCE ====================

  /// Get student attendance records
  Future<List<AttendanceModel>> getStudentAttendance({
    required String studentId,
    DateTime? startDate,
    DateTime? endDate,
    String? subject,
  }) async {
    try {
      Query query = _firestore
          .collection(_attendanceCollection)
          .where('student_id', isEqualTo: studentId)
          .orderBy('date', descending: true);

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();

      final records = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
        }
        if (data['marked_at'] is Timestamp) {
          data['marked_at'] = (data['marked_at'] as Timestamp).toDate().toIso8601String();
        }
        if (data['updated_at'] is Timestamp) {
          data['updated_at'] = (data['updated_at'] as Timestamp).toDate().toIso8601String();
        }

        return AttendanceModel.fromJson(data);
      }).toList();

      if (subject != null && subject.isNotEmpty) {
        return records.where((r) => r.subject == subject).toList();
      }

      // print('✅ Fetched ${records.length} attendance records for student: $studentId');
      return records;
    } catch (e) {
      // print('❌ Error fetching student attendance: $e');
      return [];
    }
  }

  /// Get class attendance for a specific date
  Future<List<AttendanceModel>> getClassAttendance({
    required String classId,
    required DateTime date,
    String? subject,
    String? period,
  }) async {
    try {
      final dateOnly = DateTime(date.year, date.month, date.day);

      Query query = _firestore
          .collection(_attendanceCollection)
          .where('class_id', isEqualTo: classId)
          .where('date', isEqualTo: Timestamp.fromDate(dateOnly));

      final snapshot = await query.get();

      List<AttendanceModel> records = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
        }
        if (data['marked_at'] is Timestamp) {
          data['marked_at'] = (data['marked_at'] as Timestamp).toDate().toIso8601String();
        }
        if (data['updated_at'] is Timestamp) {
          data['updated_at'] = (data['updated_at'] as Timestamp).toDate().toIso8601String();
        }

        return AttendanceModel.fromJson(data);
      }).toList();

      if (subject != null && subject.isNotEmpty) {
        records = records.where((r) => r.subject == subject).toList();
      }
      if (period != null && period.isNotEmpty) {
        final periodInt = int.tryParse(period);
        if (periodInt != null) {
          records = records.where((r) => r.period == periodInt).toList();
        }
      }

      records.sort((a, b) {
        final aNum = int.tryParse(a.rollNumber) ?? 0;
        final bNum = int.tryParse(b.rollNumber) ?? 0;
        return aNum.compareTo(bNum);
      });

      // print('✅ Fetched ${records.length} attendance records for class: $classId on $dateOnly');
      return records;
    } catch (e) {
      // print('❌ Error fetching class attendance: $e');
      return [];
    }
  }

  /// Get attendance summary for a student
  /// ✅ FIXED: Changed parameter names to match AttendanceSummaryModel
  Future<AttendanceSummaryModel?> getAttendanceSummary({
    required String studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final records = await getStudentAttendance(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      );

      if (records.isEmpty) {
        return AttendanceSummaryModel(
          studentId: studentId,  // ✅ FIXED: Added studentId
          totalDays: 0,
          presentDays: 0,
          absentDays: 0,
          lateDays: 0,
          excusedDays: 0,
          sickDays: 0,  // ✅ FIXED: Added sickDays
          attendancePercentage: 0.0,
        );
      }

      int totalDays = records.length;
      int presentDays = records.where((r) => r.status.toLowerCase() == 'present').length;
      int absentDays = records.where((r) => r.status.toLowerCase() == 'absent').length;
      int lateDays = records.where((r) => r.status.toLowerCase() == 'late').length;
      int excusedDays = records.where((r) => r.status.toLowerCase() == 'excused').length;
      int sickDays = records.where((r) => r.status.toLowerCase() == 'sick').length;  // ✅ FIXED

      double percentage = totalDays > 0 ? (presentDays / totalDays) * 100 : 0.0;

      final summary = AttendanceSummaryModel(
        studentId: studentId,  // ✅ FIXED: Added studentId
        totalDays: totalDays,
        presentDays: presentDays,
        absentDays: absentDays,
        lateDays: lateDays,
        excusedDays: excusedDays,
        sickDays: sickDays,  // ✅ FIXED: Added sickDays
        attendancePercentage: percentage,
      );

      // print('✅ Attendance summary for student $studentId: ${percentage.toStringAsFixed(1)}%');
      return summary;
    } catch (e) {
      // print('❌ Error calculating attendance summary: $e');
      return null;
    }
  }

  /// Get today's attendance for a student
  Future<AttendanceModel?> getTodayAttendance(String studentId) async {
    try {
      final today = DateTime.now();
      final dateOnly = DateTime(today.year, today.month, today.day);

      final snapshot = await _firestore
          .collection(_attendanceCollection)
          .where('student_id', isEqualTo: studentId)
          .where('date', isEqualTo: Timestamp.fromDate(dateOnly))
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final data = snapshot.docs.first.data();
      data['id'] = snapshot.docs.first.id;

      if (data['date'] is Timestamp) {
        data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
      }
      if (data['marked_at'] is Timestamp) {
        data['marked_at'] = (data['marked_at'] as Timestamp).toDate().toIso8601String();
      }
      if (data['updated_at'] is Timestamp) {
        data['updated_at'] = (data['updated_at'] as Timestamp).toDate().toIso8601String();
      }

      return AttendanceModel.fromJson(data);
    } catch (e) {
      // print('❌ Error fetching today\'s attendance: $e');
      return null;
    }
  }

  // ==================== UTILITY METHODS ====================

  Future<bool> isAttendanceMarkedForClass({
    required String classId,
    required DateTime date,
    String? subject,
    String? period,
  }) async {
    try {
      final dateOnly = DateTime(date.year, date.month, date.day);

      Query query = _firestore
          .collection(_attendanceCollection)
          .where('class_id', isEqualTo: classId)
          .where('date', isEqualTo: Timestamp.fromDate(dateOnly))
          .limit(1);

      final snapshot = await query.get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      // print('❌ Error checking attendance: $e');
      return false;
    }
  }

  Future<AttendanceModel?> _checkExistingAttendance({
    required String studentId,
    required String classId,
    required DateTime date,
    String? subject,
    int? period,
  }) async {
    try {
      final dateOnly = DateTime(date.year, date.month, date.day);

      Query query = _firestore
          .collection(_attendanceCollection)
          .where('student_id', isEqualTo: studentId)
          .where('class_id', isEqualTo: classId)
          .where('date', isEqualTo: Timestamp.fromDate(dateOnly));

      if (subject != null) {
        query = query.where('subject', isEqualTo: subject);
      }
      if (period != null) {
        query = query.where('period', isEqualTo: period);
      }

      final snapshot = await query.limit(1).get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      data['id'] = snapshot.docs.first.id;

      if (data['date'] is Timestamp) {
        data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
      }
      if (data['marked_at'] is Timestamp) {
        data['marked_at'] = (data['marked_at'] as Timestamp).toDate().toIso8601String();
      }
      if (data['updated_at'] is Timestamp) {
        data['updated_at'] = (data['updated_at'] as Timestamp).toDate().toIso8601String();
      }

      return AttendanceModel.fromJson(data);
    } catch (e) {
      // print('❌ Error checking existing attendance: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getAttendanceStatistics({
    String? classId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final today = DateTime.now();
      final dateOnly = DateTime(today.year, today.month, today.day);

      Query query = _firestore
          .collection(_attendanceCollection)
          .where('date', isEqualTo: Timestamp.fromDate(dateOnly));

      if (classId != null) {
        query = query.where('class_id', isEqualTo: classId);
      }

      final snapshot = await query.get();

      int totalStudents = snapshot.docs.length;
      int presentToday = snapshot.docs.where((doc) => doc['status'] == 'present').length;
      int absentToday = snapshot.docs.where((doc) => doc['status'] == 'absent').length;
      int lateToday = snapshot.docs.where((doc) => doc['status'] == 'late').length;

      double averageAttendance = totalStudents > 0
          ? (presentToday / totalStudents) * 100
          : 0.0;

      return {
        'total_students': totalStudents,
        'present_today': presentToday,
        'absent_today': absentToday,
        'late_today': lateToday,
        'average_attendance': averageAttendance,
      };
    } catch (e) {
      // print('❌ Error getting attendance statistics: $e');
      return {
        'total_students': 0,
        'present_today': 0,
        'absent_today': 0,
        'late_today': 0,
        'average_attendance': 0.0,
      };
    }
  }

  Future<List<Map<String, dynamic>>> getStudentsWithLowAttendance({
    String? classId,
    double threshold = 75.0,
  }) async {
    try {
      Query query = _firestore.collection(_attendanceCollection);

      if (classId != null) {
        query = query.where('class_id', isEqualTo: classId);
      }

      final snapshot = await query.get();

      final studentAttendance = <String, Map<String, dynamic>>{};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final studentId = data['student_id'];

        if (!studentAttendance.containsKey(studentId)) {
          studentAttendance[studentId] = {
            'student_id': studentId,
            'student_name': data['student_name'],
            'class_id': data['class_id'],
            'class_name': data['class_name'],
            'section': data['section'],
            'total': 0,
            'present': 0,
          };
        }

        studentAttendance[studentId]!['total']++;
        if (data['status'] == 'present') {
          studentAttendance[studentId]!['present']++;
        }
      }

      final lowAttendanceStudents = <Map<String, dynamic>>[];

      studentAttendance.forEach((studentId, data) {
        final total = data['total'] as int;
        final present = data['present'] as int;
        final percentage = total > 0 ? (present / total) * 100 : 0.0;

        if (percentage < threshold) {
          lowAttendanceStudents.add({
            ...data,
            'attendance_percentage': percentage,
          });
        }
      });

      lowAttendanceStudents.sort((a, b) =>
          a['attendance_percentage'].compareTo(b['attendance_percentage']));

      // print('✅ Found ${lowAttendanceStudents.length} students with low attendance');
      return lowAttendanceStudents;
    } catch (e) {
      // print('❌ Error getting low attendance students: $e');
      return [];
    }
  }

  Future<bool> deleteAttendance(String attendanceId) async {
    try {
      await _firestore.collection(_attendanceCollection).doc(attendanceId).delete();
      // print('✅ Attendance deleted successfully: $attendanceId');
      return true;
    } catch (e) {
      // print('❌ Error deleting attendance: $e');
      return false;
    }
  }
}